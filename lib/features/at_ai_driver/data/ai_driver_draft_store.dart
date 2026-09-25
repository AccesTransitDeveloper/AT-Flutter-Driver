import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/preferences/shared_preference_manager.dart';
import '../models/ai_driver_document_draft.dart';
import '../models/ai_driver_registration_draft.dart';

class AiDriverDraftStore {
  static const _secureFilesChannel = MethodChannel(
    'com.accessible.provider/secure_files',
  );
  static const _directoryName = 'at_ai_driver';
  static const _draftFileName = 'registration_draft.json';
  static const _backupFileName = 'registration_draft.backup.json';
  final String _accountScope;

  const AiDriverDraftStore._(this._accountScope);

  static Future<AiDriverDraftStore> forCurrentSession() async {
    final preferences = await SharedPreferenceManager.create();
    final authorization = preferences.getAuthorization();
    if (authorization == null || authorization.isEmpty) {
      throw StateError('An authenticated driver session is required.');
    }
    final scope = sha256
        .convert(utf8.encode(_stableSessionIdentity(authorization)))
        .toString();
    return AiDriverDraftStore._(scope);
  }

  /// Creates a pre-registration scope from the authoritative login identity.
  /// It is intentionally separate from [forCurrentSession], which requires an
  /// access token and is used only after authentication.
  static Future<AiDriverDraftStore> forRegistrationIdentity(
    String identity,
  ) async {
    final normalized = identity.trim().toLowerCase();
    if (normalized.isEmpty) {
      throw StateError('A registration identity is required.');
    }
    final scope = sha256
        .convert(utf8.encode('registration:$normalized'))
        .toString();
    return AiDriverDraftStore._(scope);
  }

  static String _stableSessionIdentity(String authorization) {
    final token = authorization.replaceFirst(RegExp(r'^Bearer\s+'), '');
    final segments = token.split('.');
    if (segments.length == 3) {
      try {
        final payload =
            jsonDecode(
                  utf8.decode(
                    base64Url.decode(base64Url.normalize(segments[1])),
                  ),
                )
                as Map<String, dynamic>;
        for (final key in const ['sub', 'userId', 'user_id', 'id']) {
          final value = payload[key]?.toString();
          if (value != null && value.isNotEmpty) return value;
        }
      } catch (_) {
        // Opaque and non-standard tokens are safely scoped by their full hash.
      }
    }
    return token;
  }

  Future<Directory> _draftDirectory() async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory(
      '${root.path}/$_directoryName/accounts/$_accountScope',
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    if (Platform.isIOS) {
      await _secureFilesChannel.invokeMethod<void>('excludeFromBackup', {
        'path': directory.path,
      });
    }
    return directory;
  }

  Future<AiDriverRegistrationDraft> loadOrCreate() async {
    final existing = await loadExisting();
    if (existing != null) return existing;
    return createFresh();
  }

  Future<AiDriverRegistrationDraft?> loadExisting() async {
    final directory = await _draftDirectory();
    final file = File('${directory.path}/$_draftFileName');
    final backup = File('${directory.path}/$_backupFileName');
    await _scrubLegacySsn(file);
    await _scrubLegacySsn(backup);
    for (final candidate in [file, backup]) {
      if (!await candidate.exists()) continue;
      try {
        final json = jsonDecode(await candidate.readAsString());
        final loaded = AiDriverRegistrationDraft.fromJson(
          json as Map<String, dynamic>,
        );
        final repaired = await _repairMissingDocuments(loaded, directory);
        if (candidate.path == backup.path || repaired != loaded) {
          await save(repaired);
        }
        return repaired;
      } catch (_) {
        // Try the atomic-write backup before treating the draft as absent.
      }
    }
    return null;
  }

  Future<void> _scrubLegacySsn(File file) async {
    if (!await file.exists()) return;
    String? raw;
    try {
      raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic> || !decoded.containsKey('ssn')) {
        return;
      }
      decoded.remove('ssn');
      await file.writeAsString(jsonEncode(decoded), flush: true);
    } catch (_) {
      if (raw != null && RegExp(r'"ssn"\s*:').hasMatch(raw)) {
        await file.delete();
      }
    }
  }

  Future<AiDriverRegistrationDraft> createFresh() async {
    final directory = await _draftDirectory();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
    final draft = AiDriverRegistrationDraft.create();
    await save(draft);
    return draft;
  }

  Future<void> save(AiDriverRegistrationDraft draft) async {
    final directory = await _draftDirectory();
    final file = File('${directory.path}/$_draftFileName');
    final temporary = File('${directory.path}/$_draftFileName.tmp');
    final backup = File('${directory.path}/$_backupFileName');

    await temporary.writeAsString(jsonEncode(draft.toJson()), flush: true);
    if (await backup.exists()) await backup.delete();
    if (await file.exists()) await file.rename(backup.path);
    try {
      await temporary.rename(file.path);
    } catch (_) {
      if (await backup.exists() && !await file.exists()) {
        await backup.rename(file.path);
      }
      rethrow;
    }
  }

  Future<String> retainDocument({
    required String draftId,
    required String documentId,
    required String sourcePath,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw const FileSystemException(
        'Selected document is no longer available',
      );
    }

    final directory = await _draftDirectory();
    final documents = Directory('${directory.path}/$draftId/documents');
    if (!await documents.exists()) {
      await documents.create(recursive: true);
    }

    final extension = _extensionOf(source.path);
    final destination = File(
      '${documents.path}/${documentId}_${DateTime.now().millisecondsSinceEpoch}$extension',
    );
    await source.copy(destination.path);
    return destination.path;
  }

  Future<void> deleteRetainedDocument(String? path) async {
    if (path == null || path.isEmpty) return;
    final directory = await _draftDirectory();
    final expectedRoot = '${directory.path}${Platform.pathSeparator}';
    if (!path.startsWith(expectedRoot)) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  Future<AiDriverRegistrationDraft> _repairMissingDocuments(
    AiDriverRegistrationDraft draft,
    Directory directory,
  ) async {
    var changed = false;
    final expectedRoot =
        '${directory.path}${Platform.pathSeparator}${draft.draftId}'
        '${Platform.pathSeparator}documents${Platform.pathSeparator}';
    final repaired = <AiDriverDocumentDraft>[];

    for (final document in draft.documents) {
      final path = document.localFilePath;
      final valid =
          path == null ||
          (path.startsWith(expectedRoot) && await File(path).exists());
      if (!valid) changed = true;
      repaired.add(valid ? document : document.withoutFile());
    }

    if (!changed) return draft;
    return draft.replaceDocuments(repaired);
  }

  String _extensionOf(String path) {
    final fileName = path.split(Platform.pathSeparator).last;
    final dot = fileName.lastIndexOf('.');
    return dot < 0 ? '' : fileName.substring(dot).toLowerCase();
  }
}

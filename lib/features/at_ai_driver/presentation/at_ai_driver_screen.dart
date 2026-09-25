import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/managers/permission_manager.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repository/app_repository.dart';
import '../../../models/responses/auth/country_response.dart';
import '../../../viewmodels/auth/register_viewmodel.dart';
import '../../../views/widgets/app_scaffold.dart';
import '../data/ai_driver_document_submission_gateway.dart';
import '../data/ai_driver_draft_store.dart';
import '../models/ai_driver_document_draft.dart';
import '../models/ai_driver_registration_draft.dart';

class AtAiDriverScreen extends StatefulWidget {
  final bool startFresh;
  final RegisterOrigin origin;
  final String? phoneNumber;
  final String? countryPhoneCode;
  final String? email;
  final List<Country> countries;
  final Country? selectedCountry;

  const AtAiDriverScreen({
    super.key,
    this.startFresh = false,
    this.origin = RegisterOrigin.phone,
    this.phoneNumber,
    this.countryPhoneCode,
    this.email,
    this.countries = const [],
    this.selectedCountry,
  });

  @override
  State<AtAiDriverScreen> createState() => _AtAiDriverScreenState();
}

class _AtAiDriverScreenState extends State<AtAiDriverScreen>
    with WidgetsBindingObserver {
  late final Future<AiDriverDraftStore> _storeFuture;
  final _imagePicker = ImagePicker();
  AiDriverRegistrationDraft? _draft;
  String? _busyDocumentId;
  String? _error;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _tlcController = TextEditingController();
  final _ssnController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _speech = SpeechToText();
  final _tts = FlutterTts();
  bool _listening = false;
  bool _stoppingVoice = false;
  bool _isResumed = true;
  int _voiceGeneration = 0;
  Future<void> _saveQueue = Future<void>.value();
  String _language = 'en';

  static const _aiPalette = AppColorPalette(
    colorBackground: Color(0xFF0E2438),
    colorPrimary: Color(0xFF39A9FF),
    colorSecondary: Color(0xFF37D6C8),
    colorTertiary: Color(0xFF2F80ED),
    colorWarning: Color(0xFFFFB547),
    colorText: Color(0xFFF7FAFC),
    colorSelectedText: Color(0xFFFFFFFF),
    colorButtonText: Color(0xFFFFFFFF),
    colorButtonBackground: Color(0xFF2F80ED),
    colorBackgroundGray: Color(0xFF173451),
  );

  static const _speechLocales = {
    'en': 'en_US',
    'ru': 'ru_RU',
    'es': 'es_ES',
    'hi': 'hi_IN',
    'ar': 'ar_SA',
    'zh': 'zh_CN',
    'tr': 'tr_TR',
    'ja': 'ja_JP',
  };

  static const _ttsLocales = {
    'en': 'en-US',
    'ru': 'ru-RU',
    'es': 'es-ES',
    'hi': 'hi-IN',
    'ar': 'ar-SA',
    'zh': 'zh-CN',
    'tr': 'tr-TR',
    'ja': 'ja-JP',
  };
  static const _stepIds = [
    'driver_license',
    'tlc_license',
    'tlc_number',
    'ssn',
    'phone',
    'email',
    'diamond_sticker',
    'vehicle_license',
    'inspection_registration',
    'insurance',
    'selfie',
  ];

  String get _activeId =>
      _stepIds[(_draft?.currentStepIndex.clamp(0, 10) ?? 0).toInt()];
  bool _isTextStep(String id) => const {
    'tlc_number',
    'ssn',
    'phone',
    'email',
    'vehicle_license',
  }.contains(id);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final identity = widget.origin == RegisterOrigin.email
        ? widget.email
        : '${widget.countryPhoneCode ?? ''}:${widget.phoneNumber ?? ''}';
    _storeFuture = AiDriverDraftStore.forRegistrationIdentity(identity ?? '');
    _configureTts();
    _loadDraft();
  }

  Future<void> _configureTts() async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage(_ttsLocales[_language] ?? 'en-US');
  }

  Future<void> _loadDraft() async {
    try {
      final store = await _storeFuture;
      final draft = widget.startFresh
          ? await store.createFresh()
          : await store.loadOrCreate();
      if (mounted) {
        _firstNameController.text = draft.firstName;
        _lastNameController.text = draft.lastName;
        _tlcController.text = draft.tlcNumber;
        _ssnController.clear();
        _vehicleController.text = draft.vehicleLicenseNumber;
        final normalizedDraft = draft.copyWith(
          phone: widget.phoneNumber ?? draft.phone,
          email: widget.email ?? draft.email,
          currentStepIndex: draft.currentStepIndex > 3
              ? 3
              : draft.currentStepIndex,
          completed: false,
        );
        _phoneController.text = normalizedDraft.phone;
        _emailController.text = normalizedDraft.email;
        _language = draft.language;
        await store.save(normalizedDraft);
        setState(() => _draft = normalizedDraft);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Your document checklist could not be opened.');
      }
    }
  }

  bool _activeComplete(AiDriverRegistrationDraft draft) {
    switch (_activeId) {
      case 'tlc_number':
        return draft.tlcNumber.trim().isNotEmpty;
      case 'ssn':
        return _isSsnComplete;
      case 'phone':
        return draft.phone.trim().isNotEmpty;
      case 'email':
        return draft.email.trim().isNotEmpty;
      case 'vehicle_license':
        return draft.vehicleLicenseNumber.trim().isNotEmpty;
      default:
        return draft.documents.any(
          (item) => item.id == _activeId && item.isCollected,
        );
    }
  }

  Future<void> _nextStep() async {
    final draft = _draft;
    if (draft == null || !_activeComplete(draft)) {
      if (mounted)
        setState(() => _error = 'Complete this step before continuing.');
      return;
    }
    await _stopVoice();
    if (draft.currentStepIndex >= _stepIds.length - 1) {
      await _saveDraft(draft.copyWith(completed: true, phase: 'complete'));
    } else {
      await _saveDraft(
        draft.copyWith(
          currentStepIndex: draft.currentStepIndex + 1,
          phase: 'working',
        ),
      );
    }
  }

  Future<void> _previousStep() async {
    final draft = _draft;
    if (draft == null || draft.currentStepIndex == 0) return;
    await _stopVoice();
    await _saveDraft(
      draft.copyWith(currentStepIndex: draft.currentStepIndex - 1),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isResumed = state == AppLifecycleState.resumed;
    if (!_isResumed) _stopVoice();
  }

  Future<void> _stopVoice() async {
    _voiceGeneration++;
    if (_stoppingVoice) return;
    _stoppingVoice = true;
    try {
      await _speech.cancel();
      await _tts.stop();
      if (mounted) setState(() => _listening = false);
    } finally {
      _stoppingVoice = false;
    }
  }

  Future<void> _toggleVoice() async {
    if (_listening) {
      await _stopVoice();
      return;
    }
    final generation = ++_voiceGeneration;
    bool canContinue() =>
        mounted && _isResumed && generation == _voiceGeneration;

    final permission = await PermissionManager.instance.requestMicrophone();
    if (!canContinue()) return;
    if (permission != PermissionResult.granted) {
      if (mounted)
        setState(
          () => _error = 'Microphone permission is required for voice input.',
        );
      return;
    }
    final initialized = await _speech.initialize(
      onError: (_) => _stopVoice(),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') _stopVoice();
      },
    );
    if (!canContinue()) return;
    if (!initialized) {
      if (mounted)
        setState(() => _error = 'Voice input is not available on this device.');
      return;
    }
    setState(() {
      _listening = true;
      _error = null;
    });
    await _tts.stop();
    if (!canContinue()) return;
    await _tts.setLanguage(_ttsLocales[_language] ?? 'en-US');
    if (!canContinue()) return;
    final isIntro = _draft?.phase == 'intro';
    final prompt = isIntro
        ? 'Please tell me your first and last name.'
        : _draft?.documents.firstWhere((item) => item.id == _activeId).title ??
              'Please answer the active registration step.';
    await _tts.speak(
      _language == 'ru' && isIntro
          ? 'Назовите ваше имя и фамилию.'
          : _language == 'ru'
          ? 'Ответьте на текущий шаг регистрации.'
          : prompt,
    );
    if (!canContinue() || !_listening) return;
    await _speech.listen(
      localeId: _speechLocales[_language] ?? 'en_US',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: false,
      onResult: (result) {
        if (generation != _voiceGeneration) return;
        if (!result.finalResult) return;
        final words = result.recognizedWords.trim();
        if (words.isEmpty || !mounted) return;
        final draft = _draft;
        if (draft == null) return;
        if (draft.phase == 'intro') {
          final parts = words.split(RegExp(r'\s+'));
          final first = parts.first;
          final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
          _firstNameController.text = first;
          _lastNameController.text = last;
          _saveDraft(draft.copyWith(firstName: first, lastName: last));
          return;
        }
        switch (_activeId) {
          case 'tlc_number':
            _tlcController.text = words;
            _saveDraft(draft.copyWith(tlcNumber: words));
          case 'phone':
            _phoneController.text = words;
            _saveDraft(draft.copyWith(phone: words));
          case 'email':
            _emailController.text = words;
            _saveDraft(draft.copyWith(email: words));
          case 'vehicle_license':
            _vehicleController.text = words;
            _saveDraft(draft.copyWith(vehicleLicenseNumber: words));
          case 'ssn':
            // SSN is never accepted from the microphone.
            break;
        }
      },
    );
  }

  Future<void> _speakActiveInstructions() async {
    final draft = _draft;
    if (draft == null) return;
    await _stopVoice();
    final step = draft.documents.firstWhere((item) => item.id == _activeId);
    await _tts.setLanguage(_ttsLocales[_language] ?? 'en-US');
    await _tts.speak('${step.title}. ${step.description}');
  }

  Future<void> _startGuide() async {
    final draft = _draft;
    if (draft == null) return;
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    if (firstName.length < 2 || lastName.length < 2) {
      setState(() => _error = 'Enter your first and last name to continue.');
      return;
    }
    await _stopVoice();
    await _saveDraft(
      draft.copyWith(
        firstName: firstName,
        lastName: lastName,
        language: _language,
        phase: 'working',
      ),
    );
  }

  Future<void> _saveDraft(AiDriverRegistrationDraft draft) async {
    if (mounted) setState(() => _draft = draft);
    _saveQueue = _saveQueue
        .then((_) async {
          final store = await _storeFuture;
          await store.save(draft);
        })
        .catchError((_) {
          if (mounted) {
            setState(
              () => _error = 'Your registration draft could not be saved.',
            );
          }
        });
    await _saveQueue;
  }

  bool get _isSsnComplete =>
      _ssnController.text.replaceAll(RegExp(r'\D'), '').length == 9;

  int _completedCount(AiDriverRegistrationDraft draft) =>
      draft.collectedCount + (_isSsnComplete ? 1 : 0);

  bool _allStepsComplete(AiDriverRegistrationDraft draft) =>
      draft.isComplete && _isSsnComplete;

  Future<void> _chooseSource(AiDriverDocumentDraft document) async {
    final source = await showModalBottomSheet<_DocumentSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, _DocumentSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose a photo'),
              onTap: () => Navigator.pop(context, _DocumentSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('Choose a PDF'),
              onTap: () => Navigator.pop(context, _DocumentSource.pdf),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    await _collectDocument(document, source);
  }

  Future<void> _collectDocument(
    AiDriverDocumentDraft document,
    _DocumentSource source,
  ) async {
    setState(() {
      _busyDocumentId = document.id;
      _error = null;
    });

    try {
      String? selectedPath;
      String? originalName;

      if (source == _DocumentSource.pdf) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: const ['pdf'],
        );
        selectedPath = result?.files.single.path;
        originalName = result?.files.single.name;
      } else {
        if (source == _DocumentSource.camera) {
          final permission = await PermissionManager.instance.requestCamera();
          if (permission != PermissionResult.granted) {
            throw StateError('Camera permission is required to take a photo.');
          }
        }
        final image = await _imagePicker.pickImage(
          source: source == _DocumentSource.camera
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1600,
          maxHeight: 1600,
          imageQuality: 88,
        );
        selectedPath = image?.path;
        originalName = image?.name;
      }

      if (selectedPath == null || _draft == null) return;
      final selectedFilePath = selectedPath;
      final selectedFile = File(selectedFilePath);
      if (!await selectedFile.exists()) {
        throw StateError('The selected document file is no longer available.');
      }

      if (source != _DocumentSource.pdf) {
        final approved = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Review photo'),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: SizedBox(
                width: 280,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 280,
                      height: 240,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          selectedFile,
                          width: 280,
                          height: 240,
                          fit: BoxFit.cover,
                          cacheWidth: 280,
                          cacheHeight: 240,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Make sure the document is clear and readable.'),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Retake'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Looks good'),
              ),
            ],
          ),
        );
        if (approved != true) return;
      }

      final store = await _storeFuture;
      final previousPath = document.localFilePath;
      try {
        final retainedPath = await store.retainDocument(
          draftId: _draft!.draftId,
          documentId: document.id,
          sourcePath: selectedFilePath,
        );
        final updated = _draft!.replaceDocument(
          document.copyWith(
            localFilePath: retainedPath,
            originalFileName: originalName,
            capturedAt: DateTime.now(),
          ),
        );
        await store.save(updated);
        await store.deleteRetainedDocument(previousPath);
        if (mounted) setState(() => _draft = updated);
      } catch (_) {
        await store.deleteRetainedDocument(previousPath);
        rethrow;
      }
    } on StateError catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'The document could not be saved. Try again.');
      }
    } finally {
      if (mounted) setState(() => _busyDocumentId = null);
    }
  }

  Future<void> _finish() async {
    final draft = _draft;
    if (draft == null) return;
    if (!_allStepsComplete(draft)) {
      if (mounted)
        setState(
          () => _error = 'Complete every onboarding step before continuing.',
        );
      return;
    }
    await _stopVoice();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm your registration'),
        content: Text(
          'Name: ${_firstNameController.text} ${_lastNameController.text}\n'
          'TLC number: ${draft.tlcNumber.isEmpty ? 'Not provided' : draft.tlcNumber}\n\n'
          'Your documents stay on this device and are not uploaded.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Review'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final repository = ProviderScope.containerOf(context, listen: false)
          .read(appRepositoryProvider);
      final gateway = AppRepositoryAiDriverDocumentSubmissionGateway(repository);
      await gateway.submit(draft);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is StateError
            ? error.message
            : 'The documents could not be sent for review. Please try again.');
      }
      return;
    }

    final updated = draft.copyWith(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phone: widget.phoneNumber,
      email: widget.email,
      language: _language,
    );
    await _saveDraft(updated);
    _ssnController.clear();
    await _saveDraft(
      updated.copyWith(currentStepIndex: 3, completed: false, phase: 'working'),
    );
    if (mounted) {
      context.navigateToRegisterFromAi(
        origin: widget.origin,
        countries: widget.countries,
        selectedCountry: widget.selectedCountry,
        phoneNumber: widget.phoneNumber,
        countryPhoneCode: widget.countryPhoneCode,
        email: widget.email,
        confirmedPrefill: ConfirmedRegistrationPrefill(
          firstName: updated.firstName,
          lastName: updated.lastName,
          phone: updated.phone,
          email: updated.email,
          drivingLicense: null,
        ),
      );
    }
  }

  Future<void> _registerManually() async {
    await _stopVoice();
    _ssnController.clear();
    final draft = _draft;
    if (draft != null && draft.currentStepIndex > 3) {
      await _saveDraft(
        draft.copyWith(currentStepIndex: 3, completed: false, phase: 'working'),
      );
    }
    if (!mounted) return;
    if (widget.origin == RegisterOrigin.phone) {
      context.navigateToRegisterPhone(
        phoneNumber: widget.phoneNumber ?? '',
        countryPhoneCode: widget.countryPhoneCode ?? '',
        countries: widget.countries,
        selectedCountry: widget.selectedCountry,
      );
    } else {
      context.navigateToRegisterEmail(
        email: widget.email ?? '',
        countries: widget.countries,
        selectedCountry: widget.selectedCountry,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isResumed = false;
    _voiceGeneration++;
    _speech.cancel();
    _tts.stop();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _tlcController.dispose();
    _ssnController.dispose();
    _vehicleController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Widget _buildActiveTextStep(AiDriverRegistrationDraft draft) {
    final id = _activeId;
    final controller = id == 'tlc_number'
        ? _tlcController
        : id == 'ssn'
        ? _ssnController
        : id == 'vehicle_license'
        ? _vehicleController
        : id == 'email'
        ? _emailController
        : _phoneController;
    return TextField(
      controller: controller,
      obscureText: id == 'ssn',
      keyboardType: id == 'ssn' || id == 'phone'
          ? TextInputType.phone
          : id == 'email'
          ? TextInputType.emailAddress
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: draft.documents.firstWhere((item) => item.id == id).title,
      ),
      onChanged: (value) {
        if (id == 'ssn') {
          setState(() {});
          return;
        }
        final updated = id == 'tlc_number'
            ? draft.copyWith(tlcNumber: value)
            : id == 'phone'
            ? draft.copyWith(phone: value)
            : id == 'email'
            ? draft.copyWith(email: value)
            : draft.copyWith(vehicleLicenseNumber: value);
        _saveDraft(updated);
      },
    );
  }

  Widget _buildActivePhotoStep(AiDriverRegistrationDraft draft) {
    final document = draft.documents.firstWhere((item) => item.id == _activeId);
    return _DocumentCard(
      document: document,
      busy: _busyDocumentId == document.id,
      onPressed: () => _chooseSource(document),
    );
  }

  @override
  Widget build(BuildContext context) {
    const colors = _aiPalette;
    final draft = _draft;
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E2438),
        extensions: const [AppThemeColors(palette: _aiPalette)],
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF39A9FF),
          brightness: Brightness.dark,
        ),
      ),
      child: WillPopScope(
        onWillPop: () async {
          await _stopVoice();
          _ssnController.clear();
          return true;
        },
        child: AppScaffold(
          body: SafeArea(
            child: draft == null
                ? Center(
                    child: _error == null
                        ? const CircularProgressIndicator()
                        : _ErrorState(message: _error!, onRetry: _loadDraft),
                  )
                : Column(
                    children: [
                      _Header(
                        collected: _completedCount(draft),
                        total: _stepIds.length,
                      ),
                      LinearProgressIndicator(
                        value: (draft.currentStepIndex + 1) / _stepIds.length,
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          children: [
                            _AssistantMessage(
                              text: draft.collectedCount == 0
                                  ? 'Your details were checked. I’ll guide you through registration and collect the documents needed for driver approval.'
                                  : 'Great. AT AI Driver has saved these documents locally and has not sent them anywhere.',
                            ),
                            const SizedBox(height: 16),
                            if (draft.phase == 'intro') ...[
                              TextField(
                                controller: _firstNameController,
                                decoration: const InputDecoration(
                                  labelText: 'First name',
                                ),
                                onChanged: (value) {
                                  if (_draft != null) {
                                    _saveDraft(
                                      _draft!.copyWith(firstName: value),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _lastNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Last name',
                                ),
                                onChanged: (value) {
                                  if (_draft != null) {
                                    _saveDraft(
                                      _draft!.copyWith(lastName: value),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: _language,
                                decoration: const InputDecoration(
                                  labelText: 'AI language',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'en',
                                    child: Text('🇺🇸 English'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ru',
                                    child: Text('🇷🇺 Русский'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'es',
                                    child: Text('🇪🇸 Español'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'hi',
                                    child: Text('🇮🇳 हिन्दी'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ar',
                                    child: Text('🇸🇦 العربية'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'zh',
                                    child: Text('🇨🇳 中文'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'tr',
                                    child: Text('🇹🇷 Türkçe'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ja',
                                    child: Text('🇯🇵 日本語'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null && _draft != null) {
                                    setState(() => _language = value);
                                    _saveDraft(
                                      _draft!.copyWith(language: value),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _toggleVoice,
                                icon: Icon(_listening ? Icons.stop : Icons.mic),
                                label: Text(
                                  _listening
                                      ? 'Stop listening'
                                      : 'Say your name',
                                ),
                              ),
                              const SizedBox(height: 8),
                              FilledButton(
                                onPressed: _startGuide,
                                child: const Text('Start with Voice Guide'),
                              ),
                            ] else ...[
                              Text(
                                'Step ${draft.currentStepIndex + 1} of ${_stepIds.length}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              _isTextStep(_activeId)
                                  ? _buildActiveTextStep(draft)
                                  : _buildActivePhotoStep(draft),
                              const SizedBox(height: 12),
                              if (_isTextStep(_activeId) && _activeId != 'ssn')
                                OutlinedButton.icon(
                                  onPressed: _toggleVoice,
                                  icon: Icon(
                                    _listening ? Icons.stop : Icons.mic,
                                  ),
                                  label: Text(
                                    _listening ? 'Stop listening' : 'Use voice',
                                  ),
                                )
                              else if (!_isTextStep(_activeId))
                                OutlinedButton.icon(
                                  onPressed: _speakActiveInstructions,
                                  icon: const Icon(Icons.volume_up_outlined),
                                  label: const Text('Hear instructions'),
                                )
                              else
                                const Text(
                                  'For your privacy, enter SSN manually.',
                                  textAlign: TextAlign.center,
                                ),
                            ],
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              _InlineError(message: _error!),
                            ],
                            TextButton(
                              onPressed: _registerManually,
                              child: const Text('Register manually instead'),
                            ),
                            if (draft.phase != 'intro' &&
                                draft.currentStepIndex > 0)
                              TextButton(
                                onPressed: _previousStep,
                                child: const Text('Back'),
                              ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                      if (draft.phase != 'intro')
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                          decoration: BoxDecoration(
                            color: colors.colorBackground,
                            border: Border(
                              top: BorderSide(
                                color: colors.colorText.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          child: SafeArea(
                            top: false,
                            child: SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _busyDocumentId == null
                                    ? (_allStepsComplete(draft)
                                          ? _finish
                                          : _nextStep)
                                    : null,
                                style: FilledButton.styleFrom(
                                  backgroundColor: colors.colorButtonBackground,
                                  foregroundColor: colors.colorButtonText,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: Text(
                                  _allStepsComplete(draft)
                                      ? 'Review and continue'
                                      : 'Next',
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

enum _DocumentSource { camera, gallery, pdf }

class _Header extends StatelessWidget {
  final int collected;
  final int total;

  const _Header({required this.collected, required this.total});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.colorPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.auto_awesome, color: colors.colorPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AT AI Driver',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text('$collected of $total documents collected'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantMessage extends StatelessWidget {
  final String text;

  const _AssistantMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.colorBackgroundGray,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Text(text, style: const TextStyle(height: 1.4)),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final AiDriverDocumentDraft document;
  final bool busy;
  final VoidCallback onPressed;

  const _DocumentCard({
    required this.document,
    required this.busy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Card(
      elevation: 0,
      color: colors.colorBackgroundGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: document.isCollected
              ? colors.colorSecondary
              : colors.colorText.withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              document.isCollected
                  ? Icons.check_circle
                  : Icons.description_outlined,
              color: document.isCollected
                  ? colors.colorSecondary
                  : colors.colorPrimary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    document.isCollected
                        ? document.originalFileName ?? 'Saved on this device'
                        : document.description,
                    style: TextStyle(
                      color: colors.colorText.withValues(alpha: 0.65),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            busy
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    onPressed: onPressed,
                    tooltip: document.isCollected ? 'Replace' : 'Add',
                    icon: Icon(
                      document.isCollected
                          ? Icons.refresh
                          : Icons.add_a_photo_outlined,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: const TextStyle(color: Colors.red)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 42),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

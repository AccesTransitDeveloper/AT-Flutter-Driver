import 'dart:convert';
import 'dart:io';

import 'package:driver/core/interceptors/base_url_interceptor.dart';
import 'package:driver/core/interceptors/header_interceptor.dart';
import 'package:driver/core/interceptors/logging_interceptor.dart';
import 'package:driver/core/preferences/shared_preference_manager.dart';
import 'package:driver/data/api/api_client.dart';
import 'package:driver/data/api/response_state.dart';
import 'package:driver/data/repository/app_repository.dart';
import 'package:driver/features/at_ai_driver/data/ai_driver_document_submission_gateway.dart';
import 'package:driver/features/at_ai_driver/models/ai_driver_document_draft.dart';
import 'package:driver/features/at_ai_driver/models/ai_driver_registration_draft.dart';
import 'package:driver/models/responses/document/document_response.dart';
import 'package:driver/viewmodels/auth/register_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class _CapturingMultipartClient extends http.BaseClient {
  http.MultipartRequest? lastRequest;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is http.MultipartRequest) {
      lastRequest = request;
    }

    final payload = jsonEncode({'documentStatus': 20});
    return http.StreamedResponse(
      Stream.value(utf8.encode(payload)),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('collects only document IDs that have a file to upload', () {
    final draft = AiDriverRegistrationDraft.create().copyWith(
      documents: [
        const AiDriverDocumentDraft(
          id: 'driver_license',
          title: 'Driver license',
          description: 'Front side',
          localFilePath: '/tmp/driver_license.jpg',
        ),
        const AiDriverDocumentDraft(
          id: 'email',
          title: 'Email',
          description: 'Email field',
        ),
        const AiDriverDocumentDraft(
          id: 'insurance',
          title: 'Insurance policy',
          description: 'Policy file',
          localFilePath: '/tmp/insurance.pdf',
        ),
      ],
    );

    expect(
      collectUploadableDocumentIds(draft),
      ['driver_license', 'insurance'],
    );
  });

  test('resolves server document IDs using backend metadata', () {
    final remoteDocuments = [
      Document(
        documentId: 'doc_driver_license_012',
        documentDetail: DocumentDetail(
          name: 'Driver License',
          title: 'Driver License',
        ),
      ),
      Document(
        documentId: 'doc_insurance_999',
        documentDetail: DocumentDetail(
          name: 'Insurance Policy',
          title: 'Insurance Policy',
        ),
      ),
    ];

    expect(
      resolveDocumentIdForAiDriver(
        localDocumentId: 'driver_license',
        remoteDocuments: remoteDocuments,
      ),
      'doc_driver_license_012',
    );

    expect(
      resolveDocumentIdForAiDriver(
        localDocumentId: 'insurance',
        remoteDocuments: remoteDocuments,
      ),
      'doc_insurance_999',
    );
  });

  test('prefers the server document id when uploading a document', () {
    final document = Document(
      documentId: 'server_doc_123',
      id: 'local_doc_456',
    );

    expect(resolveDocumentUploadId(document), 'server_doc_123');
  });

  test('builds a multipart document upload request with the imageUrl field name', () async {
    SharedPreferences.setMockInitialValues({});

    final sharedPref = await SharedPreferenceManager.create();
    final apiClient = ApiClient(
      BaseUrlInterceptor('https://example.com'),
      HeaderInterceptor(sharedPref),
      LoggingInterceptor(),
    );

    final tempDir = await Directory.systemTemp.createTemp('document_upload_test');
    final tempFile = File('${tempDir.path}/license.jpg');
    await tempFile.writeAsBytes([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

    final request = await apiClient.createMultipartRequest(
      'uploaded_document/server_doc_123',
      filePath: tempFile.path,
      fileFieldName: 'imageUrl',
      headers: {'Accept': 'application/json'},
      fields: {'expiryDate': '2030-01-01'},
    );

    expect(request.method, 'PUT');
    expect(request.url.path, endsWith('/uploaded_document/server_doc_123'));
    expect(request.files.single.field, 'imageUrl');
    expect(request.fields['expiryDate'], '2030-01-01');

    await tempFile.delete();
    await tempDir.delete();
  });

  test('skips the duplicate name step when AI-driver prefill already has a name', () async {
    SharedPreferences.setMockInitialValues({});
    final sharedPref = await SharedPreferenceManager.create();
    final repository = AppRepository(
      ApiClient(
        BaseUrlInterceptor('https://example.com'),
        HeaderInterceptor(sharedPref),
        LoggingInterceptor(),
      ),
    );

    final viewModel = RegisterViewModel(repository, sharedPref);
    viewModel.applyConfirmedPrefill(
      const ConfirmedRegistrationPrefill(
        firstName: 'John',
        lastName: 'Doe',
      ),
    );

    expect(viewModel.state.currentStep, RegisterStep.terms);
    expect(viewModel.state.firstName, 'John');
    expect(viewModel.state.lastName, 'Doe');
  });

  testWidgets('review photo dialog renders without intrinsic-width layout crash',
      (tester) async {
    final tempDir = await Directory.systemTemp.createTemp(
      'review_photo_dialog_test',
    );
    final imageFile = File('${tempDir.path}/review_photo.png');
    await imageFile.writeAsBytes([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x10,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0xF3, 0xFF,
      0xF3, 0x00, 0x00, 0x00, 0x06, 0x50, 0x4C, 0x54,
      0x45, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0xFF,
      0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0xFF, 0x00,
      0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
      0x42, 0x60, 0x82,
    ]);

    addTearDown(() async {
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog<void>(
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
                                    imageFile,
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
                },
                child: const Text('Open dialog'),
              );
            },
          ),
        ),
      ),
    );

    print('before open dialog tap');
    await tester.tap(find.text('Open dialog'));
    await tester.pump();
    print('after open dialog pump');

    expect(find.text('Review photo'), findsOneWidget);

    print('before looks good tap');
    await tester.tap(find.text('Looks good'));
    await tester.pump();
    print('after looks good pump');

    expect(find.text('Review photo'), findsNothing);
  });
}

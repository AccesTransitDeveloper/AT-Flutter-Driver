import 'ai_driver_document_draft.dart';

class AiDriverRegistrationDraft {
  final String draftId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool completed;
  final List<AiDriverDocumentDraft> documents;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String tlcNumber;
  final String vehicleLicenseNumber;
  final String language;
  final int currentStepIndex;
  final String phase;

  const AiDriverRegistrationDraft({
    required this.draftId,
    required this.createdAt,
    required this.updatedAt,
    required this.completed,
    required this.documents,
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.email = '',
    this.tlcNumber = '',
    this.vehicleLicenseNumber = '',
    this.language = 'en',
    this.currentStepIndex = 0,
    this.phase = 'intro',
  });

  factory AiDriverRegistrationDraft.create() {
    final now = DateTime.now();
    return AiDriverRegistrationDraft(
      draftId: now.microsecondsSinceEpoch.toString(),
      createdAt: now,
      updatedAt: now,
      completed: false,
      documents: const [
        AiDriverDocumentDraft(
          id: 'driver_license',
          title: 'Driver license',
          description: 'Front side, readable and without glare.',
        ),
        AiDriverDocumentDraft(
          id: 'tlc_license',
          title: 'TLC license',
          description: 'Your current TLC driver license.',
        ),
        AiDriverDocumentDraft(
          id: 'tlc_number',
          title: 'TLC license number',
          description: 'Enter your TLC license number.',
        ),
        AiDriverDocumentDraft(
          id: 'ssn',
          title: 'Social Security number',
          description: 'Enter your SSN. It stays on this device.',
        ),
        AiDriverDocumentDraft(
          id: 'phone',
          title: 'Phone number',
          description: 'Confirm the phone number for your account.',
        ),
        AiDriverDocumentDraft(
          id: 'email',
          title: 'Email address',
          description: 'Confirm the email address for your account.',
        ),
        AiDriverDocumentDraft(
          id: 'diamond_sticker',
          title: 'FHV diamond sticker',
          description: 'Take a clear photo of your sticker.',
        ),
        AiDriverDocumentDraft(
          id: 'vehicle_license',
          title: 'FHV vehicle license number',
          description: 'Enter the vehicle license number.',
        ),
        AiDriverDocumentDraft(
          id: 'inspection_registration',
          title: 'Inspection and registration',
          description: 'Take one clear photo of both documents.',
        ),
        AiDriverDocumentDraft(
          id: 'insurance',
          title: 'Insurance policy',
          description: 'Take a photo or choose the policy PDF.',
        ),
        AiDriverDocumentDraft(
          id: 'selfie',
          title: 'Selfie',
          description: 'Take a clear selfie for your application.',
        ),
      ],
    );
  }

  bool get _textComplete =>
      tlcNumber.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      vehicleLicenseNumber.trim().isNotEmpty;

  int get collectedCount {
    var count = documents.where((item) => item.isCollected).length;
    for (final id in const [
      'tlc_number',
      'phone',
      'email',
      'vehicle_license',
    ]) {
      if ((id == 'tlc_number' && tlcNumber.trim().isNotEmpty) ||
          (id == 'phone' && phone.trim().isNotEmpty) ||
          (id == 'email' && email.trim().isNotEmpty) ||
          (id == 'vehicle_license' && vehicleLicenseNumber.trim().isNotEmpty)) {
        count++;
      }
    }
    return count;
  }

  bool get isComplete =>
      firstName.trim().isNotEmpty &&
      lastName.trim().isNotEmpty &&
      _textComplete &&
      documents
          .where(
            (item) => !const [
              'tlc_number',
              'ssn',
              'phone',
              'email',
              'vehicle_license',
            ].contains(item.id),
          )
          .every((item) => item.isCollected);

  AiDriverRegistrationDraft copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? tlcNumber,
    String? vehicleLicenseNumber,
    String? language,
    int? currentStepIndex,
    String? phase,
    List<AiDriverDocumentDraft>? documents,
    bool? completed,
  }) => AiDriverRegistrationDraft(
    draftId: draftId,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
    completed: completed ?? this.completed,
    documents: documents ?? this.documents,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    tlcNumber: tlcNumber ?? this.tlcNumber,
    vehicleLicenseNumber: vehicleLicenseNumber ?? this.vehicleLicenseNumber,
    language: language ?? this.language,
    currentStepIndex: currentStepIndex ?? this.currentStepIndex,
    phase: phase ?? this.phase,
  );

  AiDriverRegistrationDraft replaceDocument(
    AiDriverDocumentDraft replacement,
  ) => copyWith(
    documents: documents
        .map((item) => item.id == replacement.id ? replacement : item)
        .toList(growable: false),
  );

  AiDriverRegistrationDraft replaceDocuments(
    List<AiDriverDocumentDraft> replacements,
  ) => copyWith(documents: replacements);

  AiDriverRegistrationDraft markCompleted() => copyWith(completed: true);

  Map<String, dynamic> toJson() => {
    'draftId': draftId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'completed': completed,
    'submissionStatus': 'notSubmitted',
    'networkDestination': null,
    'documents': documents.map((item) => item.toJson()).toList(),
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'email': email,
    'tlcNumber': tlcNumber,
    'vehicleLicenseNumber': vehicleLicenseNumber,
    'language': language,
    'currentStepIndex': currentStepIndex,
    'phase': phase,
  };

  factory AiDriverRegistrationDraft.fromJson(Map<String, dynamic> json) =>
      AiDriverRegistrationDraft(
        draftId: json['draftId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        completed: json['completed'] as bool? ?? false,
        documents: (json['documents'] as List<dynamic>)
            .map(
              (item) =>
                  AiDriverDocumentDraft.fromJson(item as Map<String, dynamic>),
            )
            .toList(growable: false),
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        tlcNumber: json['tlcNumber'] as String? ?? '',
        vehicleLicenseNumber: json['vehicleLicenseNumber'] as String? ?? '',
        language: json['language'] as String? ?? 'en',
        currentStepIndex: json['currentStepIndex'] as int? ?? 0,
        phase: json['phase'] as String? ?? 'intro',
      );
}

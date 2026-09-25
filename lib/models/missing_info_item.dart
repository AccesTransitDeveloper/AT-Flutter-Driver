/// Represents a single missing info action item shown on the home screen.
///
/// [id] maps to a navigation destination:
///   1 = documents, 2 = vehicles, 3 = vehicle documents,
///   4 = country, 5 = city, 6 = profile, 7 = availability,
///   8 = assessment, 9 = application form, 10 = ABN,
///   11 = select business, 12 = police check, 13 = additional terms
class MissingInfoItem {
  final int id;
  final String title;
  final String description;
  final bool isEnabled;
  final dynamic data;

  const MissingInfoItem({
    required this.id,
    required this.title,
    required this.description,
    this.isEnabled = true,
    this.data,
  });
}

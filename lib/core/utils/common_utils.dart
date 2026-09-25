/// Compares two semantic version strings (e.g. "1.2.3").
/// Returns < 0 if current < latest, 0 if equal, > 0 if current > latest.
int compareVersions(String currentVersion, String latestVersion) {
  try {
    final parts1 = currentVersion.split('.');
    final parts2 = latestVersion.split('.');

    final maxLength =
        parts1.length > parts2.length ? parts1.length : parts2.length;

    for (int i = 0; i < maxLength; i++) {
      final part1 = i < parts1.length ? int.parse(parts1[i]) : 0;
      final part2 = i < parts2.length ? int.parse(parts2[i]) : 0;

      if (part1 != part2) {
        return part1 - part2;
      }
    }
  } catch (_) {
    // Invalid version format — treat as equal
  }

  return 0;
}

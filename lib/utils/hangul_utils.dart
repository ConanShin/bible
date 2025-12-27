class HangulUtils {
  static const List<String> _chosungList = [
    'ㄱ',
    'ㄲ',
    'ㄴ',
    'ㄷ',
    'ㄸ',
    'ㄹ',
    'ㅁ',
    'ㅂ',
    'ㅃ',
    'ㅅ',
    'ㅆ',
    'ㅇ',
    'ㅈ',
    'ㅉ',
    'ㅊ',
    'ㅋ',
    'ㅌ',
    'ㅍ',
    'ㅎ',
  ];

  /// Extracts chosung (initial consonants) from a Korean string.
  /// Non-Korean characters are preserved as is.
  static String getChosung(String text) {
    String result = "";
    for (int i = 0; i < text.length; i++) {
      int code = text.codeUnitAt(i) - 44032;
      if (code >= 0 && code <= 11171) {
        result += _chosungList[code ~/ 588];
      } else {
        result += text[i];
      }
    }
    return result;
  }

  /// Checks if the [text] matches the [query] using both literal substring match
  /// and chosung match.
  static bool matches(String text, String query) {
    if (query.isEmpty) return true;
    String cleanText = text.toLowerCase();
    String cleanQuery = query.toLowerCase();

    // 1. Literal match
    if (cleanText.contains(cleanQuery)) return true;

    // 2. Chosung match
    String chosung = getChosung(text);
    if (chosung.contains(cleanQuery)) return true;

    return false;
  }
}

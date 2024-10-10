import 'package:intl/intl.dart';

const String defaultDateFormat = "yyyy.MM.dd";

String parseDate(String? dateStr) {
  return parseDateFormat(dateStr, defaultDateFormat);
}

String parseDateFormat(String? dateStr, String? dateFormat) {
  if (dateStr == null || dateStr.isEmpty) {
    return ''; // null이나 빈 값이면 빈 문자열 반환
  }

  if (dateFormat == null || dateFormat.isEmpty) {
    dateFormat = defaultDateFormat;
  }

  try {
    DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat(dateFormat).format(dateTime);
  } catch (e) {
    return ''; // 날짜 형식이 잘못된 경우 빈 문자열 반환
  }
}

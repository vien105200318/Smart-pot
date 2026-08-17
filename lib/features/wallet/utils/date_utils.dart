/// Key dạng `yyyy-MM-dd` dùng để gom quest theo ngày.
String todayKey() {
  final now = DateTime.now();
  final mm = now.month.toString().padLeft(2, '0');
  final dd = now.day.toString().padLeft(2, '0');
  return '${now.year}-$mm-$dd';
}

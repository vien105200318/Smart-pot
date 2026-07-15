// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get home => 'Trang chủ';

  @override
  String get devices => 'Thiết bị';

  @override
  String get camera => 'Camera AI';

  @override
  String get history => 'Lịch sử';

  @override
  String get settings => 'Cài đặt';

  @override
  String get soilMoisture => 'Độ ẩm đất';

  @override
  String get temperature => 'Nhiệt độ';

  @override
  String get airHumidity => 'Độ ẩm KK';

  @override
  String get waterTank => 'Mực nước';

  @override
  String get waterNow => 'Tưới ngay';

  @override
  String get watering => 'Đang tưới...';

  @override
  String get mistNow => 'Phun sương';

  @override
  String get misting => 'Đang phun...';

  @override
  String get online => 'Trực tuyến';

  @override
  String get offline => 'Mất kết nối';

  @override
  String get historyData => 'Dữ liệu Lịch sử';

  @override
  String get historyDesc => 'Theo dõi xu hướng môi trường theo thời gian.';

  @override
  String get filter1Day => '1 Ngày';

  @override
  String get filter1Week => '1 Tuần';

  @override
  String get filter1Month => '1 Tháng';

  @override
  String get filterAllTime => 'Tất cả';

  @override
  String get noDeviceConnected => 'Chưa có thiết bị nào được kết nối.';

  @override
  String get noData => 'Không có dữ liệu trong thời gian này.';

  @override
  String get airHumidChart => 'Độ ẩm KK (%)';

  @override
  String get soilMoistChart => 'Độ ẩm đất (%)';

  @override
  String get waterDurationChart => 'TG Tưới (phút)';

  @override
  String get recentActivities => 'Hoạt động gần đây';

  @override
  String get noRecentActivities => 'Không có hoạt động nào.';

  @override
  String get connectedDevices => 'Thiết bị kết nối';

  @override
  String get devicesDesc => 'Quản lý linh kiện phần cứng và cảm biến.';

  @override
  String get standby => 'Đang chờ';

  @override
  String get reading => 'Đang đọc';

  @override
  String get esp32Board => 'Mạch chủ ESP32';

  @override
  String get waterPumpRelay => 'Rơ-le Bơm nước';

  @override
  String get mistMaker => 'Máy phun sương';

  @override
  String get envSensors => 'Cảm biến môi trường';

  @override
  String syncError(String error) {
    return 'Lỗi đồng bộ: $error';
  }

  @override
  String get community => 'GreenVibe';

  @override
  String get communityDesc => 'Chia sẻ hành trình chăm cây của bạn.';

  @override
  String get newPost => 'Đăng bài';

  @override
  String get likes => 'Thích';

  @override
  String get comments => 'Bình luận';

  @override
  String get share => 'Chia sẻ';

  @override
  String get createPost => 'Tạo bài viết';

  @override
  String get whatsOnYourMind => 'Chậu cây của bạn hôm nay thế nào?';

  @override
  String get postBtn => 'Đăng';

  @override
  String get posting => 'Đang đăng...';
}

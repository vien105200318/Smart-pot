// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get devices => 'Devices';

  @override
  String get camera => 'Camera';

  @override
  String get history => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get soilMoisture => 'Soil Moisture';

  @override
  String get temperature => 'Temperature';

  @override
  String get airHumidity => 'Air Humidity';

  @override
  String get waterTank => 'Water Tank';

  @override
  String get waterNow => 'Water Now';

  @override
  String get watering => 'Watering...';

  @override
  String get mistNow => 'Mist Now';

  @override
  String get misting => 'Misting...';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get historyData => 'History Data';

  @override
  String get historyDesc => 'Monitor all environmental trends over time.';

  @override
  String get filter1Day => '1 Day';

  @override
  String get filter1Week => '1 Week';

  @override
  String get filter1Month => '1 Month';

  @override
  String get filterAllTime => 'All Time';

  @override
  String get noDeviceConnected => 'No devices connected.';

  @override
  String get noData => 'No data available for this period.';

  @override
  String get airHumidChart => 'Air Humidity (%)';

  @override
  String get soilMoistChart => 'Soil Moisture (%)';

  @override
  String get waterDurationChart => 'Watering Duration (mins)';

  @override
  String get recentActivities => 'Recent Activities';

  @override
  String get noRecentActivities => 'No recent activities.';

  @override
  String get connectedDevices => 'Connected Devices';

  @override
  String get devicesDesc => 'Manage your hardware components and sensors.';

  @override
  String get standby => 'Standby';

  @override
  String get reading => 'Reading';

  @override
  String get esp32Board => 'ESP32 Main Board';

  @override
  String get waterPumpRelay => 'Water Pump Relay';

  @override
  String get mistMaker => 'Ultrasonic Mist Maker';

  @override
  String get envSensors => 'Environment Sensors';

  @override
  String syncError(String error) {
    return 'Sync error: $error';
  }
}

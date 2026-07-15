// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get home => 'ホーム';

  @override
  String get devices => 'デバイス';

  @override
  String get camera => 'カメラ';

  @override
  String get history => '履歴';

  @override
  String get settings => '設定';

  @override
  String get soilMoisture => '土壌水分';

  @override
  String get temperature => '温度';

  @override
  String get airHumidity => '空気湿度';

  @override
  String get waterTank => '水位';

  @override
  String get waterNow => '水やり';

  @override
  String get watering => '水やり中...';

  @override
  String get mistNow => 'ミスト';

  @override
  String get misting => 'ミスト中...';

  @override
  String get online => 'オンライン';

  @override
  String get offline => 'オフライン';

  @override
  String get historyData => '履歴データ';

  @override
  String get historyDesc => '環境の傾向を監視します。';

  @override
  String get filter1Day => '1日';

  @override
  String get filter1Week => '1週間';

  @override
  String get filter1Month => '1ヶ月';

  @override
  String get filterAllTime => 'すべて';

  @override
  String get noDeviceConnected => 'デバイスが接続されていません。';

  @override
  String get noData => 'この期間のデータはありません。';

  @override
  String get airHumidChart => '空気湿度 (%)';

  @override
  String get soilMoistChart => '土壌水分 (%)';

  @override
  String get waterDurationChart => '水やり時間 (分)';

  @override
  String get recentActivities => '最近のアクティビティ';

  @override
  String get noRecentActivities => '最近のアクティビティはありません。';

  @override
  String get connectedDevices => '接続されたデバイス';

  @override
  String get devicesDesc => 'ハードウェアとセンサーを管理します。';

  @override
  String get standby => 'スタンバイ';

  @override
  String get reading => '読み取り中';

  @override
  String get esp32Board => 'ESP32メインボード';

  @override
  String get waterPumpRelay => '水ポンプリレー';

  @override
  String get mistMaker => '超音波ミストメーカー';

  @override
  String get envSensors => '環境センサー';

  @override
  String syncError(String error) {
    return '同期エラー: $error';
  }

  @override
  String get community => 'GreenVibe';

  @override
  String get communityDesc => '植物の成長をみんなと共有しましょう。';

  @override
  String get newPost => '投稿';

  @override
  String get likes => 'いいね';

  @override
  String get comments => 'コメント';

  @override
  String get share => '共有';

  @override
  String get createPost => '投稿を作成';

  @override
  String get whatsOnYourMind => '植物について何を考えていますか？';

  @override
  String get postBtn => '投稿';

  @override
  String get posting => '投稿中...';
}

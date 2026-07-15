import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('vi'),
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @soilMoisture.
  ///
  /// In en, this message translates to:
  /// **'Soil Moisture'**
  String get soilMoisture;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @airHumidity.
  ///
  /// In en, this message translates to:
  /// **'Air Humidity'**
  String get airHumidity;

  /// No description provided for @waterTank.
  ///
  /// In en, this message translates to:
  /// **'Water Tank'**
  String get waterTank;

  /// No description provided for @waterNow.
  ///
  /// In en, this message translates to:
  /// **'Water Now'**
  String get waterNow;

  /// No description provided for @watering.
  ///
  /// In en, this message translates to:
  /// **'Watering...'**
  String get watering;

  /// No description provided for @mistNow.
  ///
  /// In en, this message translates to:
  /// **'Mist Now'**
  String get mistNow;

  /// No description provided for @misting.
  ///
  /// In en, this message translates to:
  /// **'Misting...'**
  String get misting;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @historyData.
  ///
  /// In en, this message translates to:
  /// **'History Data'**
  String get historyData;

  /// No description provided for @historyDesc.
  ///
  /// In en, this message translates to:
  /// **'Monitor all environmental trends over time.'**
  String get historyDesc;

  /// No description provided for @filter1Day.
  ///
  /// In en, this message translates to:
  /// **'1 Day'**
  String get filter1Day;

  /// No description provided for @filter1Week.
  ///
  /// In en, this message translates to:
  /// **'1 Week'**
  String get filter1Week;

  /// No description provided for @filter1Month.
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get filter1Month;

  /// No description provided for @filterAllTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get filterAllTime;

  /// No description provided for @noDeviceConnected.
  ///
  /// In en, this message translates to:
  /// **'No devices connected.'**
  String get noDeviceConnected;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available for this period.'**
  String get noData;

  /// No description provided for @airHumidChart.
  ///
  /// In en, this message translates to:
  /// **'Air Humidity (%)'**
  String get airHumidChart;

  /// No description provided for @soilMoistChart.
  ///
  /// In en, this message translates to:
  /// **'Soil Moisture (%)'**
  String get soilMoistChart;

  /// No description provided for @waterDurationChart.
  ///
  /// In en, this message translates to:
  /// **'Watering Duration (mins)'**
  String get waterDurationChart;

  /// No description provided for @recentActivities.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities'**
  String get recentActivities;

  /// No description provided for @noRecentActivities.
  ///
  /// In en, this message translates to:
  /// **'No recent activities.'**
  String get noRecentActivities;

  /// No description provided for @connectedDevices.
  ///
  /// In en, this message translates to:
  /// **'Connected Devices'**
  String get connectedDevices;

  /// No description provided for @devicesDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your hardware components and sensors.'**
  String get devicesDesc;

  /// No description provided for @standby.
  ///
  /// In en, this message translates to:
  /// **'Standby'**
  String get standby;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get reading;

  /// No description provided for @esp32Board.
  ///
  /// In en, this message translates to:
  /// **'ESP32 Main Board'**
  String get esp32Board;

  /// No description provided for @waterPumpRelay.
  ///
  /// In en, this message translates to:
  /// **'Water Pump Relay'**
  String get waterPumpRelay;

  /// No description provided for @mistMaker.
  ///
  /// In en, this message translates to:
  /// **'Ultrasonic Mist Maker'**
  String get mistMaker;

  /// No description provided for @envSensors.
  ///
  /// In en, this message translates to:
  /// **'Environment Sensors'**
  String get envSensors;

  /// No description provided for @syncError.
  ///
  /// In en, this message translates to:
  /// **'Sync error: {error}'**
  String syncError(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

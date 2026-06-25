# 🌱 Smart Pot

A smart IoT plant monitoring and irrigation system built with **Flutter**, **Firebase**, and **ESP32**.

Monitor your plants in real-time, automate watering, control misting remotely, and receive notifications directly from your mobile device.

---

## Features

### Plant Monitoring

* Real-time temperature monitoring
* Real-time air humidity monitoring
* Real-time soil moisture monitoring
* Device online/offline status

### Remote Control

* Manual watering
* Manual misting
* Auto mode toggle

### Automation

* Automatic watering based on soil moisture threshold
* Automatic misting based on environmental conditions
* Local automation logic running on ESP32

### Mobile App

* Flutter (iOS first)
* Firebase Authentication
* Realtime Firestore synchronization
* Historical sensor charts
* Push notifications

---

## Hardware

### Controller

* ESP32

### Sensors

* DHT12 (Temperature & Humidity)
* Soil Moisture Sensor

### Actuators

* Water Valve
* Mist Sprayer
* MOSFET Drivers

### Future Expansion

* ESP32-CAM
* Water Tank Level Sensor
* Light Sensor
* Fertilizer Module

---

## Architecture

```text
Flutter App
      │
      ▼
 Firebase
(Auth + Firestore + FCM)
      │
      ▼
     ESP32
      │
 ┌─────────────┐
 │   DHT12     │
 │ Soil Sensor │
 │ Water Valve │
 │ Mist Spray  │
 └─────────────┘
```

---

## Tech Stack

### Mobile

* Flutter
* Riverpod
* GoRouter
* Freezed

### Backend

* Firebase Authentication
* Cloud Firestore
* Firebase Cloud Messaging

### Firmware

* ESP32
* Arduino Framework

### CI/CD

* GitHub Actions
* Firebase App Distribution
* Apple Enterprise Distribution

---

## Project Structure

```text
smart-pot/

├── app/
│   └── flutter/
│
├── firmware/
│   └── esp32/
│
├── docs/
│
└── .github/
    └── workflows/
```

---

## Firestore Structure

```text
devices
 └── pot_001
```

Example:

```json
{
  "name": "Balcony Pot",
  "online": true,
  "temperature": 31.5,
  "humidity": 68,
  "soilMoisture": 42,
  "watering": false,
  "misting": false,
  "autoMode": true
}
```

---

## Roadmap

### V1

* [x] Flutter App
* [x] Firebase Integration
* [x] ESP32 Integration
* [x] Real-time Monitoring
* [x] Manual Watering
* [x] Manual Misting
* [x] Auto Watering
* [x] Historical Charts
* [x] Push Notifications

### V1.5

* [ ] Camera Snapshot
* [ ] Multiple Plant Pots
* [ ] OTA Firmware Updates

### V2

* [ ] Plant Health Monitoring
* [ ] Advanced Scheduling
* [ ] Shared Device Access
* [ ] Web Dashboard

---

## Development Setup

### Flutter

```bash
flutter pub get
flutter run
```

### Firebase

```bash
flutterfire configure
```

### ESP32

```bash
pio run
pio run --target upload
```

---

## Goals

Build a reliable and scalable smart plant ecosystem starting with a single plant pot and expanding to multi-device smart garden management.

---

## License

MIT License


# <img src="https://github.com/vien105200318/Smart-pot/blob/main/assets/images/logo.png" width="40" height="40" align="center"> Smart Pot

A smart IoT plant monitoring and irrigation system built with **Flutter**, **Firebase**, **ESP32**, and automated by **Vercel**.

Monitor your plants in real time, automate watering, control misting remotely, and receive intelligent notifications directly on your mobile device.

---

# 🏗️ Architecture Overview

To maintain a cost-effective and scalable architecture, this project uses **Firebase** for real-time data storage and **Vercel Serverless Functions** for background monitoring and automated alerts, eliminating the need for a paid Firebase Blaze plan.

```text
Flutter App ◄──► Firebase (Auth + Firestore) ◄──► ESP32
                         │
                         ▼
             Vercel Cron Job (Serverless)
                         │
                         ▼
             Firebase Cloud Messaging (FCM)
```

---

# 🚀 Why Vercel for Notifications?

Instead of relying on Firebase Cloud Functions, this project utilizes **Vercel Cron Jobs**.

### 💰 Cost Efficiency

- Completely free
- No need to upgrade to Firebase Blaze Plan

### 🔧 Flexibility

- Decouples server-side monitoring logic from the database
- Easier maintenance and testing

### 🤖 Automation

- Vercel periodically polls Firestore
- Detects device offline events
- Sends push notifications through Firebase Cloud Messaging (FCM)

---

# ✨ Features

## 🌿 Plant Monitoring

- Real-time temperature
- Real-time air humidity
- Real-time soil moisture
- Device online/offline status tracking

## 💧 Remote Control & Automation

- Manual watering control
- Manual misting control
- Auto-mode switching
- Local automation logic running on ESP32

## 📱 Mobile App (Flutter)

- Riverpod (State Management)
- GoRouter (Navigation)
- Push notifications via Firebase Cloud Messaging (FCM)
- Notifications triggered by Vercel Cron Jobs

---

# 🛠 Tech Stack

## Mobile

- Flutter
- Riverpod
- GoRouter
- Freezed

## Backend & Automation

- Firebase Firestore (Realtime Database)
- Firebase Authentication
- Vercel Functions
- Firebase Cloud Messaging (FCM)

## Firmware

- ESP32 (Arduino Framework)

## DevOps

- GitHub Actions (CI/CD)
- Automated IPA Building

---

# 📂 Project Structure

```text
smart-pot/
├── app/            # Flutter source code
├── api/            # Vercel Serverless Functions (Node.js)
├── firmware/       # ESP32 firmware
├── .github/        # GitHub Actions workflows
└── vercel.json     # Vercel Cron Job configuration
```

---

# 🗄 Firestore Data Model

```json
{
  "name": "Balcony Pot",
  "isOnline": true,
  "temperature": 31.5,
  "soilMoisture": 42,
  "watering": false,
  "autoMode": true
}
```

---

# 🚀 Development Setup

## Flutter

```bash
flutter pub get
flutter run
```

## Vercel Backend

1. Generate a **Service Account Key** from Firebase Console.
2. Add it as an environment variable:

```text
FIREBASE_SERVICE_ACCOUNT
```

3. Deploy:

```bash
vercel --prod
```

## ESP32

```bash
pio run --target upload
```

---

# 🛣 Roadmap

## ✅ V1 (Current)

- [x] Real-time monitoring
- [x] Manual controls
- [x] Auto-watering logic
- [x] GitHub Actions CI/CD
- [x] Vercel-based notification system

## 🚧 V1.5

- [ ] Camera snapshot integration
- [ ] Multi-pot management

---

# 📄 License

This project is licensed under the **MIT License**.
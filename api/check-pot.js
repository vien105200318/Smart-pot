const admin = require('firebase-admin');

if (!admin.apps.length) {
  try {
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: "gemini-code-assitance-6c7b1"
    });
  } catch (err) {
    console.error("❌ Lỗi khởi tạo Firebase:", err.message);
    process.exit(1); 
  }
}

module.exports = async (req, res) => {
  try {
    const db = admin.firestore();
    const potsSnapshot = await db.collection('pots').get();
    
    if (potsSnapshot.empty) {
      return res.status(200).json({ status: 'ok', message: 'Không có thiết bị.' });
    }

    const results = []; 
    const now = Date.now();

    for (const doc of potsSnapshot.docs) {
      const data = doc.data();
      const potRef = doc.ref;

      // 1. TÍNH TOÁN ONLINE/OFFLINE TỰ ĐỘNG
      // Lấy timestamp từ Firebase (lastUpdated)
      const lastUpdated = data.lastUpdated ? data.lastUpdated.toMillis() : 0; 
      const timeDiffMinutes = (now - lastUpdated) / (1000 * 60);

      let currentStatus = data.isOnline;

      // Nếu quá 3 phút (theo khoảng gửi của ESP32) mà không có data -> Ép Offline
      if (timeDiffMinutes > 3 && data.isOnline === true) {
        await potRef.update({ isOnline: false });
        currentStatus = false;
        results.push(`${doc.id}: Đã chuyển sang OFFLINE (timeout)`);
      } 
      // Nếu có data mới -> Ép Online
      else if (timeDiffMinutes <= 3 && data.isOnline === false) {
        await potRef.update({ isOnline: true });
        currentStatus = true;
        results.push(`${doc.id}: Đã chuyển sang ONLINE`);
      }

      // 2. GỬI NOTIFICATION (Chỉ gửi khi có sự thay đổi trạng thái)
      // Cảnh báo Offline
      if (currentStatus === false && data.alertSent !== true) {
        await admin.messaging().send({
          notification: { title: '⚠️ Smart Pot mất kết nối', body: `Thiết bị ${data.deviceId || doc.id} đã offline!` },
          topic: 'all_users'
        });
        await potRef.update({ alertSent: true });
      } 
      // Thông báo Online lại
      else if (currentStatus === true && data.alertSent === true) {
        await admin.messaging().send({
          notification: { title: '✅ Smart Pot đã Online', body: `Thiết bị ${data.deviceId || doc.id} đã kết nối lại.` },
          topic: 'all_users'
        });
        await potRef.update({ alertSent: false });
      }
    }
    
    return res.status(200).json({ status: 'success', details: results });
    
  } catch (error) {
    return res.status(500).json({ status: 'error', message: error.message });
  }
};
const admin = require('firebase-admin');

// Khởi tạo Admin SDK
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
  // Thêm một lớp bảo mật đơn giản: chỉ cho phép gọi bằng khóa bí mật (nếu muốn)
  // Ví dụ: const secret = req.headers['x-cron-secret'];
  
  try {
    const db = admin.firestore();
    const potsSnapshot = await db.collection('pots').get();
    
    if (potsSnapshot.empty) {
      return res.status(200).send('Không có thiết bị.');
    }

    const results = []; // Để theo dõi kết quả

    for (const doc of potsSnapshot.docs) {
      const data = doc.data();
      const potRef = doc.ref;

      if (data.hasOwnProperty('isOnline')) {
        // Xử lý Offline
        if (data.isOnline === false && data.alertSent !== true) {
          await admin.messaging().send({
            notification: { 
              title: '⚠️ Cảnh báo Smart Pot', 
              body: `Thiết bị ${data.deviceId || doc.id} đã mất kết nối!` 
            },
            topic: 'all_users'
          });
          await potRef.update({ alertSent: true });
          results.push(`${doc.id}: Đã gửi cảnh báo Offline`);
        } 
        // Xử lý Online
        else if (data.isOnline === true && data.alertSent === true) {
          await admin.messaging().send({
            notification: { 
              title: '✅ Smart Pot đã Online', 
              body: `Thiết bị ${data.deviceId || doc.id} đã kết nối lại.` 
            },
            topic: 'all_users'
          });
          await potRef.update({ alertSent: false });
          results.push(`${doc.id}: Đã gửi thông báo Online`);
        }
      }
    }
    
    return res.status(200).json({ status: 'success', details: results });
    
  } catch (error) {
    console.error("❌ Lỗi Cron Job:", error);
    return res.status(500).json({ error: error.message });
  }
};
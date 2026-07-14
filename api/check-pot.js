const admin = require('firebase-admin');

// Khởi tạo Admin SDK
if (!admin.apps.length) {
  try {
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: "gemini-code-assitance-6c7b1"
    });
    console.log("✅ Firebase Admin khởi tạo thành công!");
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
      return res.status(200).json({ status: 'ok', message: 'Không có thiết bị nào trong hệ thống.' });
    }

    const results = []; 

    for (const doc of potsSnapshot.docs) {
      const data = doc.data();
      const potRef = doc.ref;

      // Chỉ xử lý nếu document có trường isOnline
      if (data.hasOwnProperty('isOnline')) {
        
        // Kịch bản 1: Thiết bị OFFLINE
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
        
        // Kịch bản 2: Thiết bị ONLINE trở lại
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
        
        // Thiết bị bình thường
        else {
          results.push(`${doc.id}: Bình thường (Online: ${data.isOnline})`);
        }
      }
    }
    
    // Trả về JSON để nhìn cho chuyên nghiệp và dễ debug
    return res.status(200).json({ 
      status: 'success', 
      checked_count: potsSnapshot.size,
      details: results 
    });
    
  } catch (error) {
    console.error("❌ Lỗi hệ thống:", error);
    return res.status(500).json({ 
      status: 'error', 
      message: error.message,
      stack: error.stack
    });
  }
};
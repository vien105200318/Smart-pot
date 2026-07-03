const admin = require('firebase-admin');

if (!admin.apps.length) {
  const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

module.exports = async (req, res) => {
  const db = admin.firestore();
  
  // Lưu ý: Vẫn giữ nguyên collection là 'pots' của bạn
  const potRef = db.collection('pots').doc('pot_001');
  const doc = await potRef.get();
  
  if (doc.exists) {
    const data = doc.data();
    
    // KỊCH BẢN 1: THIẾT BỊ OFFLINE
    if (data.isOnline === false && data.alertSent !== true) {
      const messageOffline = {
        notification: { 
          title: '⚠️ Cảnh báo Smart Pot', 
          body: 'Cây của bạn đã mất kết nối! Kiểm tra nguồn điện ngay.' 
        },
        topic: 'all_users'
      };
      
      await admin.messaging().send(messageOffline);
      await potRef.update({ alertSent: true }); // Khóa cờ lại
      return res.status(200).send('Đã gửi thông báo OFFLINE!');
    } 
    
    // KỊCH BẢN 2: THIẾT BỊ ONLINE TRỞ LẠI
    if (data.isOnline === true && data.alertSent === true) {
      const messageOnline = {
        notification: { 
          title: '✅ Smart Pot đã Online', 
          body: 'Thiết bị đã được cấp điện và kết nối lại thành công.' 
        },
        topic: 'all_users'
      };
      
      await admin.messaging().send(messageOnline);
      await potRef.update({ alertSent: false }); // Mở cờ ra cho lần sau
      return res.status(200).send('Đã gửi thông báo ONLINE!');
    }

    // KỊCH BẢN 3: ĐANG BÌNH THƯỜNG (Không có gì thay đổi)
    return res.status(200).send('Trạng thái bình thường. Không cần gửi Noti.');
  }
  
  return res.status(404).send('Không tìm thấy thiết bị.');
};
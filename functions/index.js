const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
admin.initializeApp();

exports.watchDeviceStatus = onDocumentUpdated("pots/{potId}", (event) => {
    const newData = event.data.after.data();
    const previousData = event.data.before.data();

    // Nếu trạng thái thay đổi từ true (Online) sang false (Offline)
    if (previousData.isOnline === true && newData.isOnline === false) {
        const message = {
            notification: {
                title: "Cảnh báo khẩn cấp! 🔴",
                body: "Thiết bị ESP32 đã mất kết nối mạng."
            },
            topic: "alerts" // App sẽ lắng nghe topic này
        };
        return admin.messaging().send(message);
    }
    return null;
});
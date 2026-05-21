const { setGlobalOptions } = require("firebase-functions/v2");
const { onRequest, onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const apn = require("apn");
const path = require("path"); // Перенесено вгору

// Налаштування лімітів інстансів
setGlobalOptions({ maxInstances: 10 });

// Ініціалізація Firebase Admin SDK
admin.initializeApp();

// Підключаємо Agora генератор токенів
const { RtcTokenBuilder, RtcRole } = require("agora-token");
const agoraKeys = require("./stream-keys.json");

// Ініціалізація APNs провайдера для надсилання VoIP-пушів
const apnProvider = new apn.Provider({
  token: {
	 key: path.join(__dirname, "AuthKey_MG47F4PMJ2.p8"),
	 keyId: "MG47F4PMJ2",
	 teamId: "WU276H25JQ"
  },
  production: false
});

// -------------------------------------------------------------------------
// NEW FUNCTION: Generates a secure JWT token for Agora RTC
// -------------------------------------------------------------------------
exports.getAgoraToken = onRequest({ region: "europe-central2" }, async (req, res) => {
  try {
	 const channelName = req.query.channelName;
	 const uid = req.query.uid ? Number(req.query.uid) : 0;
	 
	 if (!channelName) {
		res.status(400).send("Missing channelName parameter.");
		return;
	 }
	 
	 const appId = agoraKeys.agoraAppId;
	 const appCertificate = agoraKeys.agoraAppCertificate;
	 
	 const role = RtcRole.PUBLISHER;
	 
	 const tokenExpirationInSecond = 3600;
	 const privilegeExpirationInSecond = 3600;
	 
	 const token = RtcTokenBuilder.buildTokenWithUid(
																	 appId,
																	 appCertificate,
																	 channelName,
																	 uid,
																	 role,
																	 tokenExpirationInSecond,
																	 privilegeExpirationInSecond
																	 );
	 
	 res.status(200).json({ token: token });
	 
  } catch (error) {
	 console.error("Error generating Agora token:", error);
	 res.status(500).send("Internal Server Error");
  }
});

// -------------------------------------------------------------------------
// NOTIFICATION FUNCTION: Sends push notifications when a new message arrives
// -------------------------------------------------------------------------
exports.sendChatNotification = onDocumentCreated("chats/{chatId}/messages/{messageId}", async (event) => {
  const messageData = event.data.data();
  if (!messageData) {
	 console.log("New message data is empty.");
	 return;
  }
  
  const text = messageData.text || "Message";
  let senderName = messageData.senderName || "New Message";
  const senderId = messageData.senderId;
  const chatId = event.params.chatId;
  
  try {
	 // 1. Fetch the chat document to get user previews
	 const chatDoc = await admin.firestore().collection("chats").doc(chatId).get();
	 
	 if (!chatDoc.exists) {
		console.log(`Chat with ID ${chatId} not found.`);
		return;
	 }
	 
	 const chatData = chatDoc.data();
	 const userPreviews = chatData.userPreviews || [];
	 
	 // 2. Identify sender and receiver from userPreviews
	 const receiver = userPreviews.find(user => user.id !== senderId);
	 const sender = userPreviews.find(user => user.id == senderId);
	 
	 if (sender) {
		senderName = sender.nickname || "New Message";
	 }
	 
	 if (!receiver) {
		console.log("Could not determine the message receiver.");
		return;
	 }
	 
	 const receiverId = receiver.id;
	 
	 // 3. Fetch the receiver's FCM token from Users collection
	 const userDoc = await admin.firestore().collection("Users").doc(receiverId).get();
	 
	 if (!userDoc.exists) {
		console.log(`User ${receiverId} not found in Users collection.`);
		return;
	 }
	 
	 const fcmToken = userDoc.data().fcmToken;
	 
	 if (!fcmToken || fcmToken === "") {
		console.log(`User ${receiverId} does not have an active fcmToken.`);
		return;
	 }
	 
	 // 4. Construct the APNs payload without the badge parameter
	 const payload = {
		token: fcmToken,
		notification: {
		  title: senderName,
		  body: text
		},
		data: {
		  chatID: chatId
		},
		apns: {
		  payload: {
			 aps: {
				sound: "default"
			 }
		  }
		}
	 };
	 
	 // 5. Send the push notification via Firebase Messaging
	 const response = await admin.messaging().send(payload);
	 console.log("Push notification successfully sent! Message ID:", response);
	 console.log("Push notification successfully sent! chat ID:", chatId);
	 
  } catch (error) {
	 console.error("An error occurred while processing the push notification:", error);
  }
});

// -------------------------------------------------------------------------
// VOIP CALL FUNCTION: Triggers a high-priority VoIP push for CallKit
// -------------------------------------------------------------------------
exports.triggerVoIPCall = onCall({ region: "europe-central2" }, async (request) => {
  if (!request.auth) {
	 throw new HttpsError("unauthenticated", "Користувач повинен бути авторизований.");
  }
  
  const chatId = request.data.chatId;
  const receiverId = request.data.receiverId;
  const callerName = request.data.callerName || "Вхідний виклик";
  
  if (!chatId || !receiverId) {
	 throw new HttpsError("invalid-argument", "Відсутні обов'язкові параметри chatId або receiverId.");
  }
  
  try {
	 // 1. Fetch the receiver's document from Users collection
	 const userDoc = await admin.firestore().collection("Users").doc(receiverId).get();
	 
	 if (!userDoc.exists) {
		throw new HttpsError("not-found", "Отримувача не знайдено в базі даних.");
	 }
	 
	 // 2. Extract the unique VoIP token
	 const voipToken = userDoc.data().voipToken;
	 if (!voipToken || voipToken === "") {
		throw new HttpsError("failed-precondition", "У користувача немає активного VoIP токена.");
	 }
	 
	 // 3. Construct the high-priority APNs VoIP notification
	 const note = new apn.Notification();
	 note.expiry = 0;
	 note.priority = 10;
	 
	 note.topic = "hiroio.ChatBook.voip";
	 
	 note.payload = {
		chatId: chatId,
		callerName: callerName
	 };
	 
	 // 4. Send the VoIP push notification via Apple APNs
	 const result = await apnProvider.send(note, voipToken);
	 
	 // 5. Verify delivery results and handle errors
	 if (result.failed.length > 0) {
		console.error("APNs delivery failure response:", result.failed[0].response);
		return { success: false, error: "APNs відхилив токен" };
	 }
	 console.log("VoIP push notification successfully sent! Receiver ID:", receiverId);
	 console.log("VoIP push notification successfully sent! Chat ID:", chatId);
	 return { success: true };
  } catch (error) {
	 console.error("An error occurred while processing the VoIP notification:", error);
	 throw new HttpsError("internal", error.message);
  }
});

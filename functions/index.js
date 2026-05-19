/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

// Ініціалізація сервера
admin.initializeApp();

// Функція тригериться, коли в підколекцію messages будь-якого чату додається новий документ
exports.sendChatNotification = onDocumentCreated("chats/{chatId}/messages/{messageId}", async (event) => {
	 const messageData = event.data.data();
	 if (!messageData) {
		  console.log("Дані нового повідомлення пусті.");
		  return;
	 }

	 // Припускаємо, що у вашому документі повідомлення є ці поля:
	 const text = messageData.text || "Message";
	 const senderName = messageData.senderName || "New Message";
	 const senderId = messageData.senderId;
	 const chatId = event.params.chatId;

	 try {
		  // 1. Оскільки пуш треба надіслати ОТРИМУВАЧУ, а не тому, хто написав,
		  // ми дістаємо головний документ чату, щоб подивитися, які юзери там є в "userPreviews"
		  const chatDoc = await admin.firestore().collection("chats").doc(chatId).get();
		  
		  if (!chatDoc.exists) {
				console.log(`Чат ${chatId} не знайдено.`);
				return;
		  }

		  const chatData = chatDoc.data();
		  const userPreviews = chatData.userPreviews || [];

		  // 2. Шукаємо в масиві userPreviews того користувача, чий ID НЕ збігається з senderId (це і є наш отримувач)
		  const receiver = userPreviews.find(user => user.id !== senderId);

		  if (!receiver) {
				console.log("Не вдалося визначити отримувача повідомлення (receiver).");
				return;
		  }

		  const receiverId = receiver.id;

		  // 3. Тепер ідемо в колекцію користувачів за токеном отримувача
		  const userDoc = await admin.firestore().collection("Users").doc(receiverId).get();
		  
		  if (!userDoc.exists) {
				console.log(`Користувача ${receiverId} не знайдено в колекції users.`);
				return;
		  }

		  const fcmToken = userDoc.data().fcmToken;

		  if (!fcmToken || fcmToken === "") {
				console.log(`У користувача ${receiverId} немає активного fcmToken.`);
				return;
		  }

		  // 4. Формуємо пуш-пакет для Apple пристроїв
		  const payload = {
				token: fcmToken,
				notification: {
					 title: senderName,
					 body: text
				},
				data: {
					 chatID: chatId // Передаємо для вашого майбутнього NavigationManager TODO
				},
				apns: {
					 payload: {
						  aps: {
								sound: "default",
								badge: 1
						  }
					 }
				}
		  };

		  // 5. Відправка
		  const response = await admin.messaging().send(payload);
		  console.log("Пуш успішно відправлено через Cloud Functions! ID:", response);

	 } catch (error) {
		  console.error("Сталася помилка при обробці пуша:", error);
	 }
});

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_fcm/NotificationService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  NotificationService notification = NotificationService();
  notification.initialize();

  // Firebaseアプリを初期化
  await Firebase.initializeApp();

  // FCMトークンの取得
  FirebaseMessaging.instance.getToken().then((token) {
    print('FCM Token: $token');
  });

  // フォアグラウンドでのメッセージ受信時の処理
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received foreground message: ${message.notification!.title}');
    print('Received foreground message: ${message.notification!.body}');
    // プッシュ通知の表示など、受信したメッセージに対する処理を実装する
    notification.showNotification(message);
  });

  // バックグラウンドまたは終了時のメッセージ受信時の処理
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

  runApp(const MyApp());
}

Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  NotificationService notification = NotificationService();
  notification.initialize();
  // バックグラウンドでのメッセージをここで処理します
  print('A background message was received: ${message.messageId}');
  notification.showNotification(message);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  NotificationService notification = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ローカルプッシュ通知テスト'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                notification.showNotificationTest(); // 通知をすぐに表示
              },
              child: const Text('すぐに通知を表示'),
            ),
          ],
        ),
      ),
    );
  }
}

# IOS Push 通知 の実装方法

## Firebase でやること

- firebase 登録
- プロジェクト作成
- アプリ作成
- プロジェクトの設定 > Apple アプリ > GoogleService-Info.plist をダウンロード (ios\runner に設置用)
- Add Firebase SDK :
  - Xcode で, open Flutter project\ios
  - Mac navigate bar > File > Add Packages > https://github.com/firebase/firebase-ios-sdk
  - Choose the Firebase libraries that you want to use (FirebaseAnalytics, FirebaseMessaging をダウンロード )
- Add initialization code in project\ios\runner\AppDelegate.swift

```
import SwiftUI
import FirebaseCore //追加

class AppDelegate: NSObject, UIApplicationDelegate {
 func application(_ application: UIApplication,
                  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

   FirebaseApp.configure()   //追加

   return true
 }

```

- Upload APNs key for firebase projects

## Flutter project\ios でやること

- Flutter プロジェクト\ios\runner に GoogleService-Info.plist を設置。

- Register for remote notification in ios\runner\AppDelegate.swift

```
import UIKit
import Flutter
import SwiftUI
import FirebaseCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
   override func application(
       _ application: UIApplication,
       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
   ) -> Bool {
       // Use Firebase library to configure APIs
       FirebaseApp.configure()

       // ここから追加


       if #available(iOS 10.0, *) {
           // For iOS 10 display notification (sent via APNS)
           UNUserNotificationCenter.current().delegate = self
           let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
           UNUserNotificationCenter.current().requestAuthorization(
               options: authOptions,
               completionHandler: { _, _ in }
           )
       } else {
           let settings: UIUserNotificationSettings =
           UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
           application.registerUserNotificationSettings(settings)
       }
       application.registerForRemoteNotifications()

       GeneratedPluginRegistrant.register(with: self)
       return super.application(application, didFinishLaunchingWithOptions: launchOptions)

          // ここまで追加
   }
}

```

## lib/main.dart の編集

```
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  // Firebaseアプリを初期化
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // FCMトークンの取得
  FirebaseMessaging.instance.getToken().then((token) {
    print('FCM Token: $token');
  });

  // フォアグラウンドでのメッセージ受信時の処理
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received foreground message: ${message.notification!.body}');
    // プッシュ通知の表示など、受信したメッセージに対する処理を実装する
  });

  // バックグラウンドまたは終了時のメッセージ受信時の処理
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}
```

## 発生エラー

```

1. Module ‘firebase_core’ not found
install cocoapods and run
npx pod-install ios
2. Metal API Validation Enabled
-> Scheme > Edit Scheme... > Run > Diagnostics > uncheck Metal API Validation.
3. Could not locate configuration file: ‘GoogleService-Info.plist’.
add GoogleService-Info.plist’ in Xcode/project folder/Runner
4. BUNDLE_ID
-> edit the BUNDLE_ID to the same with BUNDLE_ID in GoogleService-Info.plist file
5. fopen failed for data file
-> Mac nav bar -> Product -> Clean Build Folder
6. FIRMessaging Remote Notifications proxy enabled, will swizzle remote notification receiver handlers. If you’d prefer to manually integrate Firebase Messaging, add “FirebaseAppDelegateProxyEnabled” to your Info.plist, and set it to NO. Follow the instructions at:
-> Xcode-> project -> Info -> Information Property List -> click + to add FirebaseAppDelegateProxyEnabled - Boolean - Yes
7. aps-environment’ entitlement string found for application
-> SET push notification va background mode
In Xcode Project\runner -> target\runner -> singing & capabilities tab -> click + icon to add push notification va background mode
8. redefinition of module ‘Firebase’
runner - project -> runner -> package Dependencies -> remove firebase ios sdk

........
```

# 動作確認

- Flutter 起動して、コンソールから FCM Token を取得

- FCM トークンをはりつけて、Laravel プロジェクトでコマンドを実行

- Flutter コンソールで Push 通知が届いているのを確認

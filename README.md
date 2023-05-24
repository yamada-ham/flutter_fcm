---
title: Laravel & Flutter で FCM を利用した Push通知 の実装方法
tags: Firebase FirebaseCloudMessaging プッシュ通知 Push通知 Flutter
author: ymd_a
slide: false
---
# Firebaseでやること
- firebase 登録
- プロジェクト作成
- アプリ作成
- プロジェクトの設定 > アプリ > google-services.json をダウンロード (フロントアプリに設置用)
- プロジェクトの設定 > サービスアカウント > 新しい秘密鍵の作成 > xxxxx-firebase-adminsdk.json をダウンロード (サーバーサイドに設置用)

# Flutterでやること
- Flutterプロジェクトにgoogle-services.jsonを設置。
プロジェクト/android/app/google-services.json

- Flutterの編集
-pubspec.yaml の編集
firebase_messaging:
firebase_core:
のを導入
```
dependencies:
  flutter:
    sdk: flutter
  firebase_messaging:
  firebase_core:
```

- android/build.gradle の編集
```
dependencies {
    classpath 'com.google.gms:google-services:4.3.8' // 追加 バージョンが適宜変更
}
```

- android/app/build.gradle の編集
```
apply plugin: 'com.google.gms.google-services' // 最終行に追加
```

- minSdkVersionでエラーが出た場合の対処 android/app/build.gradleの編集
```
// minSdkVersion flutter.minSdkVersion
minSdkVersion 21
```

- lib/main.dart の編集
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

※ applicationId は FCMで設定したアプリケーション名と同じにすること

# サーバーサイド Laravelでやること
- google-services.json の設置
storage/private/google-services.json

- app/Console/Commands/TestPushCommand.php 作成して編集
```
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Kreait\Firebase\Factory;
use Kreait\Firebase\ServiceAccount;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Kreait\Firebase\Messaging\WebPushConfig;
use Illuminate\Support\Facades\Storage;

class TestPushCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'command:test_push {registration_token}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command description';

    /**
     * Create a new command instance.
     *
     * @return void
     */
    public function __construct()
    {
        parent::__construct();
    }

    /**
     * Execute the console command.
     *
     * @return int
     */
    public function handle()
    {
        $path = "daisouya-firebase-adminsdk.json";
        // $path = "google-services.json";
        $is_path = Storage::disk('private')->exists($path);
        if ($is_path) {
            $path_firebase_json = Storage::disk('private')->path($path);
        }
        $registrationToken = $this->argument('registration_token');
        $factory = (new Factory)->withServiceAccount($path_firebase_json);
        $messaging = $factory->createMessaging();

        $notification = Notification::fromArray([
            'title' => 'Pushテスト Title Hello',
            'body' => 'Pushテスト Body Hello!',
        ]);

        $message = CloudMessage::withTarget('token', $registrationToken)
            ->withNotification($notification);

        $messaging->send($message);

        return 0;
    }
}
```

# 動作確認
- Flutter起動して、コンソールからFCM Tokenを取得

- FCMトークンをはりつけて、Laravelプロジェクトでコマンドを実行
```
php artisan command:test_push FCMトークン
```
- FlutterコンソールでPush通知が届いているのを確認 
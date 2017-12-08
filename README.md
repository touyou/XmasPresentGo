# XmasPresentGo

- Firestore + ARKitを使ったソーシャルゲームのサンプルです。
- クローンする際は自分のFirebaseアカウントでCloud Firestoreを有効にし、`GoogleService-Info.plist`を取り入れた後以下のルールを設定してください。

```
service cloud.firestore {
  match /databases/{database}/documents {
    match /models/{document=**} {
      allow read, write;
    }
  }
}
```

## ライセンス

[MIT](LICENCE)

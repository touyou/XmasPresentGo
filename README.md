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

## 使用モデル

- present.scn by Jarlan Perez
- teddy_bear.scn by Ronen Horovitz
- gundam.scn by Tipatat Chennavasin
- skateboard.scn by Poly by Google
- unicycle.scn by Poly by Google
- game.scn by Poly by Google

すべてCCライセンスとなっています

## ライセンス

[MIT](LICENSE)

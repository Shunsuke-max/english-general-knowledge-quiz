# AdMob Integration Setup Guide

## 実装済みの項目

✅ Info.plistにAdMobアプリIDを追加
✅ SKAdNetworkの設定
✅ App Tracking Transparency (ATT)の許可メッセージ
✅ BannerAdViewの実装
✅ QuizRootViewに広告を追加
✅ AdMob SDK初期化コード

## 次に行う手順

### 1. Xcodeでプロジェクトを開く

```bash
cd /Users/asaishunsuke/Downloads/english-general-knowledge-quiz/EnglishGeneralKnowledge
open EnglishGeneralKnowledge.xcodeproj
```

### 2. Google Mobile Ads SDKをSwift Package Managerで追加

1. Xcodeのメニューバーから **File > Add Package Dependencies...**
2. 検索欄に以下のURLを入力：
   ```
   https://github.com/googleads/swift-package-manager-google-mobile-ads.git
   ```
3. **Dependency Rule**: "Up to Next Major Version" で **11.0.0** を選択
4. **Add Package** をクリック
5. **GoogleMobileAds** を選択して **Add Package** をクリック

### 3. ビルドして確認

1. シミュレーターまたは実機でビルド
2. アプリを起動してクイズ画面を開く
3. 画面下部にテスト広告が表示されることを確認

### 4. テスト広告について

- 初回は **テスト広告** が表示されます（これは正常です）
- 本番環境では自動的に実際の広告が表示されます
- テスト広告でも動作確認できます

### 5. App Tracking Transparencyの動作

アプリ起動時に以下のダイアログが表示されます：
```
"This app uses advertising to support development. 
Your data will be used to provide personalized ads."
```

ユーザーが許可すると、パーソナライズド広告が表示されます。

## 広告の設定情報

- **AdMobアプリID**: `ca-app-pub-9982720117568146~2271842099`
- **バナー広告ユニットID**: `ca-app-pub-9982720117568146/6131906499`

## トラブルシューティング

### ビルドエラーが出る場合

1. **"Cannot find 'GoogleMobileAds' in scope"**
   → Swift Packageを追加してください（手順2）

2. **"Module 'GoogleMobileAds' not found"**
   → Xcodeを再起動してClean Build Folder (Cmd+Shift+K)

3. **広告が表示されない**
   → シミュレーターまたは実機で確認してください
   → AdMobの管理画面でアプリのステータスを確認

### 広告の表示位置を変更したい場合

`QuizRootView.swift` の `bannerPlaceholder` 部分を編集してください。

## プライバシーポリシーの更新

PRIVACY_POLICY.mdに以下を追加する必要があります：

```markdown
### AdMob広告について

当アプリは、Google AdMobを使用して広告を表示します。

- **広告提供者**: Google LLC
- **収集される情報**: デバイス情報、広告ID、使用状況データ
- **目的**: パーソナライズド広告の表示
- **プライバシーポリシー**: https://policies.google.com/privacy
```

## App Storeへの申請

広告を追加した新しいバージョンを申請する際：

1. **バージョン番号を更新**（例: 1.0 → 1.1）
2. **ビルド番号を更新**（例: 1 → 2）
3. App Store Connectで「広告を含む」にチェック
4. プライバシーポリシーURLが正しいか確認
5. 新しいスクリーンショット（広告表示あり）を追加（推奨）

## 次のステップ（オプション）

### インタースティシャル広告の追加

クイズ終了後に全画面広告を表示したい場合は、別途実装できます。

### 広告収益の確認

AdMobの管理画面で：
- 表示回数
- クリック数
- 推定収益

を確認できます。

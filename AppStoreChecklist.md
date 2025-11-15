# App Store Release Checklist

## ✅ 完了済み
- [x] GitHubリポジトリ作成
- [x] Appアイコン設定（1024x1024）
- [x] iOS Deployment Target修正（iOS 17.0）
- [x] Releaseビルド成功確認

## 🔄 要対応

### 1. Bundle Identifier
- 現在: `Shunsuke.EnglishGeneralKnowledge`
- 推奨: より標準的な形式（例: `com.shunsuke.englishquiz`）
- Apple Developer Accountで登録が必要

### 2. Privacy設定
- [x] Privacy Policyの作成（PRIVACY_POLICY.md）
- [x] ネットワーク通信の説明（Google Gemini API使用）
- [x] データ収集に関する説明
- [ ] Privacy PolicyをWebホスティング（GitHub Pagesなど）に公開
- [ ] App Store Connectに公開URLを登録

### 3. App Store Connect準備
- [ ] Apple Developer Program登録（年間99ドル）
- [ ] App Store Connectでアプリ作成
- [ ] スクリーンショット準備（必須サイズ）
  - 6.7インチ (iPhone 15 Pro Max): 1290 x 2796
  - 6.5インチ (iPhone 11 Pro Max): 1284 x 2778
- [ ] アプリ説明文（日本語・英語）
- [ ] キーワード設定
- [ ] サポートURL
- [ ] マーケティングURL（オプション）

### 4. コード署名
- [ ] Distribution Certificate作成
- [ ] App Store Provisioning Profile作成
- [ ] Xcodeでコード署名設定

### 5. TestFlight
- [ ] 内部テスト
- [ ] 外部テスト（オプション）

### 6. 最終チェック
- [ ] アプリバージョン・ビルド番号の確認
- [ ] Export Complianceの確認（暗号化使用の有無）
- [ ] App Storeレビューガイドラインの確認

## 📝 メモ
- 現在のVersion: 1.0
- 現在のBuild: 1
- Development Team: TMZXJ4QDGK

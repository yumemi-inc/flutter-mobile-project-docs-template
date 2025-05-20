# 設定機能フロー画面遷移図

## 概要

<!--
このドキュメントでは、アプリケーションの設定画面関連の画面遷移を詳細に記載します。
設定画面からアクセスできる各種設定項目と、それらの画面遷移フローを定義します。
メインの[画面遷移図](./screen_flow.md)の一部として参照されます。
-->

このドキュメントでは、アプリケーションの設定機能に関連する画面遷移を定義します。
ユーザー設定画面から各種設定項目画面への遷移と、設定変更の流れを記載しています。

## 設定機能フロー詳細

### メイン設定フロー

```mermaid
flowchart TD
    Home[ホーム画面] -- "設定ボタン" --> Settings[設定画面]
    Settings -- "プロフィール" --> Profile[プロフィール設定]
    Settings -- "通知設定" --> NotifSettings[通知設定]
    Settings -- "アカウント" --> Account[アカウント設定]
    Settings -- "セキュリティ" --> Security[セキュリティ設定]
    Settings -- "外観" --> Appearance[外観設定]
    Settings -- "言語" --> Language[言語設定]
    Settings -- "ヘルプ" --> Help[ヘルプ・サポート]
    Settings -- "利用規約" --> Terms[利用規約]
    Settings -- "プライバシーポリシー" --> Privacy[プライバシーポリシー]
    
    Profile -- "戻る" --> Settings
    NotifSettings -- "戻る" --> Settings
    Account -- "戻る" --> Settings
    Security -- "戻る" --> Settings
    Appearance -- "戻る" --> Settings
    Language -- "戻る" --> Settings
    Help -- "戻る" --> Settings
    Terms -- "戻る" --> Settings
    Privacy -- "戻る" --> Settings
    
    Settings -- "戻る" --> Home
    
    Settings -- "ログアウト" --> LogoutConfirm[ログアウト確認]
    LogoutConfirm -- "はい" --> Login[ログイン画面]
    LogoutConfirm -- "いいえ" --> Settings
```

### プロフィール設定フロー

```mermaid
flowchart TD
    Profile[プロフィール設定] --> EditProfile[プロフィール編集]
    Profile --> ChangeAvatar[アバター変更]
    
    EditProfile -- "保存" --> SaveConfirm[変更確認ダイアログ]
    SaveConfirm -- "はい" --> SaveProcess[保存処理]
    SaveProcess --> Profile
    SaveConfirm -- "いいえ" --> EditProfile
    EditProfile -- "キャンセル" --> Profile
    
    ChangeAvatar -- "カメラ" --> Camera[カメラ起動]
    ChangeAvatar -- "ギャラリー" --> Gallery[ギャラリー起動]
    ChangeAvatar -- "キャンセル" --> Profile
    
    Camera -- "写真撮影" --> AvatarPreview[アバタープレビュー]
    Gallery -- "写真選択" --> AvatarPreview
    AvatarPreview -- "確定" --> SaveAvatar[アバター保存]
    SaveAvatar --> Profile
    AvatarPreview -- "キャンセル" --> ChangeAvatar
```

### セキュリティ設定フロー

```mermaid
flowchart TD
    Security[セキュリティ設定] --> ChangePassword[パスワード変更]
    Security --> TwoFactor[二要素認証設定]
    Security --> SessionManagement[セッション管理]
    
    ChangePassword -- "変更実行" --> PasswordConfirm[変更確認]
    PasswordConfirm -- "確認" --> PasswordChanged[変更完了]
    PasswordChanged --> Security
    PasswordConfirm -- "キャンセル" --> ChangePassword
    ChangePassword -- "戻る" --> Security
    
    TwoFactor -- "有効化" --> TwoFactorSetup[設定手順]
    TwoFactorSetup -- "完了" --> TwoFactorConfirm[設定確認]
    TwoFactorConfirm --> Security
    TwoFactor -- "無効化" --> TwoFactorDisable[無効化確認]
    TwoFactorDisable --> Security
    TwoFactor -- "戻る" --> Security
    
    SessionManagement -- "セッション終了" --> SessionConfirm[終了確認]
    SessionConfirm -- "はい" --> SessionTerminated[終了完了]
    SessionConfirm -- "いいえ" --> SessionManagement
    SessionTerminated --> Security
    SessionManagement -- "戻る" --> Security
```

### 通知設定フロー

```mermaid
flowchart TD
    NotifSettings[通知設定] --> GeneralNotif[全体通知]
    NotifSettings --> PushNotif[プッシュ通知]
    NotifSettings --> EmailNotif[メール通知]
    
    GeneralNotif -- "設定保存" --> NotifSettings
    PushNotif -- "設定保存" --> NotifSettings
    EmailNotif -- "設定保存" --> NotifSettings
    
    GeneralNotif -- "戻る" --> NotifSettings
    PushNotif -- "戻る" --> NotifSettings
    EmailNotif -- "戻る" --> NotifSettings
```

## 備考

- ログアウト操作は確認ダイアログで二度確認します
- セッション管理では現在のセッション以外のログインセッションを管理できます
- 一部の設定変更（言語、テーマなど）はアプリの再起動後に反映されます
- 設定項目はアプリのバージョンによって異なる場合があります

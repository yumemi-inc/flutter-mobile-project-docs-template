# 認証フロー画面遷移図

## 概要

<!--
このドキュメントでは、アプリケーションの認証に関連する画面遷移を詳細に記載します。
ユーザー認証、アカウント登録、パスワードリセットなどの認証関連機能の画面遷移フローを定義します。
メインの[画面遷移図](./screen_flow.md)の一部として参照されます。
-->

このドキュメントでは、アプリケーションの認証機能に関連する画面遷移を定義します。
ログイン、登録、パスワードリセットなどの認証関連機能を網羅し、ユーザー認証状態による条件分岐も記載しています。

## 認証フロー詳細

### 初期認証フロー

```mermaid
flowchart TD
    Start([アプリ起動]) --> Splash[スプラッシュ画面]
    Splash --> TokenCheck{トークン有効?}
    TokenCheck -- "Yes" --> Home[ホーム画面]
    TokenCheck -- "No" --> Login[ログイン画面]
    Login -- "ログイン成功" --> Home
    Login -- "アカウント登録" --> Registration[アカウント登録画面]
    Registration -- "登録成功" --> Login
    Registration -- "キャンセル" --> Login
    Login -- "パスワードを忘れた" --> PasswordReset[パスワードリセット画面]
    PasswordReset -- "リセット完了" --> Login
    PasswordReset -- "キャンセル" --> Login
```

### パスワードリセットフロー

```mermaid
flowchart TD
    Login[ログイン画面] -- "パスワードを忘れた" --> PasswordReset[パスワードリセット画面]
    PasswordReset -- "メールアドレス入力" --> SendResetEmail[リセットメール送信]
    SendResetEmail -- "送信成功" --> ResetEmailSent[送信完了画面]
    SendResetEmail -- "エラー" --> ResetError[エラー画面]
    ResetEmailSent -- "ログイン画面に戻る" --> Login
    
    %% メール経由のパスワードリセット
    ResetLink([リセットリンク]) --> PasswordResetForm[新パスワード入力画面]
    PasswordResetForm -- "パスワード更新" --> ResetSuccess[リセット成功画面]
    ResetSuccess -- "ログイン" --> Login
```

### 多要素認証フロー

```mermaid
flowchart TD
    Login[ログイン画面] -- "ログイン情報入力" --> MFACheck{多要素認証有効?}
    MFACheck -- "Yes" --> MFAInput[認証コード入力画面]
    MFACheck -- "No" --> Home[ホーム画面]
    MFAInput -- "コード検証成功" --> Home
    MFAInput -- "コード検証失敗" --> MFAError[エラー画面]
    MFAError -- "再試行" --> MFAInput
    MFAError -- "キャンセル" --> Login
```

### ログアウトフロー

```mermaid
flowchart TD
    Settings[設定画面] -- "ログアウト選択" --> LogoutConfirm[ログアウト確認]
    LogoutConfirm -- "キャンセル" --> Settings
    LogoutConfirm -- "ログアウト実行" --> LogoutProcess[ログアウト処理]
    LogoutProcess --> Login[ログイン画面]
```

## 備考

- セッションタイムアウト（30分）後は自動的にログアウトし、ログイン画面に遷移します
- 認証エラー時は共通のエラーダイアログで表示し、再試行または中断を選択できます
- ネットワーク接続がない場合は、オフライン警告を表示し、再接続後に自動リトライします
- パスワードリセットリンクの有効期限は24時間です

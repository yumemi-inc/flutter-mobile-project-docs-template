# 通知機能フロー画面遷移図

## 概要

<!--
このドキュメントでは、アプリケーションの通知機能に関連する画面遷移を詳細に記載します。
通知画面への遷移、通知からの画面遷移、通知管理などの画面遷移フローを定義します。
メインの[画面遷移図](./screen_flow.md)の一部として参照されます。
-->

このドキュメントでは、アプリケーションの通知機能に関連する画面遷移を定義します。
通知の表示、通知からのアクション、通知管理などの流れを記載しています。

## 通知機能フロー詳細

### 通知画面メインフロー

```mermaid
flowchart TD
    Home[ホーム画面] -- "通知アイコン" --> Notification[通知一覧画面]
    Notification -- "通知タップ" --> NotificationDetail[通知詳細画面]
    Notification -- "すべて既読" --> MarkAllRead[全既読処理]
    Notification -- "通知設定" --> NotificationSettings[通知設定画面]
    Notification -- "通知削除" --> DeleteConfirm[削除確認ダイアログ]
    
    MarkAllRead --> Notification
    NotificationSettings -- "設定保存/キャンセル" --> Notification
    DeleteConfirm -- "はい" --> DeleteProcess[削除処理]
    DeleteConfirm -- "いいえ" --> Notification
    DeleteProcess --> Notification
    
    NotificationDetail -- "戻る" --> Notification
    Notification -- "戻る" --> Home
```

### 通知詳細フロー

```mermaid
flowchart TD
    NotificationDetail[通知詳細画面] -- "関連コンテンツ表示" --> RelatedContent[関連コンテンツ画面]
    NotificationDetail -- "アクション実行" --> Action[アクション処理]
    NotificationDetail -- "共有" --> Share[共有ダイアログ]
    NotificationDetail -- "削除" --> DeleteConfirm[削除確認]
    
    RelatedContent -- "戻る" --> NotificationDetail
    Action -- "完了" --> ActionResult[処理結果画面]
    ActionResult -- "戻る" --> NotificationDetail
    Share -- "完了/キャンセル" --> NotificationDetail
    DeleteConfirm -- "はい" --> DeleteProcess[削除処理]
    DeleteConfirm -- "いいえ" --> NotificationDetail
    DeleteProcess --> Notification[通知一覧画面]
```

### 通知カテゴリフロー

```mermaid
flowchart TD
    Notification[通知一覧画面] -- "カテゴリ切替" --> CategoryFilter[カテゴリ選択]
    CategoryFilter -- "すべて" --> AllNotifications[全通知表示]
    CategoryFilter -- "未読のみ" --> UnreadOnly[未読通知表示]
    CategoryFilter -- "重要" --> ImportantOnly[重要通知表示]
    CategoryFilter -- "システム" --> SystemOnly[システム通知表示]
    CategoryFilter -- "アクティビティ" --> ActivityOnly[アクティビティ通知表示]
    
    AllNotifications --> Notification
    UnreadOnly --> Notification
    ImportantOnly --> Notification
    SystemOnly --> Notification
    ActivityOnly --> Notification
```

### プッシュ通知フロー

```mermaid
flowchart TD
    PushNotif([プッシュ通知]) -- "タップ" --> AppCheck{アプリ起動中?}
    AppCheck -- "Yes" --> DeepLink[該当画面に遷移]
    AppCheck -- "No" --> AppLaunch[アプリ起動]
    AppLaunch --> Splash[スプラッシュ画面]
    Splash --> DeepLink
    
    DeepLink -- "通知内容による" --> TargetScreen[対象画面]
    DeepLink -- "通知詳細" --> NotificationDetail[通知詳細画面]
```

## 備考

- プッシュ通知からの起動時は、通知内容に関連する画面に直接遷移します
- 通知の削除は個別または一括で行うことができます
- システム通知は削除できないものもあります
- アプリがバックグラウンドとフォアグラウンドで通知表示方法が異なります
- 通知履歴は最大100件まで保存され、それ以上は古いものから自動削除されます

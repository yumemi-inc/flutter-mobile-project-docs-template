<!--
このドキュメントは外部連携一覧（External interface List）のテンプレートです。

【使い方】
- 本テンプレートはプロジェクトにおける外部システム・サービスとの連携要件を整理・共有するためのものです。
- 連携の種類ごと（例：認証系、メッセージング系、決済系など）にセクションを分けて記載してください。
- 各連携には「連携名称」「外部システム」「目的・概要」「インターフェース種別」「備考」などを明記してください。
- サンプルを参考に、必要な連携を追加・修正してください。
- 用語や表現の統一、重複の回避に注意してください。
- 詳細設計が存在する場合は、連携名称から詳細設計ドキュメントへのリンクを貼ってください。

【カラム説明】
| カラム名 | 説明 |
|-|-|
| 連携名称 | 連携機能の名称。システムやサービスごとに一意に分かる名称を記載してください。 |
| 外部システム | 連携先の外部システムやサービス名。正式名称を記載してください。 |
| 目的・概要 | 連携の目的や概要。なぜこの連携が必要か、どのような役割を果たすかを簡潔に記載してください。 |
| インターフェース種別 | 連携方式（例：REST API、Webhook、ファイル連携など）。技術的な接続方法を記載してください。 |
| 備考 | その他特記事項や注意点、関連ドキュメントへのリンクなどを記載してください。必要に応じて空欄でも構いません。 |
-->

# 外部連携一覧テンプレート（External Integration List Template）

## 認証系

| 連携名称 | 外部システム | 目的・概要 | インターフェース種別 | 備考 |
|-|-|-|-|-|
| Google認証 | Google OAuth | ユーザーログイン | REST API | |
| Appleサインイン | Apple ID | Appleアカウントによるログイン | REST API | |

## メッセージング系

| 連携名称 | 外部システム | 目的・概要 | インターフェース種別 | 備考 |
|-|-|-|-|-|
| プッシュ通知 | [FCM] | プッシュ通知送信 | REST API | |
| メール送信 | SendGrid | システムからのメール送信 | REST API | |
| SMS送信 | Twilio | 認証コード等のSMS送信 | REST API | |

## 決済系

| 連携名称 | 外部システム | 目的・概要 | インターフェース種別 | 備考 |
|-|-|-|-|-|
| クレジット決済 | Stripe | クレジットカード決済 | REST API | |
| サブスクリプション | Apple/Google課金 | アプリ内定期課金 | StoreKit/Google Play Billing | |

## ファイル連携系

| 連携名称 | 外部システム | 目的・概要 | インターフェース種別 | 備考 |
|-|-|-|-|-|
| ファイルアップロード | S3 | 画像・ドキュメントの保存 | REST API/S3 SDK | |
| 帳票出力 | Google Drive | 帳票PDFの自動保存 | REST API | |

## 分析系

| 連携名称 | 外部システム | 目的・概要 | インターフェース種別 | 備考 |
|-|-|-|-|-|
| アクセス解析 | Google Analytics | ユーザー行動のトラッキング | REST API/SDK | |
| BI連携 | Tableau | データ可視化・ダッシュボード連携 | REST API | |

## 地図・位置情報系

| 連携名称 | 外部システム | 目的・概要 | インターフェース種別 | 備考 |
|-|-|-|-|-|
| 地図表示 | Google Maps | 地図の表示・ルート検索 | REST API/SDK | |

<!-- Links -->

<!-- 認証型 -->

[FCM]: fcm.md

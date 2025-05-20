# ホーム機能フロー画面遷移図

## 概要

<!--
このドキュメントでは、アプリケーションのホーム画面を起点とした主要機能への画面遷移を詳細に記載します。
ホーム画面からアクセスできる機能や、関連する画面遷移のフローを定義します。
メインの[画面遷移図](./screen_flow.md)の一部として参照されます。
-->

このドキュメントでは、アプリケーションのホーム画面からの主要な機能への画面遷移を定義します。
ユーザーの主な利用シナリオに沿った画面遷移を記載し、ホーム画面を中心とした機能の流れを示しています。

## ホーム機能フロー詳細

### メインフロー

```mermaid
flowchart TD
    Home[ホーム画面] --> Detail1[詳細画面A]
    Home --> Detail2[詳細画面B]
    Home --> Detail3[詳細画面C]
    Home --> Search[検索画面]
    
    Detail1 -- "戻るボタン" --> Home
    Detail2 -- "戻るボタン" --> Home
    Detail3 -- "戻るボタン" --> Home
    Search -- "戻るボタン" --> Home
    
    Detail1 -- "関連情報" --> Detail2
    Detail2 -- "詳細情報" --> Detail3
    Search -- "検索結果選択" --> Detail1
    Search -- "検索結果選択" --> Detail2
    Search -- "検索結果選択" --> Detail3
    
    Home -- "通知アイコン" --> Notification[通知画面]
    Home -- "設定ボタン" --> Settings[設定画面]
    
    Notification -- "戻るボタン" --> Home
    Settings -- "戻るボタン" --> Home
```

### 詳細画面フロー

```mermaid
flowchart TD
    Detail1[詳細画面A] --> DetailInfo1[情報表示A]
    Detail1 --> Edit1[編集画面A]
    Detail1 --> Share1[共有ダイアログ]
    
    DetailInfo1 -- "戻る" --> Detail1
    Edit1 -- "保存/キャンセル" --> Detail1
    Share1 -- "完了/キャンセル" --> Detail1
    
    Detail2[詳細画面B] --> DetailInfo2[情報表示B]
    Detail2 --> Edit2[編集画面B]
    Detail2 --> Share2[共有ダイアログ]
    
    DetailInfo2 -- "戻る" --> Detail2
    Edit2 -- "保存/キャンセル" --> Detail2
    Share2 -- "完了/キャンセル" --> Detail2
```

### 検索フロー

```mermaid
flowchart TD
    Search[検索画面] --> SearchResults[検索結果画面]
    Search --> Filter[検索フィルター画面]
    
    Filter -- "フィルター適用" --> Search
    Filter -- "キャンセル" --> Search
    
    SearchResults -- "結果選択" --> Detail1[詳細画面A]
    SearchResults -- "結果選択" --> Detail2[詳細画面B]
    SearchResults -- "結果選択" --> Detail3[詳細画面C]
    
    SearchResults -- "戻る" --> Search
    Detail1 -- "戻る" --> SearchResults
    Detail2 -- "戻る" --> SearchResults
    Detail3 -- "戻る" --> SearchResults
```

### タブ切り替えフロー

```mermaid
flowchart LR
    subgraph ホームタブ
        Tab1[タブ1]
        Tab2[タブ2]
        Tab3[タブ3]
        Tab4[タブ4]
    end
    
    Tab1 -- "タブ切替" --> Tab2
    Tab2 -- "タブ切替" --> Tab3
    Tab3 -- "タブ切替" --> Tab4
    Tab4 -- "タブ切替" --> Tab1
    
    Tab1 -- "項目選択" --> Detail1[詳細画面A]
    Tab2 -- "項目選択" --> Detail2[詳細画面B]
    Tab3 -- "項目選択" --> Detail3[詳細画面C]
    Tab4 -- "項目選択" --> Settings[設定画面]
```

## 備考

- 詳細画面からの「戻る」操作は、直前の画面に戻ります（ホーム画面または検索結果画面など）
- 各詳細画面ではスワイプによるページ切り替えも可能です
- タブ状態はアプリ再起動時も保持されます
- 編集画面では未保存の変更がある場合、「戻る」操作時に確認ダイアログを表示します

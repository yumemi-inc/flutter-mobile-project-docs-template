# ドキュメントテンプレート

ドキュメントのテンプレート。

## [機能仕様書一覧]

機能仕様書一覧は以下の手順で管理されています：

1. `docs/template/functional_specification` ディレクトリ内の機能仕様書ファイルのメタ情報を取得
2. 各ファイルのメタ情報から以下の形式で機能概要を作成:

   ```md
   ## [機能名]
   - 概要: 機能が提供する価値や目的
   - 目的: 機能実現で達成したいこと
   ```

3. 作成した機能概要を `<prompt_result>` タグ内に追記

これにより、プロジェクト全体の機能を体系的に管理・把握することができます。

### 機能仕様書一覧のコメントプロンプト

- `<action>`: `<document_directory>`のファイルを取得し、`<prompt_result>`に`<template-title>`と`<template-body>`を作成
- `<rule>`: `<action>` 実行時に順守して欲しいルールを明記
- `<document_directory>`: `<action>`実行時に読み込むディレクトリを指定
- `<feature_name>`: 機能名
- `<file_path>`: 参照しているファイルの相対パスを指定
- `<template-title>`: h2のタイトル
- `<template-body>`: 作成される文章のフォーマットを指定

[機能仕様書一覧]: feature_list.md

### 機能仕様書一覧のメンテナンス方法

1. `<prompt_result>`から`</prompt_result>`ないの文章を削除し、1行改行する
2. `feature_list.md`を選択している状態で新規Chatを開く
3. `feature_list.md`が`Added`されていることを確認する
4. `Agent`モードであることを確認する
5. `model`が`calude-3.5-sonnet`であることを確認する
6. 入力欄に`<action>`を入力し、実行する
7. 生成AIの成果物を確認し、問題がなければ`Approve`する。
8. `7`で問題がある場合、`model`を適時変更し6から再度実行する

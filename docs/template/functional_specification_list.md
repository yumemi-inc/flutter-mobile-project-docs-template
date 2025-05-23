<!--
<rule>
- 変更は本ファイルのみです
- ファイルの作成、削除はしないでください
- 他ファイルは閲覧権限のみです
- "docs/template" は出力しないでください
</rule>

<document_directory>
docs/template/functional_specification
</document_directory>

<action>
<rule>に準拠し、以下の3ステップを順に実行してください

1. <document_directory> ディレクトリに保存されているファイルのメタ情報を取得する
2. ファイル単位でメタ情報を取得し、<template-title>と<template-body>に準拠し、文章を作成する
3. 作成した文章を文末に<prompt_result>と</prompt_result>の範囲に追記してください
</action>

<feature_name>
ファイルのメタデータを要約した機能名を日本語で作成してください
</feature_name>

<file_path>
- <action>で読み取ったファイルの相対パスから"docs/template/"を削除してください 
</file_path>

<template-title>
## [<feature_name>]
</template-title>

<template-body>
- **概要:** [機能が提供する価値や目的を1〜2文で記述]
- **目的:** [この機能を実現することで達成したいことを簡潔に記述]

[<feature_name>]: <file_path>
</template-body>
 -->

# 機能仕様書一覧

<!-- <prompt_result> -->

## [機能仕様書テンプレート]

- **概要:** 機能仕様書作成のためのテンプレートと執筆ガイドラインを提供
- **目的:** 標準化された形式で機能仕様書を作成し、ドキュメントの品質と一貫性を確保する

[機能仕様書テンプレート]: functional_specification/README.md

## [ユーザー認証システム]

- **概要:** アプリケーションへの安全なアクセスを提供するための包括的な認証システム
- **目的:** セキュアなユーザー認証を実現し、アカウント管理機能を提供する

[ユーザー認証システム]: functional_specification/certification.md

<!-- </prompt_result> -->
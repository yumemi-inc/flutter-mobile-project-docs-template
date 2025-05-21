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

## [機能仕様書テンプレート管理機能]

- **概要:** 機能仕様書作成のための標準化されたテンプレートとガイドラインを提供する
- **目的:** 一貫性のある高品質な機能仕様書の作成をサポートし、開発プロセスの効率化を実現する

[機能仕様書テンプレート管理機能]: functional_specification/README.md

## [ユーザー認証システム仕様]

- **概要:** セキュアなユーザー認証システムの実装仕様を提供し、アカウント管理から認証までの一連の機能を定義する
- **目的:** アプリケーションのセキュリティを確保しつつ、ユーザーフレンドリーな認証体験を実現する

[ユーザー認証システム仕様]: functional_specification/certification.md

<!-- </prompt_result> -->
# はじめに

## ワークスペースの設定

### `<workspace-name>.code-workspace` ファイルの作成

```json
{
    "folders": [
        {
            "path": "<flutter-mobile-project-templateのpath>"
        },
        {
            "path": "<flutter-mobile-project-docs-templateのpath>"
        }
    ]
}
```

上記のフォーマットに従って`<workspace-name>.code-workspace`ファイルを作成し、以下の項目を適切に設定してください：

- `<workspace-name>`: プロジェクトのワークスペース名
- `<flutter-mobile-project-templateのpath>`: [flutter-mobile-project-template]から作成したプロジェクトの絶対パスまたは相対パス
- `<flutter-mobile-project-docs-templateのpath>`: [flutter-mobile-project-docs-template]から作成したドキュメントの絶対パスまたは相対パス

### ワークスペースの読み込み

1. メニューから`File` > `Open`を選択
2. 作成した`<workspace-name>.code-workspace`ファイルを開く

ワークスペースが正しく読み込まれると

- `folders`で指定したフォルダ内のファイルが一覧表示される
- ウィンドウタイトルが`<workspace-name> (Workspace)`と表示される

<!-- URLs -->

[flutter-mobile-project-template]: https://github.com/yumemi-inc/flutter-mobile-project-template/tree/main
[flutter-mobile-project-docs-template]: https://github.com/yumemi-inc/flutter-mobile-project-docs-template

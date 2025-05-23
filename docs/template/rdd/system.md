<!--
このドキュメントは「システム方式・性能要件」のテンプレートです。

【使い方】
- 本テンプレートはシステム方式や性能要件、対象端末などの技術的要件を整理・共有するためのものです。
- 必要に応じて要件を追加・修正してください。
- 用語や表現の統一、重複の回避に注意してください。

-->

# システム方式・性能要件テンプレート

## システム方式に関する事項

<!--
このセクションには、システム方式（フレームワーク、開発言語、サポートOS、CI/CDなど）に関する要件を記載してください。
-->

<!-- markdownlint-disable MD033 -->

| 項目 | 内容 |
|-|-|
| フレームワーク | Flutter 3.x |
| 開発言語 | Dart |
| サポートOS | iOS 16以上<br>Android 14以上 |
| Target SDK Version | iOS: 17.x<br>Android: 35 |
| CI/CD | GitHub Actions |

<!-- markdownlint-enable MD033 -->

## 対象端末に関する事項

<!--
このセクションには、アプリの動作対象となる端末や推奨端末、サポート範囲、必要なハードウェア機能要件について記載してください。
- カメラ、センサー、NFC、Bluetoothなど、アプリの利用に必須となるハードウェア機能がある場合は、その要件を具体的に明記してください。
- 例：カメラ（バック/フロント、オートフォーカス）、加速度センサー、NFC対応、Bluetooth LE対応など。
- 必須要件を満たさない端末では、App Store/Google Play Store上にアプリが表示されないようストア設定を行う場合、その対応方針も明記してください。
- 法人向け端末や特殊端末、タブレット、エミュレータ等の扱いも必要に応じて記載してください。
- 例：特定のセンサー非搭載端末やNFC非対応端末はサポート対象外とする等。
- 今後新たなハードウェア要件が追加される場合は、その都度本セクションを更新してください。
-->

### カメラ機能

- カメラを搭載するiOS/Android端末のみを対象とする。
- 下記カメラ要件を見たさない端末では、App Store/Google Play Store上に表示されないように、設定を行う。

#### カメラ要件

- 以下のカメラ機能いずれかが端末に搭載されていること
  - バックカメラ
  - フロントカメラ
- カメラ機能がオートフォーカス機能を搭載していること

## 性能に関する事項

<!--
このセクションには、アプリのパフォーマンス要件や性能基準端末、調査・検証方針などを記載してください。
- 性能基準端末は、実際にパフォーマンステストや検証を行う際の代表端末を明記します。
- 性能調査では、CPU・メモリ・バッテリー消費・メモリリーク・クラッシュ率など、調査観点や対応方針を記載してください。
- 例: 主要画面の遷移速度、APIレスポンス、バックグラウンド復帰時間など。
-->

### 性能基準端末

<!--
このセクションには、性能検証やパフォーマンステストの基準とする端末を記載してください。
- 端末名、OSバージョン、型番などを具体的に記載することで、検証環境の統一を図ります。
- 新機種やOSアップデート時の対応方針も必要に応じて記載してください。
- 例: iPhone 16（iOS 18.1）、Google Pixel 9（Android 15）など。
-->

- iOS:
  - iPhone 16（iOS 18.1）
- Android:
  - Google Pixel 9（Android 15）

### 性能調査

<!--
このセクションには、性能調査・検証の観点や実施内容、対応方針を記載してください。
- CPU・メモリ使用率、メモリリーク、バッテリー消費、クラッシュ率など、調査対象を明記します。
- 問題発生時の対応フローや、定期的な性能監視の有無も記載すると良いです。
-->

- CPU、メモリ使用率の急激な上昇、メモリーリークなどの問題を調査し、適切に対処を行う。

## 上位互換性に関する事項

<!--
このセクションには、アプリの上位互換性（OSバージョンアップ時の対応方針やサポートポリシーなど）を記載してください。
- 新OSリリース時の検証・対応スケジュールや、サポート対象外OSの扱い、主要ライブラリのサポート方針などを明記します。
- 例: サポートOSを超えるバージョンはリリース後に協議・検証の上で対応判断。
-->

- サポートOSを超えるバージョンに関しては、新OSのリリース後に協議の上、対応を検討する。

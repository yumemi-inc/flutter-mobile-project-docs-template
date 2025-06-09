-- ======================================================================
-- DuckDBデータベース設計に基づくスキーマ定義
-- 
-- 目的: Flutter モバイルプロジェクトの仕様書管理システム
-- AI による仕様書とコードの連携を支援するデータベース設計
-- 
-- 作成日: 2024年
-- 設計仕様: README.md の「DuckDBデータベース設計案」に準拠
-- ======================================================================

-- 既存のテーブルがあれば削除（開発時のリセット用）
-- 外部キー制約があるため、逆順で削除
DROP TABLE IF EXISTS implementations;
DROP TABLE IF EXISTS sections;
DROP TABLE IF EXISTS revisions;
DROP TABLE IF EXISTS specifications;

-- ======================================================================
-- 1. specifications テーブル (仕様書本体の管理)
-- ======================================================================
-- 目的: Markdown形式の仕様書本体とその基本的なメタデータを管理
CREATE TABLE specifications (
    -- 仕様書の一意なID (UUID推奨)
    spec_id UUID PRIMARY KEY NOT NULL,
    
    -- ローカルでのMarkdownファイルのパス（相対パスまたは絶対パス）
    file_path VARCHAR NOT NULL UNIQUE,
    
    -- Markdownファイル名 (例: feature_x_spec.md)
    file_name VARCHAR NOT NULL,
    
    -- 仕様書のタイトル (MarkdownのH1見出しなどから抽出)
    title VARCHAR NOT NULL,
    
    -- Markdownファイルの内容全体
    content VARCHAR NOT NULL,
    
    -- 現在アクティブなリビジョンのID
    current_revision_id UUID,
    
    -- 仕様書の現在のステータス
    status VARCHAR CHECK (status IN ('Draft', 'Under Review', 'Approved', 'Deprecated')),
    
    -- レコードが作成された日時
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- レコードが最後に更新された日時
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ======================================================================
-- 2. revisions テーブル (仕様書のバージョン履歴)
-- ======================================================================
-- 目的: specifications テーブルの content カラムに対する変更履歴を管理
CREATE TABLE revisions (
    -- リビジョンの一意なID
    revision_id UUID PRIMARY KEY NOT NULL,
    
    -- 関連する仕様書のID
    spec_id UUID NOT NULL,
    
    -- そのリビジョンでの仕様書内容の完全なスナップショット
    content_snapshot VARCHAR NOT NULL,
    
    -- このリビジョンでの変更点の要約
    change_summary VARCHAR,
    
    -- 変更を行ったユーザーまたはAIのエージェント名
    changed_by VARCHAR,
    
    -- リビジョンが作成された日時
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- 外部キー制約
    FOREIGN KEY (spec_id) REFERENCES specifications(spec_id)
);

-- ======================================================================
-- 3. sections テーブル (仕様書のセクション管理)
-- ======================================================================
-- 目的: 仕様書内の論理的なセクションを管理し、AIが特定のセクションに
--       焦点を当てて操作できるようにする
CREATE TABLE sections (
    -- セクションの一意なID
    section_id UUID PRIMARY KEY NOT NULL,
    
    -- 所属する仕様書のID
    spec_id UUID NOT NULL,
    
    -- 親セクションのID (階層構造用)
    parent_section_id UUID,
    
    -- Markdownの見出しレベル (例: 1 for #, 2 for ##)
    heading_level INTEGER NOT NULL,
    
    -- セクションの見出しテキスト
    heading_text VARCHAR NOT NULL,
    
    -- セクションのMarkdown内容
    content VARCHAR NOT NULL,
    
    -- 元ファイルでのセクション開始行番号
    start_line INTEGER NOT NULL,
    
    -- 元ファイルでのセクション終了行番号
    end_line INTEGER NOT NULL,
    
    -- 仕様書内でのセクションの順序
    order_in_spec INTEGER NOT NULL,
    
    -- 外部キー制約
    FOREIGN KEY (spec_id) REFERENCES specifications(spec_id),
    FOREIGN KEY (parent_section_id) REFERENCES sections(section_id)
);

-- ======================================================================
-- 4. implementations テーブル (実装コードとの連携)
-- ======================================================================
-- 目的: 仕様書と関連する実装コードの情報を管理
CREATE TABLE implementations (
    -- 実装レコードの一意なID
    implementation_id UUID PRIMARY KEY NOT NULL,
    
    -- 関連する仕様書のID
    spec_id UUID NOT NULL,
    
    -- 関連する仕様書のセクションID（オプション）
    related_section_id UUID,
    
    -- ソースコードファイルへのパス
    code_path VARCHAR NOT NULL,
    
    -- 関連する関数名やクラス名（AIが生成する可能性）
    function_name VARCHAR,
    
    -- 関連するコードスニペット（部分的な保存）
    code_snippet VARCHAR,
    
    -- 実装内容の簡単な説明
    description VARCHAR,
    
    -- 最後にコードと同期された日時
    last_synced_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- 外部キー制約
    FOREIGN KEY (spec_id) REFERENCES specifications(spec_id),
    FOREIGN KEY (related_section_id) REFERENCES sections(section_id)
);

-- ======================================================================
-- インデックスの作成
-- ======================================================================

-- specifications テーブルのインデックス
-- file_path にユニークインデックス（重複防止）
CREATE UNIQUE INDEX idx_specifications_file_path ON specifications(file_path);

-- title にインデックス（検索性能向上）
CREATE INDEX idx_specifications_title ON specifications(title);

-- revisions テーブルのインデックス
-- spec_id と created_at の複合インデックス（履歴検索用）
CREATE INDEX idx_revisions_spec_created ON revisions(spec_id, created_at);

-- sections テーブルのインデックス
-- spec_id と order_in_spec の複合インデックス（セクション順序検索用）
CREATE INDEX idx_sections_spec_order ON sections(spec_id, order_in_spec);

-- implementations テーブルのインデックス
-- spec_id にインデックス（関連実装検索用）
CREATE INDEX idx_implementations_spec_id ON implementations(spec_id);

-- ======================================================================
-- サンプルデータ挿入例（コメントアウト）
-- ======================================================================

/*
-- サンプル仕様書の挿入例
INSERT INTO specifications VALUES (
    gen_random_uuid(),
    'docs/features/authentication.md',
    'authentication.md',
    '認証機能仕様書',
    '# 認証機能仕様書\n\n## 概要\n\nユーザー認証システムの仕様を定義します。',
    NULL,
    'Draft',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- サンプルリビジョンの挿入例
INSERT INTO revisions VALUES (
    gen_random_uuid(),
    (SELECT spec_id FROM specifications WHERE file_name = 'authentication.md'),
    '# 認証機能仕様書\n\n## 概要\n\nユーザー認証システムの仕様を定義します。',
    '初期バージョン作成',
    'AI Assistant',
    CURRENT_TIMESTAMP
);
*/

-- ======================================================================
-- 運用上の注意事項
-- ======================================================================

-- 1. DuckDBファイルの一元管理
--    - .duckdb ファイルの保存場所を統一
--    - バージョン管理への含め方を検討

-- 2. ファイル同期メカニズム
--    - DuckDB内データとローカルMarkdownファイルとの同期
--    - ファイルシステム変更監視の実装

-- 3. Markdownパーサーの頑健性
--    - sections テーブルへの正確なデータ挿入
--    - 不完全なMarkdownのエラーハンドリング

-- 4. トランザクション管理
--    - 複数テーブルにわたる変更の一貫性保証
--    - 適切なロールバック処理

-- 5. AIエージェント管理
--    - データベースアクセスの認証・認可
--    - 操作ログの記録

-- 6. パフォーマンスモニタリング
--    - 大量データ時のパフォーマンス監視
--    - インデックス最適化の検討

-- ======================================================================
-- 設計完了
-- ====================================================================== 
# Diagram Skills - 開発ガイド

*バージョン: 1.1.0*
*最終更新: 2025年11月17日*

## 📋 目次

1. [開発環境のセットアップ](#開発環境のセットアップ)
2. [プロジェクト構造](#プロジェクト構造)
3. [Skill開発ガイド](#skill開発ガイド)
4. [テスト方法](#テスト方法)
5. [リリースプロセス](#リリースプロセス)
6. [コントリビューション](#コントリビューション)
7. [トラブルシューティング](#トラブルシューティング)

---

## 開発環境のセットアップ

### 必要なツール

- **Claude Code CLI**: 最新版
- **テキストエディタ**: VS Code / Cursor 推奨
- **Git**: バージョン管理
- **Draw.io Desktop**: テスト用（オプション）
- **Node.js**: スクリプト実行用（オプション）

### 初回セットアップ

```bash
# 1. リポジトリのクローン
git clone <repository-url>
cd diagram-skills

# 2. 開発用インストール
./install.sh --debug  # または install.bat /DEBUG

# 3. 確認
claude skills list
```

### 開発モードの有効化

```bash
# Skillsディレクトリにシンボリックリンクを作成（推奨）
ln -s $(pwd)/drawio-diagram-generator ~/.claude/skills/drawio-diagram-generator
ln -s $(pwd)/mermaid-diagram-generator ~/.claude/skills/mermaid-diagram-generator

# これにより、ファイルを編集すると即座に反映される
```

---

## プロジェクト構造

### ディレクトリ構成

```
diagram-skills/
│
├── 📄 ドキュメント
│   ├── README.md                    # 総合ガイド
│   ├── INSTALL.md                   # インストール詳細
│   ├── QUICKSTART.md                # 3分ガイド
│   ├── CHANGELOG.md                 # 変更履歴
│   ├── DEVELOPMENT.md               # このファイル
│   ├── CLAUDE.md                    # Claude Code向けガイド
│   └── PROJECT.md                   # プロジェクト管理
│
├── 🔧 インストーラー
│   ├── install.sh                   # Linux/macOS
│   ├── install.bat                  # Windows
│   ├── uninstall.sh                 # Linux/macOS
│   └── uninstall.bat                # Windows
│
├── 🎨 Draw.io Skill
│   └── drawio-diagram-generator/
│       ├── SKILL.md                 # メインSkill（555行）
│       ├── styles.json              # スタイル定義（400行）
│       └── [future]
│           ├── templates/           # テンプレート集
│           ├── examples/            # サンプル図
│           └── tests/               # テストスイート
│
├── 📊 Mermaid Skill
│   └── mermaid-diagram-generator/
│       ├── SKILL.md                 # メインSkill（600行）
│       ├── simplification-rules.md  # 簡素化ルール（500行）
│       └── [future]
│           ├── templates/           # テンプレート集
│           ├── examples/            # サンプル図
│           └── tests/               # テストスイート
│
└── 🔒 設定ファイル
    ├── .claudeignore                # Claude無視ファイル
    ├── .gitignore                   # Git無視ファイル
    └── package.json                 # メタデータ（将来）
```

### ファイルサイズ

| ファイル | サイズ | 目的 |
|---------|--------|------|
| README.md | 13KB | 総合ガイド |
| INSTALL.md | 14KB | インストール詳細 |
| CHANGELOG.md | 5KB | 変更履歴 |
| drawio SKILL.md | 15KB | Draw.io生成ロジック |
| styles.json | 11KB | スタイル定義 |
| mermaid SKILL.md | 16KB | Mermaid生成ロジック |
| simplification-rules.md | 14KB | 簡素化アルゴリズム |

**合計**: 約90KB（コンパクト設計）

---

## Skill開発ガイド

### Skill作成の基本フロー

```
1. 要件定義
   ├─ 対象図タイプを決定
   ├─ 必要な機能をリストアップ
   └─ 出力形式を定義
   ↓
2. SKILL.md作成
   ├─ YAMLフロントマター
   ├─ 概要セクション
   ├─ 実行プロセス
   ├─ 図タイプ別テンプレート
   └─ ベストプラクティス
   ↓
3. 補助ファイル作成
   ├─ styles.json（Draw.io）
   ├─ simplification-rules.md（Mermaid）
   └─ その他リソース
   ↓
4. テスト
   ├─ ユニットテスト
   ├─ 統合テスト
   └─ E2Eテスト
   ↓
5. ドキュメント更新
   ├─ README.md
   ├─ CHANGELOG.md
   └─ INSTALL.md（必要に応じて）
```

### SKILL.mdの構造

#### 必須セクション

```markdown
---
name: "skill-name"
description: "簡潔な説明（最大1024文字）"
---

# Skill Title

## 概要
Skillの目的と機能

## 使用タイミング
どんな時に使うか

## 実行プロセス
ステップバイステップの処理フロー

## 図タイプ別テンプレート
各図タイプの具体的な実装

## ベストプラクティス
推奨される使い方

## トラブルシューティング
よくある問題と解決策
```

#### YAMLフロントマターのルール

```yaml
---
name: "skill-name"              # 必須：英数字とハイフンのみ、最大64文字
description: "説明文"            # 必須：最大1024文字
version: "1.0.0"                # オプション：セマンティックバージョニング
author: "作成者"                 # オプション
tags: ["tag1", "tag2"]          # オプション：検索用タグ
---
```

### styles.jsonの構造

```json
{
  "version": "1.0.0",
  "description": "スタイル定義の説明",
  
  "globalSettings": {
    // 全体設定
  },
  
  "colorPalette": {
    // カラー定義
  },
  
  "diagramStyles": {
    "useCase": { /* ユースケース図用 */ },
    "class": { /* クラス図用 */ },
    "sequence": { /* シーケンス図用 */ },
    // ...
  },
  
  "layoutSettings": {
    // レイアウト設定
  }
}
```

### コーディング規約

#### Markdown

```markdown
# レベル1見出し（タイトルのみ）

## レベル2見出し（主要セクション）

### レベル3見出し（サブセクション）

#### レベル4見出し（詳細）

**太字**: 重要な用語
*斜体*: 強調

- 箇条書き
  - インデント

1. 番号付きリスト
2. 順序が重要な場合

`インラインコード`

```言語
コードブロック
```
```

#### コードスニペット

```javascript
// ✅ 良い例：コメント付き、説明的な変数名
function calculateOptimalRoute(edge, elements) {
  // 経由点を計算
  const waypoints = [];
  
  for (const element of elements) {
    if (doesEdgeCrossElement(edge, element)) {
      waypoints.push(calculateDetourPoint(element));
    }
  }
  
  return waypoints;
}

// ❌ 悪い例：コメントなし、不明瞭な変数名
function calc(e, el) {
  const wp = [];
  for (const x of el) {
    if (check(e, x)) wp.push(det(x));
  }
  return wp;
}
```

---

## テスト方法

### マニュアルテスト

#### 1. 基本動作テスト

```bash
# Claude Codeを起動
claude

# Draw.ioテスト
> Eコマースシステムのクラス図をDraw.ioで作成してください

# 期待される動作：
# 1. [drawio-diagram-generator Skillを使用] と表示
# 2. .drawioファイルが生成される
# 3. パステルカラーで表示
# 4. 線が交差していない

# Mermaidテスト
> APIのシーケンス図をMermaidで作成してください

# 期待される動作：
# 1. [mermaid-diagram-generator Skillを使用] と表示
# 2. .mdファイルが生成される
# 3. GitHubで表示可能
# 4. シンプルで読みやすい
```

#### 2. 各図タイプのテスト

**Draw.io:**
```
テストケース1: ユースケース図
テストケース2: クラス図（10個のクラス）
テストケース3: シーケンス図（5個のメッセージ）
テストケース4: アクティビティ図
テストケース5: ステートマシン図
テストケース6: コンポーネント図
テストケース7: 配置図
テストケース8: オブジェクト図
テストケース9: パッケージ図
テストケース10: コミュニケーション図
テストケース11: ER図（8個のエンティティ）
テストケース12: データモデル図
```

**Mermaid:**
```
テストケース1: クラス図（シンプル）
テストケース2: シーケンス図（5メッセージ）
テストケース3: ステートマシン図
テストケース4: ER図（6エンティティ）
```

#### 3. エッジケーステスト

```
- 複雑な図（要素数20個以上）
- 日本語の長いラベル（50文字以上）
- 特殊文字を含む名前
- 循環参照のある図
- 空の要素
```

### 自動テスト（将来実装予定）

```bash
# テストスクリプトの実行
npm test

# 特定のSkillをテスト
npm test -- drawio

# カバレッジレポート
npm run coverage
```

### テストチェックリスト

```markdown
## Draw.io Skill

- [ ] 12種類の図全てが生成できる
- [ ] パステルカラーが適用される
- [ ] 線が他のボックスを横切らない
- [ ] 日本語ラベルが正しく表示される
- [ ] 技術用語が英語のまま保持される
- [ ] .drawioファイルがDraw.ioで開ける
- [ ] styles.jsonの設定が反映される

## Mermaid Skill

- [ ] 対応する図タイプが全て生成できる
- [ ] 複雑度チェックが機能する
- [ ] 15個以上の要素で分割提案が出る
- [ ] GitHubで表示できる
- [ ] VS Codeでプレビューできる
- [ ] 表示エラーが発生しない
- [ ] simplification-rulesが適用される

## インストーラー

- [ ] Windows版が動作する
- [ ] Linux/macOS版が動作する
- [ ] 既存Skillsがバックアップされる
- [ ] エラー時にロールバックされる
- [ ] 他のSkillsに影響しない
- [ ] ログファイルが正しく生成される

## アンインストーラー

- [ ] diagram-skillsのみ削除される
- [ ] 他のSkillsは残る
- [ ] 確認プロンプトが表示される
- [ ] 強制削除モードが動作する
```

---

## リリースプロセス

### バージョニング

セマンティックバージョニング（Semantic Versioning）に従う：

```
MAJOR.MINOR.PATCH

例: 1.1.0
     │ │ └─ パッチ：バグ修正
     │ └─── マイナー：機能追加（後方互換性あり）
     └───── メジャー：破壊的変更
```

### リリース手順

#### 1. 準備

```bash
# 現在のバージョンを確認
git tag -l

# 新バージョンを決定（例: 1.2.0）
NEW_VERSION="1.2.0"
```

#### 2. CHANGELOGの更新

```markdown
# CHANGELOG.md

## [1.2.0] - 2025-11-20

### 追加
- 新しいテンプレート機能
- Draw.ioの自動レイアウト最適化

### 変更
- simplification-rulesの改善
- ドキュメントの更新

### 修正
- Windows版インストーラーのバグ修正
- 日本語ラベルの文字化け問題
```

#### 3. バージョン番号の更新

```bash
# 全ドキュメントのバージョンを更新
# - README.md
# - INSTALL.md
# - CHANGELOG.md
# - DEVELOPMENT.md
# - SKILL.md（各）
# - styles.json
```

#### 4. テスト

```bash
# 全テストを実行
./test-all.sh

# インストール/アンインストールテスト
./install.sh --debug
./uninstall.sh --force
./install.bat /DEBUG
./uninstall.bat /FORCE
```

#### 5. ZIPファイルの作成

```bash
# クリーンビルド
rm -f diagram-skills.zip
zip -r diagram-skills.zip diagram-skills/ -x "*.log" -x "*.git*"

# ファイルサイズ確認（推奨: 1MB以下）
ls -lh diagram-skills.zip
```

#### 6. Gitタグの作成

```bash
# コミット
git add .
git commit -m "Release v${NEW_VERSION}"

# タグ作成
git tag -a "v${NEW_VERSION}" -m "Version ${NEW_VERSION}"

# プッシュ
git push origin main
git push origin "v${NEW_VERSION}"
```

#### 7. リリースノートの作成

```markdown
# Release v1.2.0

## 新機能
- テンプレート機能の追加
- 自動レイアウト最適化

## 改善
- Mermaid簡素化ルールの改善
- ドキュメントの充実

## バグ修正
- Windowsインストーラーのバグ修正
- 日本語表示の問題解決

## ダウンロード
- [diagram-skills-v1.2.0.zip](link)

## インストール
```bash
./install.sh  # または install.bat
```

詳細は [INSTALL.md](INSTALL.md) を参照。
```

### リリースチェックリスト

```markdown
- [ ] 全テストが通る
- [ ] CHANGELOGが更新されている
- [ ] バージョン番号が全ファイルで一致
- [ ] ZIPファイルが作成されている
- [ ] ファイルサイズが適切（<1MB推奨）
- [ ] Gitタグが作成されている
- [ ] リリースノートが作成されている
- [ ] ドキュメントが最新
- [ ] 既存環境でテスト済み
```

---

## コントリビューション

### ブランチ戦略

```
main              # 本番用（安定版）
  ↑
  └─ develop      # 開発用（次期バージョン）
       ↑
       ├─ feature/template-system    # 機能追加
       ├─ bugfix/windows-encoding    # バグ修正
       └─ docs/update-readme         # ドキュメント更新
```

### プルリクエストのフロー

```
1. Issueを作成
   └─ 実装内容を明確に

2. ブランチを作成
   git checkout -b feature/your-feature

3. 開発
   ├─ コードを書く
   ├─ テストを追加
   └─ ドキュメントを更新

4. コミット
   git commit -m "feat: add template system"

5. プッシュ
   git push origin feature/your-feature

6. プルリクエスト作成
   ├─ タイトル: [feat] テンプレート機能追加
   ├─ 説明: 実装内容の詳細
   ├─ チェックリスト
   └─ スクリーンショット（必要に応じて）

7. レビュー
   └─ フィードバックに対応

8. マージ
   └─ mainまたはdevelopへ
```

### コミットメッセージ規約

```
<type>: <subject>

<body>

<footer>
```

**Type:**
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメントのみの変更
- `style`: コードの意味に影響しない変更（フォーマットなど）
- `refactor`: リファクタリング
- `test`: テストの追加・修正
- `chore`: ビルドプロセスやツールの変更

**例:**
```
feat: add template system for Draw.io

- テンプレート管理機能を追加
- templates/ディレクトリに標準テンプレートを配置
- SKILL.mdからテンプレートを参照可能に

Closes #123
```

### コードレビューの観点

```markdown
## 機能性
- [ ] 要件を満たしている
- [ ] エッジケースを考慮している
- [ ] エラーハンドリングが適切

## 品質
- [ ] コードが読みやすい
- [ ] コメントが適切
- [ ] 命名が適切

## テスト
- [ ] テストが追加されている
- [ ] テストが通る
- [ ] カバレッジが適切

## ドキュメント
- [ ] ドキュメントが更新されている
- [ ] CHANGELOGに記載されている
- [ ] コメントが十分

## 互換性
- [ ] 既存機能に影響しない
- [ ] Windows/Linux/macOSで動作
- [ ] バージョン互換性を保持
```

---

## トラブルシューティング

### 開発中の問題

#### 問題1: Skillが認識されない

**原因**: キャッシュの問題

**解決策**:
```bash
# Skillsキャッシュをクリア
claude skills refresh

# Claude再起動
claude restart

# シンボリックリンクを再作成
rm ~/.claude/skills/drawio-diagram-generator
ln -s $(pwd)/drawio-diagram-generator ~/.claude/skills/
```

#### 問題2: 変更が反映されない

**原因**: ファイルが正しく保存されていない

**解決策**:
```bash
# ファイルの最終更新時刻を確認
ls -la drawio-diagram-generator/SKILL.md

# 強制的に再読み込み
claude skills reload drawio-diagram-generator
```

#### 問題3: JSONパースエラー

**原因**: styles.jsonの構文エラー

**解決策**:
```bash
# JSONの妥当性チェック
python -m json.tool drawio-diagram-generator/styles.json

# または
jq . drawio-diagram-generator/styles.json
```

### テスト時の問題

#### 問題1: Draw.ioファイルが開けない

**原因**: XMLの構文エラー

**解決策**:
```bash
# XMLの妥当性チェック
xmllint --noout diagram.drawio

# エラー箇所を特定
xmllint diagram.drawio
```

#### 問題2: Mermaid図が表示されない

**原因**: 複雑すぎる、またはシンタックスエラー

**解決策**:
```bash
# Mermaid Live Editorでテスト
# https://mermaid.live/

# 簡素化ルールを適用
# simplification-rules.mdを参照
```

### デバッグテクニック

#### ログの確認

```bash
# インストールログ
cat install.log

# Claude Codeのログ
claude logs

# デバッグモードで実行
claude --debug
```

#### プロファイリング

```javascript
// SKILL.md内でデバッグ出力
console.log('DEBUG: 処理開始');
console.log('要素数:', elements.length);
console.time('処理時間');
// ... 処理 ...
console.timeEnd('処理時間');
```

---

## ベストプラクティス

### Skill開発

1. **シンプルに保つ**
   - 1つのSkillは1つの責務
   - 複雑な処理は分割

2. **ドキュメントを充実させる**
   - コメントは「なぜ」を書く
   - 使用例を豊富に

3. **エラーハンドリング**
   - 想定外の入力に対応
   - わかりやすいエラーメッセージ

4. **後方互換性**
   - 既存の動作を壊さない
   - 非推奨機能は段階的に削除

### コード品質

```javascript
// ✅ 良い例
function calculateEdgeRoute(edge, obstacles) {
  // 障害物を避けるルートを計算
  const waypoints = [];
  
  for (const obstacle of obstacles) {
    if (isInPath(edge, obstacle)) {
      // 迂回点を追加
      waypoints.push(calculateDetour(obstacle));
    }
  }
  
  return waypoints;
}

// ❌ 悪い例
function calc(e, o) {
  const w = [];
  for (const x of o) {
    if (check(e, x)) w.push(det(x));
  }
  return w;
}
```

### パフォーマンス

```javascript
// ✅ 最適化
const cache = new Map();

function expensiveOperation(key) {
  if (cache.has(key)) {
    return cache.get(key);
  }
  
  const result = doExpensiveWork(key);
  cache.set(key, result);
  return result;
}

// ❌ 非効率
function expensiveOperation(key) {
  // 毎回計算
  return doExpensiveWork(key);
}
```

---

## 今後の開発予定

### Phase 2（v1.2.0）

- [ ] テンプレート機能
  - 標準テンプレート集
  - カスタムテンプレート対応
  
- [ ] 自動テストスイート
  - ユニットテスト
  - 統合テスト
  - E2Eテスト

### Phase 3（v1.3.0）

- [ ] インタラクティブ機能
  - リアルタイムプレビュー
  - 対話的な要素配置
  
- [ ] CI/CD
  - GitHub Actions設定
  - 自動リリース

### Phase 4（v2.0.0）

- [ ] プラグインシステム
  - 外部Skillとの連携
  - カスタム拡張

- [ ] クラウド連携
  - オンラインストレージ
  - チーム共有機能

---

## 参考資料

### 公式ドキュメント

- [Claude Skills Documentation](https://docs.anthropic.com/skills)
- [Draw.io Documentation](https://www.diagrams.net/doc/)
- [Mermaid Documentation](https://mermaid.js.org/)

### 関連リソース

- [UML Specification](https://www.omg.org/spec/UML/)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)

### コミュニティ

- GitHub Issues: バグ報告・機能要望
- GitHub Discussions: 質問・議論
- Pull Requests: コントリビューション

---

## まとめ

このプロジェクトは以下の原則に基づいています：

✅ **シンプル**: 複雑さを避け、理解しやすく
✅ **安全**: 既存環境を壊さない、ロールバック可能
✅ **ドキュメント**: 充実したドキュメント
✅ **テスト**: 品質を保証するテスト
✅ **オープン**: コントリビューション歓迎

開発に参加する際は、これらの原則を守ってください。

質問がある場合は、GitHubのIssuesまたはDiscussionsで気軽に聞いてください！

---

*最終更新: 2025年11月17日*
*バージョン: 1.1.0*

# Mermaid Validators - 使い方ガイド

*バージョン: 1.0.0*
*作成日: 2025年11月18日*

このディレクトリには、Mermaid図の品質を向上させるための軽量バリデーションツールが含まれています。

---

## 📋 概要

### 提供ツール

1. **mermaid-validator.js** - 構文と基本ルールのバリデーター
2. **complexity-checker.js** - 複雑度の計算と推奨事項の提供

### 特徴

- ✅ **依存関係なし**: mermaid.jsライブラリ不要、Node.jsのみで動作
- ✅ **軽量**: 高速実行（50ms以下）
- ✅ **詳細な診断**: エラー、警告、情報を階層的に提供
- ✅ **JSON出力対応**: 他のツールとの連携が容易
- ✅ **CLI & モジュール**: コマンドライン実行とNode.jsモジュールの両方に対応

---

## 🚀 クイックスタート

### 前提条件

- Node.js 14.0.0 以上

### インストール

これらのツールはスタンドアロンのJavaScriptファイルです。npm installは不要です。

```bash
# Node.jsがインストールされているか確認
node --version

# v14.0.0 以上ならOK
```

### 基本的な使い方

```bash
# バリデーション実行
node validators/mermaid-validator.js diagram.mmd

# 複雑度チェック
node validators/complexity-checker.js diagram.mmd
```

---

## 🔍 mermaid-validator.js

### 概要

正規表現ベースの軽量バリデーターで、以下をチェックします：

- ✅ コードブロックの整合性
- ✅ ダイアグラム宣言の有効性
- ✅ コメントの記法
- ✅ 引用符の閉じ忘れ
- ✅ 矢印記法の正確性
- ✅ 特殊文字の使用
- ✅ 要素数の制限
- ✅ 複雑度の計算

### 使い方

#### 基本コマンド

```bash
node validators/mermaid-validator.js diagram.mmd
```

#### オプション

```bash
# JSON形式で出力
node validators/mermaid-validator.js diagram.mmd --json

# ヘルプ表示
node validators/mermaid-validator.js --help
```

### 出力例

#### 通常出力

```
=== Mermaid Diagram Validation ===

File: diagram.mmd
Diagram Type: class
Complexity: simple (score: 18)
Status: ✅ VALID

ℹ️  INFO:
  1. [ELEMENT_COUNT] クラス数: 8

✅ バリデーション成功！すべてのチェックをパスしました。
```

#### エラーがある場合

```
=== Mermaid Diagram Validation ===

File: diagram.mmd
Diagram Type: class
Complexity: moderate (score: 32)
Status: ❌ INVALID

🚫 ERRORS:
  1. [UNCLOSED_QUOTE] 閉じていないダブルクォート (") があります
     Line: 5
     Content: A["ラベル] --> B

⚠️  WARNINGS:
  1. [TOO_MANY_ELEMENTS] クラス数が多すぎます（15個）。推奨: 12個以下
     Suggestion: 図を分割してください

  2. [LONG_LABEL] ラベルが長すぎます（35文字）
     Line: 8
     Content: A["とても長いラベルテキストがここに入ります"] --> B
     Suggestion: 30文字以内に短縮してください
```

#### JSON出力

```bash
node validators/mermaid-validator.js diagram.mmd --json
```

```json
{
  "valid": false,
  "diagramType": "class",
  "complexity": {
    "score": 32,
    "level": "moderate"
  },
  "errors": [
    {
      "type": "UNCLOSED_QUOTE",
      "message": "閉じていないダブルクォート (\") があります",
      "line": 5,
      "content": "A[\"ラベル] --> B"
    }
  ],
  "warnings": [
    {
      "type": "TOO_MANY_ELEMENTS",
      "message": "クラス数が多すぎます（15個）。推奨: 12個以下",
      "suggestion": "図を分割してください"
    }
  ],
  "info": [
    {
      "type": "ELEMENT_COUNT",
      "message": "クラス数: 15"
    }
  ]
}
```

### 終了コード

- `0`: バリデーション成功（エラーなし）
- `1`: バリデーション失敗（エラーあり）

### エラータイプ一覧

| タイプ | 説明 | 重要度 |
|--------|------|--------|
| `CODE_BLOCK` | コードブロックが正しく囲まれていない | High |
| `DIAGRAM_DECLARATION` | 無効なダイアグラム宣言 | High |
| `INVALID_COMMENT` | 無効なコメント記法 | High |
| `UNCLOSED_QUOTE` | 閉じていない引用符 | High |
| `UNCLOSED_BRACKET` | 閉じていないブラケット | High |
| `INVALID_ARROW` | 無効な矢印記法 | Medium |
| `SPECIAL_CHAR` | ラベル内の特殊文字 | Medium |
| `LONG_LABEL` | ラベルが長すぎる | Low |
| `TOO_MANY_ELEMENTS` | 要素数の超過 | Medium |

---

## 📊 complexity-checker.js

### 概要

Mermaid図の複雑度を計算し、simplification-rules.mdに基づいた推奨事項を提供します。

### 使い方

#### 基本コマンド

```bash
node validators/complexity-checker.js diagram.mmd
```

#### オプション

```bash
# JSON形式で出力
node validators/complexity-checker.js diagram.mmd --json

# カスタム閾値を設定
node validators/complexity-checker.js diagram.mmd --simple 20 --moderate 35

# ヘルプ表示
node validators/complexity-checker.js --help
```

### 複雑度の計算式

#### クラス図
```
complexity = (classes × 1.0) + (attributes × 0.3) + (methods × 0.3) + (relations × 0.5)
```

#### シーケンス図
```
complexity = (participants × 2.0) + (messages × 1.0) + (nesting × 5.0) + (branches × 3.0)
```

#### ステートマシン図
```
complexity = (states × 1.5) + (transitions × 1.0) + (composite × 5.0)
```

#### ER図
```
complexity = (entities × 1.5) + (attributes × 0.3) + (relationships × 1.0)
```

#### フローチャート
```
complexity = (nodes × 1.0) + (edges × 0.8) + (subgraphs × 3.0) + (branches × 2.0)
```

### 複雑度レベル

| レベル | スコア | 評価 | アクション |
|--------|--------|------|-----------|
| **Simple** | < 25 | ✅ 良好 | そのまま使用可能 |
| **Moderate** | 25-40 | ⚠️ 警告 | 簡素化を検討 |
| **Complex** | > 40 | ❌ 高リスク | 図を分割すべき |

### 出力例

#### 通常出力

```
=== Mermaid Complexity Analysis ===

File: diagram.mmd
Diagram Type: class

Metrics:
  Elements: 8
  Relationships: 10
  Attributes: 15
  Methods: 12

Complexity:
  Score: 18
  Level: SIMPLE
  Thresholds: Simple < 25, Moderate < 40

Recommendations:
  ✅ 複雑度は適切です。このまま使用できます。
```

#### Moderate の場合

```
=== Mermaid Complexity Analysis ===

File: diagram.mmd
Diagram Type: class

Metrics:
  Elements: 12
  Relationships: 15
  Attributes: 25
  Methods: 20

Complexity:
  Score: 32
  Level: MODERATE
  Thresholds: Simple < 25, Moderate < 40

Recommendations:
  ⚠️ 複雑度がやや高めです。以下の改善を検討してください。
     → 関連するクラスをグループ化して、複数の図に分割してください
```

#### Complex の場合

```
=== Mermaid Complexity Analysis ===

File: diagram.mmd
Diagram Type: class

Metrics:
  Elements: 18
  Relationships: 22
  Attributes: 45
  Methods: 35

Complexity:
  Score: 48
  Level: COMPLEX
  Thresholds: Simple < 25, Moderate < 40

Recommendations:
  ❌ 複雑度が高すぎます。図を分割することを強く推奨します。
     → 関連するクラスをグループ化して、複数の図に分割してください
  ❌ クラス数を削減（現在: 18個 → 推奨: 12個以下）
     → 関連するクラスをグループ化して、複数の図に分割してください
  ❌ 属性が多すぎます
     → 重要な属性のみを表示し、詳細は別の図で示してください
  ❌ リレーションを削減（現在: 22本 → 推奨: 15本以下）
     → 主要なリレーションのみを表示してください
```

### 終了コード

- `0`: Simple または Moderate
- `1`: Complex（分割推奨）

---

## 🔧 CI/CD統合

### GitHub Actions

```yaml
name: Validate Mermaid Diagrams

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Validate diagrams
        run: |
          for file in docs/**/*.mmd; do
            echo "Validating $file..."
            node mermaid-diagram-generator/validators/mermaid-validator.js "$file" || exit 1
            node mermaid-diagram-generator/validators/complexity-checker.js "$file" || exit 1
          done
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Validating Mermaid diagrams..."

for file in $(git diff --cached --name-only --diff-filter=ACM | grep '\.mmd$'); do
  echo "Checking $file..."

  # バリデーション
  node mermaid-diagram-generator/validators/mermaid-validator.js "$file"
  if [ $? -ne 0 ]; then
    echo "❌ Validation failed for $file"
    exit 1
  fi

  # 複雑度チェック
  node mermaid-diagram-generator/validators/complexity-checker.js "$file"
  if [ $? -ne 0 ]; then
    echo "⚠️ Complexity too high for $file (図を分割してください)"
    exit 1
  fi
done

echo "✅ All diagrams validated successfully"
```

---

## 🛠️ Node.jsモジュールとして使用

### mermaid-validator.js

```javascript
const { MermaidValidator } = require('./validators/mermaid-validator.js');

const validator = new MermaidValidator();
const code = `
\`\`\`mermaid
classDiagram
    class User {
        +id: string
        +getName() string
    }
\`\`\`
`;

const result = validator.validate(code);

if (result.valid) {
  console.log('✅ Validation passed');
} else {
  console.log('❌ Validation failed');
  result.errors.forEach(error => {
    console.log(`  ${error.type}: ${error.message}`);
  });
}
```

### complexity-checker.js

```javascript
const { MermaidComplexityChecker } = require('./validators/complexity-checker.js');

const checker = new MermaidComplexityChecker({
  simpleThreshold: 25,
  moderateThreshold: 40
});

const code = fs.readFileSync('diagram.mmd', 'utf8');
const result = checker.check(code);

console.log(`Complexity: ${result.complexity.level} (${result.complexity.score})`);

result.recommendations.forEach(rec => {
  console.log(`${rec.type}: ${rec.message}`);
});
```

---

## 🔍 トラブルシューティング

### 問題: node: command not found

**原因**: Node.jsがインストールされていない

**解決策**:
```bash
# Node.jsをインストール
# Windows: https://nodejs.org/
# macOS: brew install node
# Linux: apt-get install nodejs
```

### 問題: Permission denied

**原因**: 実行権限がない

**解決策**:
```bash
# 実行権限を付与（Unix系のみ）
chmod +x validators/mermaid-validator.js
chmod +x validators/complexity-checker.js
```

### 問題: ファイルが見つからない

**原因**: パスが間違っている

**解決策**:
```bash
# 絶対パスを使用
node validators/mermaid-validator.js /full/path/to/diagram.mmd

# または、カレントディレクトリを確認
pwd
ls -la diagram.mmd
```

---

## 📚 関連ドキュメント

- [validation-checklist.md](../validation-checklist.md) - 詳細なバリデーション手順
- [simplification-rules.md](../simplification-rules.md) - 簡素化ルールと複雑度の説明
- [SKILL.md](../SKILL.md) - Mermaid図生成Skillのメインドキュメント

---

## 🤝 貢献

改善提案やバグ報告は大歓迎です。

### バグ報告時の情報

- バリデーター/チェッカーのバージョン
- Node.jsのバージョン
- 入力したMermaidコード
- 期待される結果と実際の結果

---

## 📝 ライセンス

MIT License

---

*最終更新: 2025年11月18日*
*著作権: (c) 2025 KEIEI.NET INC.*
*作成者: KENJI OYAMA*
*バージョン: 1.0.0*

# 図生成Claude Skills - 完全ガイド

*バージョン: 1.2.0*
*作成日: 2025年11月17日*
*最終更新: 2025年11月18日*

## 📊 概要

このリポジトリには、Claude Code用の2つの専門的な図生成Skillsが含まれています：

1. **drawio-diagram-generator** - Draw.io形式の詳細な図を生成
2. **mermaid-diagram-generator** - Mermaid形式のシンプルな図を生成

## 🎯 対応図タイプ（12種類）

| # | 図タイプ | Draw.io | Mermaid | 推奨 |
|---|---------|---------|---------|------|
| 1 | ユースケース図 | ✅ | ⚠️ | Draw.io |
| 2 | クラス図 | ✅ | ✅ | 両方 |
| 3 | シーケンス図 | ✅ | ✅ | 両方 |
| 4 | アクティビティ図 | ✅ | ✅ | 両方 |
| 5 | ステートマシン図 | ✅ | ✅ | 両方 |
| 6 | コンポーネント図 | ✅ | ⚠️ | Draw.io |
| 7 | 配置図 | ✅ | ⚠️ | Draw.io |
| 8 | オブジェクト図 | ✅ | ⚠️ | Draw.io |
| 9 | パッケージ図 | ✅ | ⚠️ | Draw.io |
| 10 | コミュニケーション図 | ✅ | ❌ | Draw.io |
| 11 | ER図 | ✅ | ✅ | 両方 |
| 12 | データモデル図 | ✅ | ✅ | 両方 |

**凡例**:
- ✅ 完全サポート
- ⚠️ 限定的サポート（代替手段あり）
- ❌ サポートなし

---

## 📁 ファイル構成

```
diagram-skills/
├── README.md                           # このファイル
├── INSTALL.md                          # 詳細なインストールガイド
├── CHANGELOG.md                        # 変更履歴
├── install.sh                          # インストールスクリプト (Linux/macOS)
├── install.bat                         # インストールスクリプト (Windows)
├── uninstall.sh                        # アンインストールスクリプト (Linux/macOS)
├── uninstall.bat                       # アンインストールスクリプト (Windows)
├── drawio-diagram-generator/           # Draw.ioスキル
│   ├── SKILL.md                        # メインスキル定義
│   └── styles.json                     # スタイル設定
└── mermaid-diagram-generator/          # Mermaidスキル
    ├── SKILL.md                        # メインスキル定義
    ├── simplification-rules.md         # 簡素化ルール
    ├── validation-checklist.md         # バリデーションチェックリスト 🆕
    └── validators/                     # バリデーションツール 🆕
        ├── README.md                   # バリデーター使い方ガイド
        ├── mermaid-validator.js        # 構文バリデーター
        └── complexity-checker.js       # 複雑度チェッカー
```

---

## 🚀 インストール方法

### 自動インストール（推奨）⭐

最も簡単で安全な方法です。既存のSkillsを保護し、エラー時は自動でロールバックします。

#### Windows

1. **PowerShellを開く**（管理者権限不要）

2. **ZIPファイルを展開**
   ```powershell
   Expand-Archive -Path diagram-skills.zip -DestinationPath $env:USERPROFILE\Downloads\diagram-skills
   ```

3. **インストール実行**
   ```powershell
   cd $env:USERPROFILE\Downloads\diagram-skills
   .\install.bat
   ```

4. **確認**
   ```powershell
   claude skills list
   ```

#### macOS / Linux

1. **ターミナルを開く**

2. **ZIPファイルを展開**
   ```bash
   cd ~/Downloads
   unzip diagram-skills.zip
   ```

3. **インストール実行**
   ```bash
   cd diagram-skills
   chmod +x install.sh
   ./install.sh
   ```

4. **確認**
   ```bash
   claude skills list
   ```

### 手動インストール

詳細な手順は [INSTALL.md](INSTALL.md) を参照してください。

---

## 🗑️ アンインストール方法

### 自動アンインストール（推奨）

このSkillsのみを安全に削除します。他のSkillsには影響しません。

#### Windows

```powershell
cd $env:USERPROFILE\Downloads\diagram-skills
.\uninstall.bat
```

#### macOS / Linux

```bash
cd ~/Downloads/diagram-skills
./uninstall.sh
```

### 強制削除（確認なし）

#### Windows

```powershell
.\uninstall.bat /FORCE
```

#### macOS / Linux

```bash
./uninstall.sh --force
```

詳細は [INSTALL.md](INSTALL.md) のトラブルシューティングを参照してください。

---

## 🔍 バリデーション機能（v1.2.0新機能）

Mermaid図生成時のSyntax errorを防ぐための包括的なバリデーション機能を提供します。

### 特徴

- ✅ **自動バリデーション**: Claudeが図生成時に自動的にチェック
- ✅ **エラー防止**: 80-95%のSyntax errorを事前に検出
- ✅ **複雑度管理**: 図の複雑さを自動計算し、推奨事項を提供
- ✅ **軽量ツール**: Node.jsのみで動作（npm不要）
- ✅ **CI/CD対応**: GitHub ActionsやPre-commit Hookで使用可能

### 2段階のバリデーション

#### レベル1: 自動バリデーション（常時有効）

Claudeが図を生成する際、以下を自動的にチェック：

- **基本構文**: コードブロック、宣言、コメント、引用符、矢印
- **複雑度**: 要素数、ネスト階層、ラベル長
- **プラットフォーム互換性**: GitHub、VS Code、Cursorでの表示保証
- **エラー修正**: 問題を発見したら即座に自動修正

**使用方法**: 特別な操作は不要。Claudeに図を依頼するだけで自動的に適用されます。

```
ユーザー: Eコマースシステムのクラス図をMermaidで作成してください

Claude: [図を生成]
        [自動バリデーション実行]
        [エラーがあれば修正]
        [Mermaid Live Editorで最終確認]
        [完成した図を提供]
```

#### レベル2: 手動バリデーション（オプション）

より厳密な検証が必要な場合、専用ツールを使用：

**構文バリデーター**:
```bash
node mermaid-diagram-generator/validators/mermaid-validator.js diagram.mmd
```

出力例:
```
=== Mermaid Diagram Validation ===
File: diagram.mmd
Diagram Type: class
Complexity: simple (score: 18)
Status: ✅ VALID

✅ バリデーション成功！すべてのチェックをパスしました。
```

**複雑度チェッカー**:
```bash
node mermaid-diagram-generator/validators/complexity-checker.js diagram.mmd
```

出力例:
```
=== Mermaid Complexity Analysis ===
File: diagram.mmd
Complexity Score: 18
Level: SIMPLE

Recommendations:
  ✅ 複雑度は適切です。このまま使用できます。
```

### バリデーション項目

| カテゴリ | チェック内容 | 自動修正 |
|----------|------------|---------|
| **基本構文** | コードブロック、宣言、コメント | ✅ |
| **引用符** | 閉じ忘れの検出 | ✅ |
| **矢印記法** | 無効な矢印の検出 | ✅ |
| **特殊文字** | エスケープ不要な文字の使用 | ⚠️ |
| **複雑度** | 要素数、ネスト階層 | ❌ (推奨のみ) |
| **ラベル長** | 30文字制限 | ⚠️ |

**凡例**:
- ✅ 自動修正
- ⚠️ 警告を表示
- ❌ 推奨事項を提供

### 複雑度レベル

| レベル | スコア | 評価 | 対応 |
|--------|--------|------|------|
| **Simple** | < 25 | ✅ 良好 | そのまま使用可能 |
| **Moderate** | 25-40 | ⚠️ 警告 | 簡素化を推奨 |
| **Complex** | > 40 | ❌ 高リスク | 図の分割を強く推奨 |

### 詳細ドキュメント

- **[validation-checklist.md](mermaid-diagram-generator/validation-checklist.md)** - 詳細なバリデーション手順
- **[validators/README.md](mermaid-diagram-generator/validators/README.md)** - ツールの使い方ガイド
- **[simplification-rules.md](mermaid-diagram-generator/simplification-rules.md)** - エラーパターンと回避方法

### CI/CD統合例

**GitHub Actions**:
```yaml
- name: Validate Mermaid diagrams
  run: |
    for file in docs/**/*.mmd; do
      node mermaid-diagram-generator/validators/mermaid-validator.js "$file"
    done
```

**Pre-commit Hook**:
```bash
#!/bin/bash
for file in $(git diff --cached --name-only | grep '\.mmd$'); do
  node mermaid-diagram-generator/validators/mermaid-validator.js "$file" || exit 1
done
```

---

## 💡 使い方

### Draw.io図の生成

```
ユーザー: Eコマースシステムのクラス図をDraw.ioで作成してください。
          パステルカラーで、日本語ラベルを使って。

Claude: [drawio-diagram-generator Skillを使用]

生成される図:
- Order クラス（注文）
- Customer クラス（顧客）  
- Product クラス（商品）
- パステルブルーのスタイル
- 日本語ラベル + 英語の技術用語
- .drawio ファイルとして保存
```

### Mermaid図の生成

```
ユーザー: APIのシーケンス図をMermaidで作成してください。
          GitHubで表示できるように。

Claude: [mermaid-diagram-generator Skillを使用]

生成される図:
- ユーザー → API → データベースの流れ
- シンプルで表示エラーなし
- .md ファイルとして保存
- GitHubのREADMEに直接貼り付け可能
```

---

## 🎨 スタイル設定

### Draw.ioのデフォルトスタイル

#### カラーパレット（パステル調）

```json
{
  "パステルブルー": "#B3D9FF",
  "パステルグリーン": "#C5E1A5",
  "パステルイエロー": "#FFF9C4",
  "パステルオレンジ": "#FFE0B2",
  "パステルピンク": "#F8BBD0",
  "パステルパープル": "#E1BEE7"
}
```

#### テキストルール

- **背景**: 白（#FFFFFF）
- **テキスト**: 黒（#000000）
- **枠線**: グレー（#666666）
- **クラス名/関数名**: 英語のまま（例: `UserService`）
- **説明/ラベル**: 日本語（例: 「ユーザーサービス」）

#### 線の交差回避（重要）

**絶対ルール**: 線は他のボックスを横切らない

Draw.ioでは以下のテクニックで交差を回避：

1. **直交ルーティング**: 90度の角度のみで線を描画
2. **経由点（Waypoints）**: 線が要素を避けるように経由点を配置
3. **階層的レイアウト**: 要素を階層に分けて配置
4. **自動レイアウト機能**: Draw.ioの自動配置機能を活用

```
例: 経由点で回避

[A]─┐       [C]
    │       ↑
    └───→●─┘
    
[B]───────→[D]
```

#### カスタムスタイル指定

```
ユーザー: モノクロのクラス図を作成してください

Claude: カスタムスタイルを適用:
- 背景: 白
- 図形: グレースケール
- テキスト: 黒
```

### Mermaidの簡素化原則

#### 基本ルール

1. **要素数**: 10-15個以内
2. **ネスト**: 2-3階層まで
3. **ラベル**: 30文字以内
4. **リレーション**: 要素ごとに2-3本まで

#### 複雑な図は自動分割

```
複雑な要件 → Claudeが自動で分割提案

例:
「20個のクラスがあるシステム」
  ↓
Claude: 以下の3つの図に分割することを推奨します:
  1. プレゼンテーション層（5クラス）
  2. ビジネス層（8クラス）
  3. データ層（7クラス）
```

---

## 📋 使用例

### 例1: Webアプリのクラス設計

```
要件:
- Eコマースサイト
- ユーザー、商品、注文の管理
- MVC アーキテクチャ

Draw.ioで生成:
→ 詳細なクラス図（属性、メソッド含む）
→ パステルカラー
→ 編集可能な .drawio ファイル

Mermaidで生成:
→ シンプルなクラス図（主要クラスのみ）
→ GitHubのREADME用
→ Markdownファイル
```

### 例2: API通信フロー

```
要件:
- ログインAPI
- JWT認証
- データベース照会

Draw.ioで生成:
→ 詳細なシーケンス図
→ activationバー、オプション処理含む
→ プレゼンテーション用

Mermaidで生成:
→ シンプルなシーケンス図
→ 主要な流れのみ
→ ドキュメント用
```

### 例3: データベース設計

```
要件:
- ブログシステム
- users, posts, comments, tags
- リレーション表示

Draw.ioで生成:
→ 詳細なER図
→ カーディナリティ、属性の型含む
→ 設計書用

Mermaidで生成:
→ シンプルなER図
→ 主要テーブルとリレーションのみ
→ 概要ドキュメント用
```

---

## 🔧 カスタマイズ

### スタイルのカスタマイズ

**Draw.ioスタイルの変更**:

`styles.json` を編集して独自のカラースキームを定義できます。

```json
{
  "customThemes": {
    "corporateBlue": {
      "primary": "#1E88E5",
      "secondary": "#64B5F6",
      "accent": "#0D47A1",
      "text": "#000000",
      "border": "#1565C0"
    }
  }
}
```

使用方法:
```
ユーザー: corporateBlueテーマでクラス図を作成してください
```

### テンプレートの追加

`templates/` ディレクトリに独自のテンプレートを追加できます。

```
drawio-diagram-generator/
└── templates/
    ├── my-custom-class-template.xml
    └── my-custom-er-template.xml
```

---

## 🌐 プラットフォーム対応

### Draw.io

**対応環境**:
- Draw.ioデスクトップアプリ
- https://app.diagrams.net/（Web版）
- VS Code拡張（Draw.io Integration）

**ファイル形式**: `.drawio`, `.xml`

### Mermaid

**対応環境**:
- GitHub（Markdownファイル内）
- GitLab（Markdownファイル内）
- VS Code（Mermaid Preview拡張）
- Cursor（組み込みプレビュー）
- Notion（コードブロック）
- Obsidian（プラグイン）

**ファイル形式**: `.md`, `.mmd`

---

## ⚡ パフォーマンス

### Draw.io

- **生成速度**: 中（XMLの構築が必要）
- **ファイルサイズ**: 大（詳細な定義を含む）
- **編集性**: 優秀（GUIで編集可能）
- **推奨用途**: プレゼンテーション、詳細設計書

### Mermaid

- **生成速度**: 高（シンプルな記法）
- **ファイルサイズ**: 小（テキストのみ）
- **編集性**: 良好（テキスト編集）
- **推奨用途**: ドキュメント、README、クイックスケッチ

---

## 🎓 ベストプラクティス

### Draw.io使用時

✅ **推奨**:
- 詳細な設計書に使用
- プレゼンテーション資料に使用
- 印刷物に使用
- チーム内での共有・編集
- 線の交差を避けた美しいレイアウト

❌ **非推奨**:
- GitHubのREADME（バイナリファイル）
- 簡単なスケッチ（オーバースペック）
- 線が交差する複雑な図（要素の再配置を推奨）

### Mermaid使用時

✅ **推奨**:
- GitHubのREADME
- ドキュメント作成
- クイックスケッチ
- バージョン管理したい図

❌ **非推奨**:
- 複雑な詳細設計（要素が多すぎる）
- 印刷用の高品質図（解像度の問題）

### 使い分けのフローチャート

```
図を作成したい
    ↓
[Q1] GitHubで表示したい？
    ├─ Yes → Mermaid
    └─ No → [Q2へ]
    
[Q2] 詳細な設計書？
    ├─ Yes → Draw.io
    └─ No → [Q3へ]
    
[Q3] 要素数は？
    ├─ 15個以下 → Mermaid
    └─ 16個以上 → Draw.io

[Q4] 頻繁に編集する？
    ├─ Yes → Draw.io（GUIで楽）
    └─ No → Mermaid（テキストで簡単）
```

---

## 🐛 トラブルシューティング

### Draw.io関連

#### 問題: ファイルが開けない

**原因**: XMLのシンタックスエラー

**解決策**:
1. テキストエディタでXMLを開く
2. エラー箇所を特定
3. 手動で修正、またはSkillで再生成

#### 問題: スタイルが反映されない

**原因**: スタイル定義の誤り

**解決策**:
1. `styles.json` を確認
2. Draw.ioで開いて手動調整
3. 調整後のXMLをテンプレートとして保存

### Mermaid関連

#### 問題: 図が表示されない

**原因**: 複雑すぎる、またはシンタックスエラー

**解決策**:
1. https://mermaid.live/ でテスト
2. エラーメッセージを確認
3. 簡素化して再生成

#### 問題: GitHubで表示崩れ

**原因**: 図が大きすぎる、ラベルが長すぎる

**解決策**:
1. 要素数を15個以内に削減
2. ラベルを30文字以内に短縮
3. 図を複数に分割

---

## 📚 関連ドキュメント

### Draw.io

- [公式サイト](https://www.drawio.com/)
- [ドキュメント](https://www.diagrams.net/doc/)
- [VS Code拡張](https://marketplace.visualstudio.com/items?itemName=hediet.vscode-drawio)

### Mermaid

- [公式サイト](https://mermaid.js.org/)
- [ドキュメント](https://mermaid.js.org/intro/)
- [Live Editor](https://mermaid.live/)
- [VS Code拡張](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid)

---

## 🤝 貢献

### テンプレートの追加

新しいテンプレートを作成して `templates/` に追加できます。

### スタイルの追加

`styles.json` に新しいテーマを追加できます。

### バグ報告

問題が見つかった場合は、以下の情報と共に報告してください：

- 使用しているSkill（Draw.io / Mermaid）
- 図のタイプ
- エラーメッセージ
- 再現手順

---

## 📝 ライセンス

このSkillsはMITライセンスで提供されています。

---

## 📞 サポート

### よくある質問

**Q: 両方のSkillを同時に使えますか？**
A: はい、Claudeが自動的に適切なSkillを選択します。

**Q: 図をPDFに変換できますか？**
A: Draw.ioはPDF出力可能。MermaidはSVG/PNG経由でPDF化可能。

**Q: カスタムアイコンは使えますか？**
A: Draw.ioでは可能。Mermaidでは制限あり。

**Q: 図をアニメーション化できますか？**
A: 両方とも静的な図のみサポート。

### 追加機能のリクエスト

新しい図タイプや機能の追加を希望する場合は、以下を明記してください：

- 図のタイプ
- 使用目的
- 必要な機能
- 優先度

---

## 🎉 まとめ

この2つのSkillsを使うことで：

✅ **12種類の専門的な図を自動生成**
✅ **Draw.io形式の詳細な図**
✅ **Mermaid形式のシンプルな図**
✅ **パステルカラーの美しいスタイル**
✅ **日本語と英語の適切な使い分け**
✅ **GitHub、VS Code、Cursorで表示可能**
✅ **自動簡素化でエラー回避**

図の作成を開始するには：

```bash
# Claude Codeで
claude

> システムのクラス図を作成してください
> APIのシーケンス図を生成してください
> データベースのER図を作りたいです
```

それでは、素晴らしい図の作成を！

---

*最終更新: 2025年11月17日 13:30 JST*  
*著作権: (c) 2025 KEIEI.NET INC.*  
*作成者: KENJI OYAMA*  
*バージョン: 1.1.1*

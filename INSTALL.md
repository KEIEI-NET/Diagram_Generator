# Diagram Skills - インストールガイド

*バージョン: 1.1.0*
*最終更新: 2025年11月17日*

## 📋 目次

1. [動作環境](#動作環境)
2. [インストール方法](#インストール方法)
   - [自動インストール（推奨）](#自動インストール推奨)
   - [手動インストール](#手動インストール)
3. [アンインストール方法](#アンインストール方法)
4. [トラブルシューティング](#トラブルシューティング)
5. [アップデート方法](#アップデート方法)

---

## 動作環境

### 必須要件

- **Claude Code**: 最新版
- **OS**: 
  - Windows 10/11
  - macOS 10.15以降
  - Linux (Ubuntu 20.04以降推奨)

### オプション

- **Draw.io**: 生成された.drawioファイルを編集する場合
- **VS Code**: Mermaid図のプレビューに便利

---

## インストール方法

### 自動インストール（推奨）

#### Windows

1. **PowerShellを管理者として起動**

2. **ZIPファイルを展開**
   ```powershell
   # ダウンロードフォルダに展開
   Expand-Archive -Path diagram-skills.zip -DestinationPath $env:USERPROFILE\Downloads\diagram-skills
   ```

3. **インストールスクリプトを実行**
   ```powershell
   cd $env:USERPROFILE\Downloads\diagram-skills
   .\install.bat
   ```

4. **確認**
   ```powershell
   claude skills list
   ```
   
   以下が表示されればOK:
   ```
   drawio-diagram-generator
   mermaid-diagram-generator
   ```

#### macOS / Linux

1. **ターミナルを開く**

2. **ZIPファイルを展開**
   ```bash
   # ダウンロードフォルダに展開
   cd ~/Downloads
   unzip diagram-skills.zip
   ```

3. **インストールスクリプトを実行**
   ```bash
   cd diagram-skills
   chmod +x install.sh
   ./install.sh
   ```

4. **確認**
   ```bash
   claude skills list
   ```

---

### 手動インストール

自動インストールが失敗した場合や、カスタマイズしたい場合。

#### ステップ1: Skillsディレクトリを確認

**Windows:**
```powershell
echo $env:USERPROFILE\.claude\skills
```

**macOS / Linux:**
```bash
echo ~/.claude/skills
```

ディレクトリが存在しない場合は作成：

**Windows:**
```powershell
New-Item -ItemType Directory -Path $env:USERPROFILE\.claude\skills -Force
```

**macOS / Linux:**
```bash
mkdir -p ~/.claude/skills
```

#### ステップ2: Skillsをコピー

**Windows:**
```powershell
# Draw.io Skill
Copy-Item -Path "drawio-diagram-generator" -Destination "$env:USERPROFILE\.claude\skills\" -Recurse -Force

# Mermaid Skill
Copy-Item -Path "mermaid-diagram-generator" -Destination "$env:USERPROFILE\.claude\skills\" -Recurse -Force
```

**macOS / Linux:**
```bash
# Draw.io Skill
cp -r drawio-diagram-generator ~/.claude/skills/

# Mermaid Skill
cp -r mermaid-diagram-generator ~/.claude/skills/
```

#### ステップ3: 権限設定（macOS / Linux のみ）

```bash
chmod -R 755 ~/.claude/skills/drawio-diagram-generator
chmod -R 755 ~/.claude/skills/mermaid-diagram-generator
```

#### ステップ4: 確認

```bash
claude skills list
```

---

## アンインストール方法

### 自動アンインストール（推奨）

#### Windows

```powershell
cd $env:USERPROFILE\Downloads\diagram-skills
.\uninstall.bat
```

#### macOS / Linux

```bash
cd ~/Downloads/diagram-skills
chmod +x uninstall.sh
./uninstall.sh
```

### 手動アンインストール

#### Windows

```powershell
# Draw.io Skillを削除
Remove-Item -Path "$env:USERPROFILE\.claude\skills\drawio-diagram-generator" -Recurse -Force

# Mermaid Skillを削除
Remove-Item -Path "$env:USERPROFILE\.claude\skills\mermaid-diagram-generator" -Recurse -Force
```

#### macOS / Linux

```bash
# Draw.io Skillを削除
rm -rf ~/.claude/skills/drawio-diagram-generator

# Mermaid Skillを削除
rm -rf ~/.claude/skills/mermaid-diagram-generator
```

---

## トラブルシューティング

### 問題1: インストールスクリプトが実行できない（Windows）

**エラー**: 「このシステムではスクリプトの実行が無効になっています」

**解決策**:
```powershell
# 実行ポリシーを確認
Get-ExecutionPolicy

# RemoteSigned に変更（管理者権限が必要）
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 問題2: 文字化けする（Windows）

**原因**: コードページがUTF-8ではない

**解決策**:
```powershell
# コードページをUTF-8に変更
chcp 65001
```

または、PowerShellを使用：
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

### 問題3: 既存のSkillsが見えなくなった

**原因**: インストールに失敗した可能性

**解決策**:
```bash
# バックアップから復元
# Windows
Move-Item -Path "$env:USERPROFILE\.claude\skills_backup\*" -Destination "$env:USERPROFILE\.claude\skills\" -Force

# macOS / Linux
mv ~/.claude/skills_backup/* ~/.claude/skills/
```

### 問題4: Skillsが認識されない

**解決策**:
```bash
# Claude Codeを再起動
claude restart

# Skillsキャッシュをクリア
claude skills refresh
```

### 問題5: 権限エラー（macOS / Linux）

**エラー**: 「Permission denied」

**解決策**:
```bash
# 権限を付与
chmod -R 755 ~/.claude/skills/drawio-diagram-generator
chmod -R 755 ~/.claude/skills/mermaid-diagram-generator

# または所有者を変更
sudo chown -R $USER:$USER ~/.claude/skills/
```

### 問題6: ディレクトリが存在しない

**エラー**: 「~/.claude/skills が見つかりません」

**解決策**:
```bash
# ディレクトリを作成
# Windows
New-Item -ItemType Directory -Path $env:USERPROFILE\.claude\skills -Force

# macOS / Linux
mkdir -p ~/.claude/skills
```

---

## アップデート方法

### 方法1: 再インストール（推奨）

1. **アンインストール**
   ```bash
   ./uninstall.sh  # または uninstall.bat
   ```

2. **新しいバージョンをダウンロード**

3. **インストール**
   ```bash
   ./install.sh  # または install.bat
   ```

### 方法2: 上書きインストール

既存のSkillsを削除せずに上書き：

**Windows:**
```powershell
# Draw.io Skillを上書き
Copy-Item -Path "drawio-diagram-generator" -Destination "$env:USERPROFILE\.claude\skills\" -Recurse -Force

# Mermaid Skillを上書き
Copy-Item -Path "mermaid-diagram-generator" -Destination "$env:USERPROFILE\.claude\skills\" -Recurse -Force
```

**macOS / Linux:**
```bash
# Draw.io Skillを上書き
cp -rf drawio-diagram-generator ~/.claude/skills/

# Mermaid Skillを上書き
cp -rf mermaid-diagram-generator ~/.claude/skills/
```

---

## インストール確認

### 基本チェック

```bash
# Skillsリストを表示
claude skills list

# 期待される出力:
# drawio-diagram-generator
# mermaid-diagram-generator
```

### 動作テスト

#### Draw.io Skillのテスト

```bash
claude

> Eコマースシステムのクラス図をDraw.ioで作成してください
```

正常に動作する場合:
- [drawio-diagram-generator Skillを使用] と表示
- .drawioファイルが生成される

#### Mermaid Skillのテスト

```bash
claude

> APIのシーケンス図をMermaidで作成してください
```

正常に動作する場合:
- [mermaid-diagram-generator Skillを使用] と表示
- .mdファイルが生成される

---

## ファイル構成

インストール後のディレクトリ構造：

```
~/.claude/skills/  (Windows: %USERPROFILE%\.claude\skills\)
├── drawio-diagram-generator/
│   ├── SKILL.md
│   └── styles.json
├── mermaid-diagram-generator/
│   ├── SKILL.md
│   └── simplification-rules.md
└── [既存の他のSkills...]  ← 影響を受けない
```

---

## セキュリティ

### インストールスクリプトの安全性

- **既存Skillsの保護**: 自動的にバックアップ作成
- **ロールバック機能**: エラー時は自動で元に戻す
- **検証**: インストール後に整合性チェック

### 推奨事項

1. **信頼できるソースからダウンロード**
2. **スクリプトの内容を確認**
   ```bash
   # スクリプトを確認
   cat install.sh  # または type install.bat
   ```
3. **バックアップを取る**
   ```bash
   # 手動バックアップ
   cp -r ~/.claude/skills ~/.claude/skills_manual_backup
   ```

---

## よくある質問

### Q1: 既存のSkillsは削除されますか？

A: いいえ。このインストーラーは既存のSkillsに影響を与えません。
   diagram-skills関連のみを対象とします。

### Q2: 複数のプロジェクトで使えますか？

A: はい。`~/.claude/skills`にインストールされるため、
   全てのプロジェクトで利用可能です。

### Q3: アンインストール後に復元できますか？

A: はい。インストール時に自動作成されるバックアップから復元できます：
   ```bash
   # Windows
   Move-Item "$env:USERPROFILE\.claude\skills_backup_[timestamp]\*" "$env:USERPROFILE\.claude\skills\"
   
   # macOS / Linux
   mv ~/.claude/skills_backup_[timestamp]/* ~/.claude/skills/
   ```

### Q4: Windowsで絵文字が表示されません

A: これは正常です。Windowsバッチファイルでは絵文字を使用していません。
   インストール処理には影響ありません。

### Q5: Skill名を変更できますか？

A: 可能ですが推奨しません。名前を変更する場合：
   1. ディレクトリ名を変更
   2. SKILL.mdの`name`フィールドを更新
   3. `claude skills refresh`を実行

---

## サポート

### 問題が解決しない場合

1. **ログを確認**
   ```bash
   # インストールログ
   cat ~/.claude/skills/install.log  # Windows: type %USERPROFILE%\.claude\skills\install.log
   ```

2. **Claude Codeのログ**
   ```bash
   claude logs
   ```

3. **完全なクリーンインストール**
   ```bash
   # 1. 完全削除
   rm -rf ~/.claude/skills/drawio-diagram-generator
   rm -rf ~/.claude/skills/mermaid-diagram-generator
   
   # 2. Claude再起動
   claude restart
   
   # 3. 再インストール
   ./install.sh
   ```

---

## 付録

### A. 環境変数

以下の環境変数でインストール先をカスタマイズ可能：

```bash
# カスタムインストール先
export CLAUDE_SKILLS_DIR=/custom/path/to/skills

# 実行
./install.sh
```

### B. サイレントインストール

対話なしでインストール：

**Windows:**
```powershell
.\install.bat /SILENT
```

**macOS / Linux:**
```bash
./install.sh --silent
```

### C. デバッグモード

詳細なログを出力：

**Windows:**
```powershell
.\install.bat /DEBUG
```

**macOS / Linux:**
```bash
./install.sh --debug
```

---

## まとめ

### 標準的なインストール手順

1. ZIPファイルを展開
2. `./install.sh`（または`install.bat`）を実行
3. `claude skills list`で確認
4. テスト実行

### 標準的なアンインストール手順

1. `./uninstall.sh`（または`uninstall.bat`）を実行
2. `claude skills list`で確認

これで、Diagram Skillsのインストールは完了です！

---

*最終更新: 2025年11月17日*
*バージョン: 1.1.0*

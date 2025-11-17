# Diagram Skills - クイックスタートガイド

*所要時間: 3分*

## 🚀 最速インストール

### Windows

```powershell
# 1. ZIPを展開
Expand-Archive diagram-skills.zip

# 2. インストール
cd diagram-skills
.\install.bat

# 3. 確認
claude skills list
```

### macOS / Linux

```bash
# 1. ZIPを展開
unzip diagram-skills.zip

# 2. インストール
cd diagram-skills
./install.sh

# 3. 確認
claude skills list
```

## ✅ インストール成功の確認

以下が表示されればOK:

```
drawio-diagram-generator
mermaid-diagram-generator
```

## 🎨 使い方

### Draw.io図を作成

```bash
claude

> Eコマースシステムのクラス図をDraw.ioで作成してください
```

### Mermaid図を作成

```bash
claude

> APIのシーケンス図をMermaidで作成してください
```

## 🗑️ アンインストール

```bash
# Windows
.\uninstall.bat

# macOS / Linux
./uninstall.sh
```

## 📖 詳細ドキュメント

- **INSTALL.md** - 詳細なインストール手順
- **README.md** - 完全な機能説明
- **CHANGELOG.md** - 変更履歴

## 🆘 トラブル時

### Windowsで文字化け

```powershell
chcp 65001
.\install.bat
```

### 権限エラー（Linux/macOS）

```bash
chmod +x install.sh
sudo ./install.sh
```

### Skillsが認識されない

```bash
claude restart
claude skills refresh
```

詳細は [INSTALL.md](INSTALL.md#トラブルシューティング) を参照。

---

以上！あとは Claude に図の作成を依頼するだけです 🎉

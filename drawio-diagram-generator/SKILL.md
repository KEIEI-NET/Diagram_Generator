---
name: "drawio-diagram-generator"
description: "Draw.io形式で12種類のUML/データモデル図を生成します。ユースケース図、クラス図、シーケンス図、アクティビティ図、ステートマシン図、コンポーネント図、配置図、オブジェクト図、パッケージ図、コミュニケーション図、ER図、データモデル図の作成時に使用してください。パステルカラーのスタイル設定に対応。"
---

# Draw.io Diagram Generator Skill

## 概要

このSkillは、Draw.io（diagrams.net）形式で専門的なUML図およびデータモデル図を生成します。
細かいスタイル設定が可能で、視覚的に美しく、実用的な図を作成できます。

## 対応図タイプ（12種類）

1. **ユースケース図** - システムの機能とアクターの関係
2. **クラス図** - オブジェクト指向設計のクラス構造
3. **シーケンス図** - 時系列でのオブジェクト間相互作用
4. **アクティビティ図** - ワークフローやビジネスプロセス
5. **ステートマシン図** - オブジェクトの状態遷移
6. **コンポーネント図** - システムのコンポーネント構成
7. **配置図** - 物理的なシステム配置
8. **オブジェクト図** - 特定時点でのオブジェクトのインスタンス
9. **パッケージ図** - パッケージの依存関係
10. **コミュニケーション図** - オブジェクト間のメッセージング
11. **ER図（EER図）** - データベースのエンティティ関係
12. **データモデル図** - 論理/物理データモデル

## 使用タイミング

以下のようなリクエストで使用してください：

- 「このシステムのユースケース図を作成してください」
- 「クラス設計をDraw.ioで図にしてください」
- 「データベースのER図を生成してください」
- 「パステルカラーでシーケンス図を作りたい」

## デフォルトスタイル設定

### カラーパレット（パステル調）

```json
{
  "background": "#FFFFFF",
  "primaryColors": {
    "blue": "#B3D9FF",
    "green": "#C5E1A5", 
    "yellow": "#FFF9C4",
    "orange": "#FFE0B2",
    "pink": "#F8BBD0",
    "purple": "#E1BEE7"
  },
  "textColor": "#000000",
  "borderColor": "#666666",
  "lineColor": "#666666"
}
```

### スタイル原則

1. **背景**: 常に白（#FFFFFF）- ページ背景、mxGraphModel の background 属性
2. **図形**: パステルカラーで塗りつぶし - fillColor は必ずパステル系
3. **テキスト**: 黒（#000000）で可読性を確保 - fontColor=#000000 固定
4. **枠線**: グレー（#666666）またはパステル系で視認性を確保
5. **矢印・線**: グレー（#666666）またはパステル系
6. **線の交差回避**: 線は他のボックスを横切らない（最重要原則）
7. **黒背景の絶対禁止**: fillColor=#000000 は使用禁止（テキストが見えなくなる）
8. **要素の重なり回避**: 全ての要素（ラベル、フレーム、ノート）は最小20px以上の間隔を確保
9. **コントラスト確保**: テキストと背景のコントラスト比 4.5:1 以上（WCAG AA準拠）
10. **UMLフレームの背景**: umlFrame使用時は必ず明るい背景色を設定（#F0F8FF推奨）

### テキスト使用ルール

- **日本語優先**: ラベル、説明文は日本語
- **技術用語は英語保持**: 
  - クラス名: `UserService`（変更しない）
  - メソッド名: `getUserById()`（変更しない）
  - 変数名: `userId`（変更しない）
- **説明は日本語**: 「ユーザー情報を取得する」

## 接続点ルール（全図タイプ共通・最重要）

**絶対ルール**: 全ての矢印・線は明示的な接続点（exit/entry座標）を持つ

### 図形タイプ別接続点マップ

#### 1. 矩形系（rectangle, swimlane, roundedRectangle）

**適用図**: クラス図、コンポーネント図、オブジェクト図、パッケージ図、データモデル図

```xml
<!-- 接続点座標（0.0～1.0の正規化座標） -->
上辺中央: exitX=0.5;exitY=0;exitDx=0;exitDy=0
下辺中央: exitX=0.5;exitY=1;exitDx=0;exitDy=0
左辺中央: exitX=0;exitY=0.5;exitDx=0;exitDy=0
右辺中央: exitX=1;exitY=0.5;exitDx=0;exitDy=0

<!-- 角の座標（斜め配置時） -->
左上角: exitX=0;exitY=0;exitDx=0;exitDy=0
右上角: exitX=1;exitY=0;exitDx=0;exitDy=0
左下角: exitX=0;exitY=1;exitDx=0;exitDy=0
右下角: exitX=1;exitY=1;exitDx=0;exitDy=0
```

**使用例**:
```xml
<!-- ✅ 正しい: クラスA（下辺）→ クラスB（上辺） -->
<mxCell edge="1" source="classA" target="classB"
        style="exitX=0.5;exitY=1;exitDx=0;exitDy=0;
               entryX=0.5;entryY=0;entryDx=0;entryDy=0;
               endArrow=block;endFill=0;
               labelBackgroundColor=#FFFFFF;fontColor=#000000"/>

<!-- ❌ 間違い: 接続点未指定 -->
<mxCell edge="1" source="classA" target="classB"
        style="endArrow=block;endFill=0"/>
```

#### 2. ひし形（rhombus）

**適用図**: アクティビティ図（判断）、ER図（関係）

```xml
<!-- 接続点座標（4つの頂点） -->
上頂点: exitX=0.5;exitY=0;exitDx=0;exitDy=0
下頂点: exitX=0.5;exitY=1;exitDx=0;exitDy=0
左頂点: exitX=0;exitY=0.5;exitDx=0;exitDy=0
右頂点: exitX=1;exitY=0.5;exitDx=0;exitDy=0
```

**重要**: ひし形は**必ず**接続点を指定（中心接続は禁止）

```
✅ 正しい:        ❌ 間違い:
    ◇               ◇
   ╱ ╲             ╱│╲
  ↓   ↓           ↓ ↓ ↓
頂点から出る    中心から出る
```

**使用例**:
```xml
<!-- 判断 → アクティビティ（Yes/下へ） -->
<mxCell edge="1" source="decision1" target="activity1"
        style="exitX=0.5;exitY=1;exitDx=0;exitDy=0;
               entryX=0.5;entryY=0;entryDx=0;entryDy=0;
               labelBackgroundColor=#FFFFFF;fontColor=#000000"
        value="Yes"/>

<!-- 判断 → エラー（No/右へ） -->
<mxCell edge="1" source="decision1" target="error1"
        style="exitX=1;exitY=0.5;exitDx=0;exitDy=0;
               entryX=0;entryY=0.5;entryDx=0;entryDy=0;
               labelBackgroundColor=#FFFFFF;fontColor=#000000"
        value="No"/>
```

#### 3. 楕円（ellipse）

**適用図**: ユースケース図（ユースケース）、ER図（属性）、コンポーネント図（インターフェース）

```xml
<!-- 接続点座標 -->
上端: exitX=0.5;exitY=0;exitDx=0;exitDy=0
下端: exitX=0.5;exitY=1;exitDx=0;exitDy=0
左端: exitX=0;exitY=0.5;exitDx=0;exitDy=0
右端: exitX=1;exitY=0.5;exitDx=0;exitDy=0
```

**使用例**:
```xml
<!-- ユースケース → ユースケース（include） -->
<mxCell edge="1" source="usecase1" target="usecase2"
        style="exitX=1;exitY=0.5;exitDx=0;exitDy=0;
               entryX=0;entryY=0.5;entryDx=0;entryDy=0;
               dashed=1;endArrow=open;
               labelBackgroundColor=#FFFFFF;fontColor=#000000"
        value="&amp;lt;&amp;lt;include&amp;gt;&amp;gt;"/>
```

#### 4. アクター（umlActor）

**適用図**: ユースケース図

```xml
<!-- 接続点座標（推奨位置） -->
足元（下）: exitX=0.5;exitY=1;exitDx=0;exitDy=0
右手: exitX=1;exitY=0.3;exitDx=0;exitDy=0
左手: exitX=0;exitY=0.3;exitDx=0;exitDy=0
頭部（上）: exitX=0.5;exitY=0;exitDx=0;exitDy=0
```

**推奨**: 足元（exitY=1）からユースケースへ接続

```xml
<!-- アクター → ユースケース -->
<mxCell edge="1" source="actor1" target="usecase1"
        style="exitX=1;exitY=0.3;exitDx=0;exitDy=0;
               entryX=0;entryY=0.5;entryDx=0;entryDy=0;
               labelBackgroundColor=#FFFFFF;fontColor=#000000"/>
```

#### 5. 立方体・3D矩形（cube）

**適用図**: 配置図（ノード、デバイス）

```xml
<!-- 接続点座標（前面の辺を使用） -->
前面下辺: exitX=0.5;exitY=1;exitDx=0;exitDy=0
前面右辺: exitX=1;exitY=0.5;exitDx=0;exitDy=0
前面左辺: exitX=0;exitY=0.5;exitDx=0;exitDy=0
```

**使用例**:
```xml
<!-- ノードA → ノードB -->
<mxCell edge="1" source="nodeA" target="nodeB"
        style="exitX=1;exitY=0.5;exitDx=0;exitDy=0;
               entryX=0;entryY=0.5;entryDx=0;entryDy=0;
               labelBackgroundColor=#FFFFFF;fontColor=#000000"
        value="HTTP"/>
```

#### 6. 円形（ellipse - 開始/終了ノード）

**適用図**: アクティビティ図、ステートマシン図

```xml
<!-- 開始ノードからの出口 -->
下端: exitX=0.5;exitY=1;exitDx=0;exitDy=0

<!-- 終了ノードへの入口 -->
上端: entryX=0.5;entryY=0;entryDx=0;entryDy=0
```

**使用例**:
```xml
<!-- 開始 → 最初のアクティビティ -->
<mxCell edge="1" source="start" target="activity1"
        style="exitX=0.5;exitY=1;exitDx=0;exitDy=0;
               entryX=0.5;entryY=0;entryDx=0;entryDy=0;
               labelBackgroundColor=#FFFFFF;fontColor=#000000"/>
```

### 図タイプ別の接続パターン

#### クラス図の推奨パターン

```xml
<!-- 継承: 子クラス（上）→ 親クラス（下） -->
<mxCell edge="1" source="childClass" target="parentClass"
        style="exitX=0.5;exitY=0;exitDx=0;exitDy=0;
               entryX=0.5;entryY=1;entryDx=0;entryDy=0;
               endArrow=block;endFill=0;
               labelBackgroundColor=#FFFFFF;fontColor=#000000"/>

<!-- 関連: 横方向 -->
<mxCell edge="1" source="classA" target="classB"
        style="exitX=1;exitY=0.5;exitDx=0;exitDy=0;
               entryX=0;entryY=0.5;entryDx=0;entryDy=0;
               endArrow=open;
               labelBackgroundColor=#FFFFFF;fontColor=#000000"
        value="関連名"/>

<!-- 依存: 破線 -->
<mxCell edge="1" source="classA" target="classC"
        style="exitX=1;exitY=0.5;exitDx=0;exitDy=0;
               entryX=0;entryY=0.5;entryDx=0;entryDy=0;
               dashed=1;endArrow=open;
               labelBackgroundColor=#FFFFFF;fontColor=#000000"
        value="&amp;lt;&amp;lt;use&amp;gt;&amp;gt;"/>
```

#### アクティビティ図の推奨パターン

```xml
<!-- 順次フロー: 下方向 -->
<mxCell edge="1" source="activity1" target="activity2"
        style="exitX=0.5;exitY=1;exitDx=0;exitDy=0;
               entryX=0.5;entryY=0;entryDx=0;entryDy=0;
               labelBackgroundColor=#FFFFFF;fontColor=#000000"/>

<!-- 分岐: Yes/No -->
<!-- Yes: 下へ -->
<mxCell edge="1" source="decision" target="activityYes"
        style="exitX=0.5;exitY=1;exitDx=0;exitDy=0;
               entryX=0.5;entryY=0;entryDx=0;entryDy=0;
               labelBackgroundColor=#FFFFFF;fontColor=#000000"
        value="Yes"/>

<!-- No: 右へ -->
<mxCell edge="1" source="decision" target="activityNo"
        style="exitX=1;exitY=0.5;exitDx=0;exitDy=0;
               entryX=0;entryY=0.5;entryDx=0;entryDy=0;
               labelBackgroundColor=#FFFFFF;fontColor=#000000"
        value="No"/>
```

#### ER図の推奨パターン

```xml
<!-- エンティティ → 関係（ひし形） → エンティティ -->
<mxCell edge="1" source="entity1" target="relationship"
        style="exitX=1;exitY=0.5;exitDx=0;exitDy=0;
               entryX=0;entryY=0.5;entryDx=0;entryDy=0;
               labelBackgroundColor=#FFFFFF;fontColor=#000000"/>

<mxCell edge="1" source="relationship" target="entity2"
        style="exitX=1;exitY=0.5;exitDx=0;exitDy=0;
               entryX=0;entryY=0.5;entryDx=0;entryDy=0;
               labelBackgroundColor=#FFFFFF;fontColor=#000000"
        value="1:N"/>
```

### 接続点選択のアルゴリズム

```javascript
function selectConnectionPoint(sourceElement, targetElement) {
  // 要素の中心座標を計算
  const sourceCenter = {
    x: sourceElement.x + sourceElement.width / 2,
    y: sourceElement.y + sourceElement.height / 2
  };
  
  const targetCenter = {
    x: targetElement.x + targetElement.width / 2,
    y: targetElement.y + targetElement.height / 2
  };
  
  // 方向を判定
  const dx = targetCenter.x - sourceCenter.x;
  const dy = targetCenter.y - sourceCenter.y;
  
  const connection = {
    source: {},
    target: {}
  };
  
  // 水平方向の判定
  if (Math.abs(dx) > Math.abs(dy)) {
    // 主に横方向
    if (dx > 0) {
      // 右へ
      connection.source = { exitX: 1, exitY: 0.5 };
      connection.target = { entryX: 0, entryY: 0.5 };
    } else {
      // 左へ
      connection.source = { exitX: 0, exitY: 0.5 };
      connection.target = { entryX: 1, entryY: 0.5 };
    }
  } else {
    // 主に縦方向
    if (dy > 0) {
      // 下へ
      connection.source = { exitX: 0.5, exitY: 1 };
      connection.target = { entryX: 0.5, entryY: 0 };
    } else {
      // 上へ
      connection.source = { exitX: 0.5, exitY: 0 };
      connection.target = { entryX: 0.5, entryY: 1 };
    }
  }
  
  return connection;
}
```

### 全図タイプの接続ルール一覧表

| 図タイプ | 図形 | 形状 | 接続点 | 必須指定 |
|---------|------|------|--------|---------|
| ユースケース図 | アクター | umlActor | 足元/手 | ✅ |
| ユースケース図 | ユースケース | ellipse | 上下左右端 | ✅ |
| クラス図 | クラス | rectangle | 上下左右辺 | ✅ |
| シーケンス図 | ライフライン | rectangle | 上下辺 | ⚠️ |
| アクティビティ図 | 判断 | rhombus | 4頂点 | ✅✅ |
| アクティビティ図 | アクティビティ | roundedRect | 上下左右辺 | ✅ |
| ステートマシン図 | 状態 | roundedRect | 上下左右辺 | ✅ |
| コンポーネント図 | コンポーネント | rectangle | 上下左右辺 | ✅ |
| 配置図 | ノード | cube | 前面辺 | ✅ |
| オブジェクト図 | オブジェクト | rectangle | 上下左右辺 | ✅ |
| パッケージ図 | パッケージ | folder | 上下左右辺 | ✅ |
| ER図 | エンティティ | rectangle | 上下左右辺 | ✅ |
| ER図 | 関係 | rhombus | 4頂点 | ✅✅ |
| データモデル図 | テーブル | rectangle | 上下左右辺 | ✅ |

**凡例**: ✅✅ = 絶対必須、✅ = 必須、⚠️ = 推奨

### 接続点未指定時の問題

```xml
<!-- 問題例: 接続点未指定 -->
<mxCell edge="1" source="nodeA" target="nodeB" style="..."/>

<!-- 結果 -->
- Draw.ioがランダムに接続点を選択
- 中心から矢印が出る場合がある
- レイアウトが不安定
- 見た目が悪い
```

## 実行プロセス

### ステップ1: 要件ヒアリング

ユーザーからの情報を確認：

```
必須情報:
- 図のタイプ（12種類から選択）
- 図の目的
- 含めるべき要素

オプション情報:
- スタイル設定（デフォルトはパステル）
- 詳細レベル（簡易/標準/詳細）
- 特定の色使い
```

### ステップ2: レイアウト戦略の決定

**線の交差回避を最優先**に、最適なレイアウトを選択：

```javascript
// レイアウト戦略の選択
const layoutStrategy = {
  // 階層的レイアウト（クラス図、コンポーネント図など）
  hierarchical: {
    direction: 'TB', // Top to Bottom
    layerSpacing: 100,
    nodeSpacing: 80,
    edgeRouting: 'orthogonal' // 直交ルーティング
  },
  
  // 放射状レイアウト（ER図など）
  radial: {
    centerNode: 'main',
    radiusIncrement: 150,
    angleIncrement: 45
  },
  
  // グリッドレイアウト（複雑な図）
  grid: {
    columns: 3,
    cellWidth: 200,
    cellHeight: 150,
    edgeRouting: 'waypoint' // 経由点使用
  }
};

// 線の交差チェックと回避
function avoidEdgeCrossing(elements, edges) {
  // 1. 要素を階層的に配置
  const layers = organizeIntoLayers(elements);
  
  // 2. 各階層内で最適な順序を決定
  for (const layer of layers) {
    optimizeLayerOrder(layer, edges);
  }
  
  // 3. エッジのルーティングを最適化
  for (const edge of edges) {
    edge.routing = calculateOptimalRoute(edge, elements);
  }
  
  return { layers, edges };
}
```

### ステップ3: 図の構造設計

線の交差を避けるための配置を計算：

```javascript
// 図の要素を整理
const diagramStructure = {
  type: "class", // 図のタイプ
  elements: [
    {
      type: "class",
      name: "UserService",
      label: "ユーザーサービス",
      layer: 0, // 階層レベル
      position: { x: 100, y: 100 }, // 自動計算
      attributes: ["- userId: string"],
      methods: ["+ getUserById(): User"],
      style: "pastel-blue"
    }
  ],
  relationships: [
    {
      from: "UserService",
      to: "UserRepository", 
      type: "dependency",
      label: "使用",
      routing: "orthogonal", // 直交ルーティング
      waypoints: [ // 経由点（必要に応じて）
        { x: 150, y: 200 },
        { x: 250, y: 200 }
      ]
    }
  ]
};
```

### ステップ4: Draw.io XML生成（線の交差回避）

Draw.io形式のXMLを生成（直交ルーティングと経由点を使用）：

```xml
<mxfile host="app.diagrams.net">
  <diagram name="クラス図">
    <mxGraphModel background="#FFFFFF" grid="1" gridSize="10">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        
        <!-- クラスA（上層） -->
        <mxCell id="2" value="UserService&lt;br&gt;ユーザーサービス" 
                style="swimlane;fontStyle=1;align=center;verticalAlign=top;
                       childLayout=stackLayout;horizontal=1;startSize=40;
                       horizontalStack=0;resizeParent=1;resizeParentMax=0;
                       resizeLast=0;collapsible=1;marginBottom=0;
                       fillColor=#B3D9FF;strokeColor=#666666;fontColor=#000000"
                vertex="1" parent="1">
          <mxGeometry x="100" y="100" width="200" height="120" as="geometry"/>
        </mxCell>
        
        <!-- クラスB（中央） -->
        <mxCell id="3" value="OrderService&lt;br&gt;注文サービス"
                style="swimlane;fontStyle=1;align=center;verticalAlign=top;
                       childLayout=stackLayout;horizontal=1;startSize=40;
                       fillColor=#C5E1A5;strokeColor=#666666;fontColor=#000000"
                vertex="1" parent="1">
          <mxGeometry x="100" y="300" width="200" height="120" as="geometry"/>
        </mxCell>
        
        <!-- クラスC（右側） -->
        <mxCell id="4" value="Repository&lt;br&gt;リポジトリ"
                style="swimlane;fontStyle=1;align=center;verticalAlign=top;
                       childLayout=stackLayout;horizontal=1;startSize=40;
                       fillColor=#FFF9C4;strokeColor=#666666;fontColor=#000000"
                vertex="1" parent="1">
          <mxGeometry x="400" y="300" width="200" height="120" as="geometry"/>
        </mxCell>
        
        <!-- 関連線1: UserService → OrderService（縦方向：下へ） -->
        <mxCell id="5" value="使用" 
                style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;
                       jettySize=auto;html=1;strokeColor=#666666;strokeWidth=2;
                       endArrow=open;endFill=0;labelBackgroundColor=#FFFFFF;fontColor=#000000"
                edge="1" parent="1" source="2" target="3">
          <mxGeometry relative="1" as="geometry">
            <!-- UserServiceの下辺中央(200, 220) → OrderServiceの上辺中央(200, 300) -->
            <mxPoint x="200" y="220" as="sourcePoint"/>
            <mxPoint x="200" y="300" as="targetPoint"/>
          </mxGeometry>
        </mxCell>
        
        <!-- 関連線2: UserService → Repository（迂回ルート） -->
        <mxCell id="6" value="依存"
                style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;
                       jettySize=auto;html=1;strokeColor=#666666;strokeWidth=2;
                       dashed=1;endArrow=open;endFill=0;labelBackgroundColor=#FFFFFF;fontColor=#000000"
                edge="1" parent="1" source="2" target="4">
          <mxGeometry relative="1" as="geometry">
            <!-- 経由点を明示的に指定してOrderServiceを避ける -->
            <Array as="points">
              <mxPoint x="200" y="260"/>
              <mxPoint x="500" y="260"/>
            </Array>
          </mxGeometry>
        </mxCell>
        
        <!-- 関連線3: OrderService → Repository（横方向：右へ） -->
        <mxCell id="7" value="使用"
                style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;
                       jettySize=auto;html=1;strokeColor=#666666;strokeWidth=2;
                       endArrow=open;endFill=0;labelBackgroundColor=#FFFFFF;fontColor=#000000"
                edge="1" parent="1" source="3" target="4">
          <mxGeometry relative="1" as="geometry">
            <!-- OrderServiceの右辺中央(300, 360) → Repositoryの左辺中央(400, 360) -->
            <mxPoint x="300" y="360" as="sourcePoint"/>
            <mxPoint x="400" y="360" as="targetPoint"/>
          </mxGeometry>
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

**線の交差回避の重要ポイント**:

1. **edgeStyle="orthogonalEdgeStyle"**: 直交スタイルで線を描画（90度の角度のみ）
2. **waypoints（経由点）**: `<Array as="points">`で線が要素を避けるように経由点を配置
3. **階層的配置**: 要素を上下左右に整然と配置し、線の交差を最小化
4. **jettySize**: 線の始点・終点のオフセット距離を調整
5. **rounded=0**: 角を丸めない（交差検出を明確に）

### ステップ5: ファイル出力

```javascript
// .drawioファイルとして保存
const fs = require('fs');
const filename = `${diagramType}-${timestamp}.drawio`;
fs.writeFileSync(filename, xmlContent);
console.log(`✅ 図を生成しました: ${filename}`);
```

## 図タイプ別テンプレート

### 1. ユースケース図

**構成要素**:
- アクター（棒人間）: パステルブルー
- ユースケース（楕円）: パステルグリーン
- システム境界（矩形）: 白背景、グレー枠線
- 関連線: グレー実線

**スタイル**:
```json
{
  "actor": {
    "shape": "umlActor",
    "fillColor": "#B3D9FF",
    "strokeColor": "#666666"
  },
  "useCase": {
    "shape": "ellipse",
    "fillColor": "#C5E1A5",
    "strokeColor": "#666666"
  }
}
```

### 2. クラス図

**構成要素**:
- クラス（矩形・3分割）: パステルブルー
- インターフェース（矩形）: パステルパープル
- 抽象クラス（斜体）: パステルイエロー
- 関連線: 継承（白抜き矢印）、実装（破線矢印）、関連（実線）

**命名規則**:
```
クラス名: UserService（英語・そのまま）
日本語ラベル: ユーザーサービス
属性: - userId: string（英語・そのまま）
メソッド: + getUserById(): User（英語・そのまま）
説明: 「ユーザー情報を管理する」（日本語）
```

### 3. シーケンス図

**構成要素**:
- ライフライン（矩形）: パステルカラー（役割別）
- アクティベーションバー（細い矩形）: 同じ色の濃いめ
- メッセージ（矢印）: グレー実線
- 戻り値（矢印）: グレー破線

**配置ルール**:
- 左から右へ時系列
- 縦に均等配置（メッセージ間隔: 40-60px）
- メッセージラベルは日本語
- **ライフライン間隔**: 最小150px確保
- **フレーム/ラベルの配置**: 他の要素と最小20px以上の間隔
- **条件ラベル**: フレーム内に配置し、メッセージラインと重ならないよう上下10px以上の余白
- **アクティベーションバー**: 明るいパステル（#D6EAFF推奨）でテキストとのコントラスト確保

### 4. アクティビティ図

**構成要素**:
- 開始ノード（黒丸）: 黒 - 図の開始点のみ使用可
- 終了ノード（二重黒丸）: 黒 - 図の終了点のみ使用可
- アクティビティ（角丸矩形）: パステルグリーン
- 判断（ひし形）: パステルイエロー
- フォーク/ジョイン（太い横線）: グレー（#666666）推奨

**判断ノードの接続ルール（重要）**:

判断ノード（ひし形）から矢印を出す際は、**必ず辺から出す**（中心から出さない）：

```xml
<!-- ✅ 正しい例: 頂点座標を明示的に指定（最も確実） -->
<mxCell edge="1" source="decision1" target="next-node"
        style="edgeStyle=orthogonalEdgeStyle;strokeColor=#666666;
               labelBackgroundColor=#FFFFFF;fontColor=#000000">
  <mxGeometry relative="1" as="geometry">
    <!-- 判断ノードの右頂点から出る -->
    <mxPoint x="600" y="360" as="sourcePoint"/>
    <!-- 次のノードの左辺中央へ入る -->
    <mxPoint x="640" y="360" as="targetPoint"/>
  </mxGeometry>
</mxCell>

<!-- ⚠️ 代替方法: exit/entry属性（Draw.ioバージョンにより動作が不安定） -->
<mxCell edge="1" source="decision1" target="next-node"
        style="...;exitX=1;exitY=0.5;exitDx=0;exitDy=0">
  <!-- この方法は中心接続になる場合がある -->
</mxCell>

<!-- ❌ 悪い例: 接続点未指定（必ず中心から出る） -->
<mxCell edge="1" source="decision1" target="next-node" style="..."/>
```

**座標計算方法**:
```javascript
// ひし形の頂点座標を計算
function calculateDiamondVertices(diamond) {
  return {
    top: { 
      x: diamond.x + diamond.width / 2, 
      y: diamond.y 
    },
    bottom: { 
      x: diamond.x + diamond.width / 2, 
      y: diamond.y + diamond.height 
    },
    left: { 
      x: diamond.x, 
      y: diamond.y + diamond.height / 2 
    },
    right: { 
      x: diamond.x + diamond.width, 
      y: diamond.y + diamond.height / 2 
    }
  };
}

// 使用例
const decision1 = { x: 400, y: 310, width: 200, height: 100 };
const vertices = calculateDiamondVertices(decision1);
// vertices.right = { x: 600, y: 360 }
```

**接続点の座標**（正規化座標: 0.0～1.0）:
```javascript
const CONNECTION_POINTS = {
  // ひし形（判断ノード）
  diamond: {
    top: { exitX: 0.5, exitY: 0 },      // 上辺
    bottom: { exitX: 0.5, exitY: 1 },   // 下辺
    left: { exitX: 0, exitY: 0.5 },     // 左辺
    right: { exitX: 1, exitY: 0.5 }     // 右辺
  },
  
  // 矩形（アクティビティ）
  rectangle: {
    top: { entryX: 0.5, entryY: 0 },
    bottom: { entryX: 0.5, entryY: 1 },
    left: { entryX: 0, entryY: 0.5 },
    right: { entryX: 1, entryY: 0.5 }
  }
};
```

**配置パターン**:
```
        判断ノード
           ◇
          ╱ ╲
    Yes  ╱   ╲  No
        ↓     ↓
      [A]    [B]
      
- Yes: exitX=0.5, exitY=1（下辺）
- No: exitX=1, exitY=0.5（右辺）
```

### 5. ステートマシン図

**構成要素**:
- 状態（角丸矩形）: パステルブルー
- 初期状態（黒丸）: 黒
- 終了状態（二重黒丸）: 黒
- 遷移（矢印）: グレー実線
- イベント/条件ラベル: 日本語

### 6. コンポーネント図

**構成要素**:
- コンポーネント（矩形+アイコン）: パステルオレンジ
- インターフェース（小さい丸）: 白
- 依存関係（破線矢印）: グレー

### 7. 配置図

**構成要素**:
- ノード（3D矩形）: パステルブルー
- デバイス（専用アイコン）: パステルグリーン
- 通信パス（実線）: グレー

### 8. オブジェクト図

**構成要素**:
- オブジェクト（矩形）: パステルピンク
- 下線付きオブジェクト名: `user1: User`（英語）
- リンク（実線）: グレー

### 9. パッケージ図

**構成要素**:
- パッケージ（タブ付き矩形）: パステルイエロー
- 依存関係（破線矢印）: グレー
- インポート（破線矢印+«import»）: グレー

### 10. コミュニケーション図

**構成要素**:
- オブジェクト（矩形）: パステルブルー
- リンク（実線）: グレー
- メッセージ（リンク上のラベル）: 日本語

### 11. ER図（EER図）

**構成要素**:
- エンティティ（矩形）: パステルブルー
- 属性（楕円）: パステルグリーン
- 関連（ひし形）: パステルイエロー
- カーディナリティ: 1, N, 0..1, 1..* など

**スタイル**:
```json
{
  "entity": {
    "fillColor": "#B3D9FF",
    "strokeColor": "#666666",
    "fontStyle": "bold"
  },
  "attribute": {
    "fillColor": "#C5E1A5",
    "strokeColor": "#666666"
  },
  "relationship": {
    "fillColor": "#FFF9C4",
    "strokeColor": "#666666"
  }
}
```

### 12. データモデル図

**構成要素**:
- テーブル（矩形・3分割）: パステルブルー
  - テーブル名
  - カラム一覧
  - 制約（PK, FK, UK, NN）
- リレーション（線+カラスの足）: グレー

**テーブルスタイル**:
```xml
<mxCell style="swimlane;fontStyle=1;childLayout=stackLayout;horizontal=1;
               startSize=30;horizontalStack=0;resizeParent=1;resizeParentMax=0;
               resizeLast=0;collapsible=1;marginBottom=0;
               fillColor=#B3D9FF;strokeColor=#666666;fontColor=#000000">
  <mxGeometry width="200" height="150"/>
</mxCell>
```

## カスタムスタイル設定

ユーザーが独自のスタイルを指定する場合：

```javascript
// カスタムスタイルの例
const customStyle = {
  colorScheme: "monochrome", // モノクロ
  primaryColor: "#E3F2FD",   // 明るいブルー
  accentColor: "#FFECB3",    // 明るいイエロー
  textColor: "#212121",       // ダークグレー
  borderWidth: 2,             // 太い枠線
  fontSize: 14,               // フォントサイズ
  fontFamily: "Arial"         // フォント
};
```

## 実行例

### 例1: クラス図の生成

```
ユーザー: Eコマースシステムのクラス図を作成してください

生成される図:
- Order クラス（注文）
- Customer クラス（顧客）
- Product クラス（商品）
- OrderItem クラス（注文明細）
各クラスに属性とメソッドを含む
パステルブルーのスタイル
```

### 例2: ER図の生成

```
ユーザー: ブログシステムのER図を作成してください

生成される図:
- users エンティティ（ユーザー）
- posts エンティティ（投稿）
- comments エンティティ（コメント）
1:N, N:M の関係を表現
パステルカラーで色分け
```

## 出力形式

### ファイル名規則

```
{図タイプ}-{プロジェクト名}-{日時}.drawio

例:
- class-diagram-ecommerce-20251117-120000.drawio
- er-diagram-blog-20251117-120500.drawio
```

### ファイル構造

```
diagram-output/
├── class-diagram-ecommerce-20251117-120000.drawio
├── er-diagram-blog-20251117-120500.drawio
└── sequence-diagram-api-20251117-121000.drawio
```

## Draw.ioで開く

生成されたファイルは以下で開けます：

1. **Draw.ioデスクトップアプリ**: ダブルクリック
2. **Draw.ioウェブ版**: https://app.diagrams.net/ にドラッグ&ドロップ
3. **VS Code拡張**: Draw.io Integration拡張機能

## サポートファイル

詳細情報は以下のファイルを参照：

- `styles.json`: スタイル定義の完全版
- `templates/`: 各図タイプのテンプレート
- `examples/`: サンプル図

## 線の交差回避テクニック（最重要）

### 禁則ルール

**絶対ルール1**: 線は他のボックス（要素）を横切らない
**絶対ルール2**: 要素は互いに重ならない（最小20px間隔）
**絶対ルール3**: 黒背景（#000000）は使用禁止（テキストが見えなくなる）

これらのルールを守るために、以下のテクニックを使用します。

### 要素の重なり回避ルール

#### 1. 最小間隔の確保

```javascript
const SPACING = {
  elementMinGap: 20,        // 要素間の最小間隔
  lifelineSpacing: 150,     // ライフライン間隔
  messageSpacing: 50,       // メッセージ間隔
  frameMargin: 10,          // フレーム内の余白
  labelMargin: 10           // ラベルの余白
};
```

#### 2. 重なり検出と自動調整

```javascript
function detectAndFixOverlaps(elements) {
  let hasOverlap = true;
  let iterations = 0;
  const maxIterations = 10;
  
  while (hasOverlap && iterations < maxIterations) {
    hasOverlap = false;
    
    for (let i = 0; i < elements.length; i++) {
      for (let j = i + 1; j < elements.length; j++) {
        if (doElementsOverlap(elements[i], elements[j], 20)) {
          // 重なりを解消：下の要素を移動
          elements[j].y += 30;
          hasOverlap = true;
        }
      }
    }
    
    iterations++;
  }
  
  return elements;
}
```

#### 3. フレーム内ラベルの配置

```xml
<!-- opt/altフレーム内の条件ラベル -->
<mxCell id="frame" value="" 
        style="rounded=1;fillColor=#F0F8FF;strokeColor=#B3D9FF" 
        vertex="1" parent="1">
  <mxGeometry x="330" y="600" width="480" height="100" as="geometry"/>
</mxCell>

<!-- フレームヘッダー -->
<mxCell id="frame-header" value="opt [条件]" 
        style="fillColor=#E3F2FD;fontColor=#000000" 
        vertex="1" parent="1">
  <mxGeometry x="335" y="605" width="140" height="18" as="geometry"/>
</mxCell>

<!-- 条件ラベル: フレーム内、メッセージより上に配置 -->
<mxCell id="condition-label" value="[具体的な条件]" 
        style="fillColor=#E3F2FD;fontColor=#000000" 
        vertex="1" parent="1">
  <mxGeometry x="340" y="635" width="120" height="18" as="geometry"/>
  <!-- y=635: フレームヘッダー(605+18+12=635) -->
</mxCell>

<!-- メッセージ: ラベルより下に配置 -->
<mxCell id="message" value="処理" edge="1" parent="1">
  <mxGeometry>
    <mxPoint x="360" y="665" as="sourcePoint"/>
    <!-- y=665: ラベル(635+18+12=665) -->
  </mxGeometry>
</mxCell>
```

### 線の交差回避テクニック

### テクニック1: 階層的レイアウト

要素を階層（レイヤー）に分けて配置：

```
レイヤー0（最上層）:  [Controller A]  [Controller B]
                              ↓               ↓
レイヤー1（中間層）:  [Service A]    [Service B]
                              ↓               ↓
レイヤー2（最下層）:  [Repository A] [Repository B]
```

**メリット**:
- 上下方向の線は交差しない
- 視覚的に階層構造が明確

**実装**:
```javascript
function organizeIntoLayers(elements) {
  const layers = [];
  const visited = new Set();
  
  // 依存関係がない要素を最上層に
  for (const element of elements) {
    if (!hasDependencies(element)) {
      layers[0] = layers[0] || [];
      layers[0].push(element);
      visited.add(element.id);
    }
  }
  
  // 残りを順次配置
  let layer = 1;
  while (visited.size < elements.length) {
    layers[layer] = [];
    for (const element of elements) {
      if (!visited.has(element.id) && 
          allDependenciesInPreviousLayers(element, layers)) {
        layers[layer].push(element);
        visited.add(element.id);
      }
    }
    layer++;
  }
  
  return layers;
}
```

### テクニック2: 直交ルーティング

線を水平・垂直の90度の角度のみで描画：

```
[A]───┐
      │
      └──→[B]
```

**Draw.io設定**:
```xml
<mxCell style="edgeStyle=orthogonalEdgeStyle;rounded=0;
               orthogonalLoop=1;jettySize=auto"
        edge="1">
```

**メリット**:
- 斜め線より交差しにくい
- プロフェッショナルな見た目
- 経由点の配置が容易

### テクニック3: 経由点（Waypoints）の使用

線が要素を避けるように経由点を配置：

```
[A]───→●───→[C]
       │
       ↓
      [B]（避ける）
```

**実装例**:
```xml
<mxCell edge="1" parent="1" source="2" target="4">
  <mxGeometry relative="1" as="geometry">
    <Array as="points">
      <!-- 経由点1: 右に移動 -->
      <mxPoint x="350" y="150"/>
      <!-- 経由点2: 下に移動（Bを避ける） -->
      <mxPoint x="350" y="400"/>
      <!-- 経由点3: 左に移動してCへ -->
      <mxPoint x="200" y="400"/>
    </Array>
  </mxGeometry>
</mxCell>
```

### テクニック4: グリッド配置

要素をグリッド上に配置して規則的なレイアウトに：

```
[A]  [B]  [C]

[D]  [E]  [F]

[G]  [H]  [I]
```

**計算式**:
```javascript
function calculateGridPosition(index, columns, cellWidth, cellHeight) {
  const row = Math.floor(index / columns);
  const col = index % columns;
  
  return {
    x: col * cellWidth + margin,
    y: row * cellHeight + margin
  };
}
```

### テクニック5: 放射状配置（ER図向け）

中心に主要エンティティ、周囲に関連エンティティ：

```
        [B]
         |
    [A]─[Main]─[C]
         |
        [D]
```

**計算式**:
```javascript
function calculateRadialPosition(index, total, radius, centerX, centerY) {
  const angle = (2 * Math.PI / total) * index;
  
  return {
    x: centerX + radius * Math.cos(angle),
    y: centerY + radius * Math.sin(angle)
  };
}
```

### テクニック6: レーンの使用

複雑な図はレーン（スイムレーン）で分割：

```
┌─────────────┬─────────────┬─────────────┐
│  UI Layer   │ Business    │ Data Layer  │
├─────────────┼─────────────┼─────────────┤
│   [View]    │  [Service]  │    [DB]     │
│      ↓      │      ↓      │             │
│ [ViewModel] │  [Logic]    │ [Repository]│
└─────────────┴─────────────┴─────────────┘
```

各レーン内では線が交差せず、レーン間の線も最小限に。

### テクニック7: 自動交差検出と警告

```javascript
function detectEdgeCrossings(elements, edges) {
  const crossings = [];
  
  for (let i = 0; i < edges.length; i++) {
    for (let j = i + 1; j < edges.length; j++) {
      const edge1 = edges[i];
      const edge2 = edges[j];
      
      // 線分の交差判定
      if (doEdgesIntersect(edge1, edge2)) {
        crossings.push({ edge1, edge2 });
      }
      
      // 線が要素を横切るか判定
      for (const element of elements) {
        if (doesEdgeCrossElement(edge1, element)) {
          crossings.push({ 
            edge: edge1, 
            element, 
            type: 'edge-crosses-element' 
          });
        }
      }
    }
  }
  
  return crossings;
}

function doEdgesIntersect(edge1, edge2) {
  // 線分の交差判定アルゴリズム
  // https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection
  // ...実装...
}

function doesEdgeCrossElement(edge, element) {
  const elementBounds = {
    left: element.x,
    right: element.x + element.width,
    top: element.y,
    bottom: element.y + element.height
  };
  
  // エッジの各セグメントが要素と交差するかチェック
  for (let i = 0; i < edge.points.length - 1; i++) {
    const p1 = edge.points[i];
    const p2 = edge.points[i + 1];
    
    if (lineSegmentIntersectsRect(p1, p2, elementBounds)) {
      return true;
    }
  }
  
  return false;
}
```

### 実行フロー

```
1. 要素の階層を決定
   ↓
2. 各階層内で最適な横順序を決定
   ↓
3. グリッド/階層/放射状レイアウトを適用
   ↓
4. 線を直交ルーティングで描画
   ↓
5. 交差を検出
   ↓
6. 交差がある場合
   ├─ 経由点を追加して迂回
   ├─ 要素の位置を調整
   └─ レイアウトを再計算
   ↓
7. 交差なし → 完成
```

### 複雑な図の対応例

**Before（交差あり）**:
```
[A]────────→[C]
      ×
[B]────────→[D]
```

**After（経由点で回避）**:
```
[A]─┐       [C]
    │       ↑
    └───→●─┘
    
[B]───────→[D]
```

### Draw.io自動レイアウト機能の活用

Draw.ioには自動レイアウト機能があり、生成後にユーザーが実行可能：

```xml
<!-- 自動レイアウトのヒントを埋め込む -->
<mxGraphModel>
  <root>
    <!-- layoutStyle を指定 -->
    <mxCell id="1" parent="0" 
            style="layoutStyle=hierarchical;
                   orientation=north;
                   vertexSpacing=80;
                   edgeSpacing=50"/>
  </root>
</mxGraphModel>
```

**ユーザー向け指示**:
Draw.ioで開いた後、`Arrange → Layout → Vertical Flow` または `Horizontal Flow` を実行することで、自動的に最適なレイアウトに調整可能。

## ベストプラクティス

### 1. 適切な図の選択

- **構造を表現**: クラス図、コンポーネント図、パッケージ図
- **振る舞いを表現**: シーケンス図、アクティビティ図、ステートマシン図
- **データを表現**: ER図、データモデル図

### 2. 可読性の確保

- 1図につき要素数は30個以内
- 交差する線を最小限に
- 適切な間隔を保つ

### 3. 日本語と英語の使い分け

```
✅ 良い例:
クラス名: UserService
説明: 「ユーザーサービス - ユーザー情報を管理する」
メソッド: getUserById()
コメント: 「IDでユーザーを取得」

❌ 悪い例:
クラス名: ユーザーサービス（英語のまま使う）
メソッド: ユーザーをIDで取得する（日本語にしない）
```

## トラブルシューティング

### 問題1: 図が複雑すぎる

**解決策**: 図を分割
- 複数の図に分ける
- レイヤーを使用
- 詳細レベルを下げる

### 問題2: スタイルが反映されない

**解決策**:
- XMLのスタイル属性を確認
- Draw.ioで開いて手動調整
- テンプレートを再適用

### 問題3: 日本語が文字化け

**解決策**:
- UTF-8エンコーディングを確認
- フォントを明示的に指定
- Draw.ioの言語設定を確認

## まとめ

このSkillを使用することで：

✅ 12種類の専門的な図を生成
✅ パステルカラーの美しいスタイル
✅ 日本語と英語の適切な使い分け
✅ Draw.ioですぐに編集可能
✅ 一貫性のある図の作成

図の作成を依頼する際は、以下を明確にしてください：

1. 図のタイプ（12種類から）
2. 含める要素
3. スタイルの要望（デフォルトはパステル）
4. 詳細レベル

それでは、図の作成を開始しましょう！

#!/usr/bin/env node

/**
 * Mermaid Complexity Checker
 *
 * Mermaid図の複雑度を計算し、簡素化の推奨事項を提供
 * simplification-rules.mdのロジックを実行可能なコードとして実装
 *
 * Usage:
 *   node complexity-checker.js <file.mmd>
 *   node complexity-checker.js <file.mmd> --json
 *   node complexity-checker.js <file.mmd> --threshold 30
 *
 * @version 1.0.0
 * @author KENJI OYAMA
 * @license MIT
 */

const fs = require('fs');

class MermaidComplexityChecker {
  constructor(options = {}) {
    this.thresholds = {
      simple: options.simpleThreshold || 25,
      moderate: options.moderateThreshold || 40
    };
  }

  /**
   * Mermaidコードの複雑度をチェック
   * @param {string} code - Mermaidコード
   * @returns {object} 複雑度の詳細情報
   */
  check(code) {
    const diagramType = this.detectDiagramType(code);

    if (!diagramType) {
      return {
        error: 'ダイアグラムタイプを検出できませんでした',
        valid: false
      };
    }

    const metrics = this.extractMetrics(code, diagramType);
    const complexity = this.calculateComplexity(metrics, diagramType);
    const level = this.getComplexityLevel(complexity);
    const recommendations = this.generateRecommendations(complexity, metrics, diagramType);

    return {
      valid: true,
      diagramType,
      metrics,
      complexity: {
        score: Math.round(complexity),
        level,
        threshold: {
          simple: this.thresholds.simple,
          moderate: this.thresholds.moderate
        }
      },
      recommendations
    };
  }

  /**
   * ダイアグラムタイプを検出
   */
  detectDiagramType(code) {
    const lines = code.split('\n');

    for (const line of lines) {
      const trimmed = line.trim();

      if (trimmed.startsWith('classDiagram')) return 'class';
      if (trimmed.startsWith('sequenceDiagram')) return 'sequence';
      if (trimmed.startsWith('stateDiagram-v2')) return 'state';
      if (trimmed.startsWith('stateDiagram')) return 'state-old';
      if (trimmed.startsWith('erDiagram')) return 'er';
      if (trimmed.startsWith('flowchart')) return 'flowchart';
      if (trimmed.startsWith('graph')) return 'graph';
    }

    return null;
  }

  /**
   * メトリクスの抽出
   */
  extractMetrics(code, type) {
    const metrics = {
      elements: 0,
      relationships: 0,
      nesting: 0,
      attributes: 0,
      methods: 0,
      branches: 0,
      subgraphs: 0
    };

    switch (type) {
      case 'class':
        metrics.elements = (code.match(/^\s*class\s+\w+/gm) || []).length;
        metrics.attributes = (code.match(/[+\-#~]\w+:/g) || []).length;
        metrics.methods = (code.match(/[+\-#~]\w+\(/g) || []).length;
        metrics.relationships = (code.match(/--[>o*|]/g) || []).length + (code.match(/\.\.[>|]/g) || []).length;
        break;

      case 'sequence':
        metrics.elements = (code.match(/^\s*participant\s+/gm) || []).length;
        if (metrics.elements === 0) {
          // 暗黙の参加者をカウント
          const participants = new Set();
          const messageMatches = code.matchAll(/(\w+)\s*-[->]+\s*(\w+)/g);
          for (const match of messageMatches) {
            participants.add(match[1]);
            participants.add(match[2]);
          }
          metrics.elements = participants.size;
        }
        metrics.relationships = (code.match(/-[->]+/g) || []).length;
        metrics.nesting = this.countNesting(code, ['alt', 'loop', 'opt', 'par']);
        metrics.branches = (code.match(/^\s*(alt|opt)/gm) || []).length;
        break;

      case 'state':
      case 'state-old':
        metrics.elements = (code.match(/^\s*\[?\*\]?[\w\s]+\s*:/gm) || []).length;
        metrics.relationships = (code.match(/-->/g) || []).length;
        metrics.nesting = this.countNesting(code, ['state']);
        break;

      case 'er':
        metrics.elements = (code.match(/^\s*\w+\s*\{/gm) || []).length;
        metrics.attributes = (code.match(/^\s+\w+\s+\w+/gm) || []).length;
        metrics.relationships = (code.match(/\|[|o]\-/g) || []).length + (code.match(/\}[|o]\-/g) || []).length;
        break;

      case 'flowchart':
      case 'graph':
        metrics.elements = (code.match(/\w+\[[^\]]+\]/g) || []).length + (code.match(/\w+\([^)]+\)/g) || []).length;
        metrics.relationships = (code.match(/--[->]/g) || []).length + (code.match(/\.\.-[->]/g) || []).length;
        metrics.subgraphs = (code.match(/^\s*subgraph/gm) || []).length;
        metrics.branches = (code.match(/-->\|/g) || []).length;
        break;
    }

    return metrics;
  }

  /**
   * ネストの深さをカウント
   */
  countNesting(code, keywords) {
    let maxDepth = 0;
    let currentDepth = 0;
    const lines = code.split('\n');

    for (const line of lines) {
      const trimmed = line.trim();

      for (const keyword of keywords) {
        if (trimmed.startsWith(keyword)) {
          currentDepth++;
          maxDepth = Math.max(maxDepth, currentDepth);
        }
      }

      if (trimmed === 'end') {
        currentDepth = Math.max(0, currentDepth - 1);
      }
    }

    return maxDepth;
  }

  /**
   * 複雑度を計算
   */
  calculateComplexity(metrics, type) {
    let complexity = 0;

    switch (type) {
      case 'class':
        complexity = (metrics.elements * 1.0)
          + (metrics.attributes * 0.3)
          + (metrics.methods * 0.3)
          + (metrics.relationships * 0.5);
        break;

      case 'sequence':
        complexity = (metrics.elements * 2.0)
          + (metrics.relationships * 1.0)
          + (metrics.nesting * 5.0)
          + (metrics.branches * 3.0);
        break;

      case 'state':
      case 'state-old':
        complexity = (metrics.elements * 1.5)
          + (metrics.relationships * 1.0)
          + (metrics.nesting * 5.0);
        break;

      case 'er':
        complexity = (metrics.elements * 1.5)
          + (metrics.attributes * 0.3)
          + (metrics.relationships * 1.0);
        break;

      case 'flowchart':
      case 'graph':
        complexity = (metrics.elements * 1.0)
          + (metrics.relationships * 0.8)
          + (metrics.subgraphs * 3.0)
          + (metrics.branches * 2.0);
        break;
    }

    return complexity;
  }

  /**
   * 複雑度レベルを判定
   */
  getComplexityLevel(complexity) {
    if (complexity < this.thresholds.simple) {
      return 'simple';
    } else if (complexity < this.thresholds.moderate) {
      return 'moderate';
    } else {
      return 'complex';
    }
  }

  /**
   * 推奨事項を生成
   */
  generateRecommendations(complexity, metrics, type) {
    const recommendations = [];
    const level = this.getComplexityLevel(complexity);

    if (level === 'simple') {
      recommendations.push({
        type: 'success',
        message: '✅ 複雑度は適切です。このまま使用できます。'
      });
      return recommendations;
    }

    if (level === 'moderate') {
      recommendations.push({
        type: 'warning',
        message: '⚠️ 複雑度がやや高めです。以下の改善を検討してください。'
      });
    } else {
      recommendations.push({
        type: 'error',
        message: '❌ 複雑度が高すぎます。図を分割することを強く推奨します。'
      });
    }

    // 図タイプ別の推奨事項
    switch (type) {
      case 'class':
        if (metrics.elements > 12) {
          recommendations.push({
            type: 'suggestion',
            message: `クラス数を削減（現在: ${metrics.elements}個 → 推奨: 12個以下）`,
            action: '関連するクラスをグループ化して、複数の図に分割してください'
          });
        }
        if (metrics.attributes > metrics.elements * 5) {
          recommendations.push({
            type: 'suggestion',
            message: '属性が多すぎます',
            action: '重要な属性のみを表示し、詳細は別の図で示してください'
          });
        }
        if (metrics.relationships > 15) {
          recommendations.push({
            type: 'suggestion',
            message: `リレーションを削減（現在: ${metrics.relationships}本 → 推奨: 15本以下）`,
            action: '主要なリレーションのみを表示してください'
          });
        }
        break;

      case 'sequence':
        if (metrics.elements > 7) {
          recommendations.push({
            type: 'suggestion',
            message: `参加者を削減（現在: ${metrics.elements}人 → 推奨: 7人以下）`,
            action: '関連する参加者をグループ化するか、シナリオを分割してください'
          });
        }
        if (metrics.nesting > 2) {
          recommendations.push({
            type: 'suggestion',
            message: `ネストを削減（現在: ${metrics.nesting}階層 → 推奨: 2階層以下）`,
            action: 'alt/loop/optのネストを浅くしてください'
          });
        }
        if (metrics.relationships > 15) {
          recommendations.push({
            type: 'suggestion',
            message: `メッセージを削減（現在: ${metrics.relationships}本 → 推奨: 15本以下）`,
            action: '主要なメッセージフローのみを表示してください'
          });
        }
        break;

      case 'state':
      case 'state-old':
        if (metrics.elements > 10) {
          recommendations.push({
            type: 'suggestion',
            message: `状態を削減（現在: ${metrics.elements}個 → 推奨: 10個以下）`,
            action: '関連する状態をグループ化してください'
          });
        }
        if (metrics.nesting > 1) {
          recommendations.push({
            type: 'suggestion',
            message: `ネストを削減（現在: ${metrics.nesting}階層 → 推奨: 1階層以下）`,
            action: '複合状態を最小限にしてください'
          });
        }
        break;

      case 'er':
        if (metrics.elements > 10) {
          recommendations.push({
            type: 'suggestion',
            message: `エンティティを削減（現在: ${metrics.elements}個 → 推奨: 10個以下）`,
            action: 'データモデルを論理的に分割してください'
          });
        }
        if (metrics.attributes > metrics.elements * 8) {
          recommendations.push({
            type: 'suggestion',
            message: '属性が多すぎます',
            action: '主要な属性のみを表示してください'
          });
        }
        break;

      case 'flowchart':
      case 'graph':
        if (metrics.elements > 15) {
          recommendations.push({
            type: 'suggestion',
            message: `ノードを削減（現在: ${metrics.elements}個 → 推奨: 15個以下）`,
            action: 'プロセスを複数のフローチャートに分割してください'
          });
        }
        if (metrics.subgraphs > 3) {
          recommendations.push({
            type: 'suggestion',
            message: `サブグラフを削減（現在: ${metrics.subgraphs}個 → 推奨: 3個以下）`,
            action: 'サブグラフのネストを浅くしてください'
          });
        }
        break;
    }

    return recommendations;
  }
}

// CLI実行
if (require.main === module) {
  const args = process.argv.slice(2);

  if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
    console.log(`
Mermaid Complexity Checker

Usage:
  node complexity-checker.js <file.mmd>
  node complexity-checker.js <file.mmd> --json
  node complexity-checker.js <file.mmd> --threshold 30

Options:
  --json                JSON形式で出力
  --simple <number>     Simpleの閾値（デフォルト: 25）
  --moderate <number>   Moderateの閾値（デフォルト: 40）
  --help                このヘルプを表示

Complexity Levels:
  Simple:    < 25 点 (推奨)
  Moderate:  25-40 点 (警告)
  Complex:   > 40 点 (分割推奨)

Example:
  node complexity-checker.js diagram.mmd
  node complexity-checker.js diagram.mmd --json
  node complexity-checker.js diagram.mmd --simple 20 --moderate 35
    `);
    process.exit(0);
  }

  const filename = args.find(arg => !arg.startsWith('--'));
  const jsonOutput = args.includes('--json');

  const simpleThreshold = args.includes('--simple')
    ? parseInt(args[args.indexOf('--simple') + 1])
    : 25;

  const moderateThreshold = args.includes('--moderate')
    ? parseInt(args[args.indexOf('--moderate') + 1])
    : 40;

  if (!filename) {
    console.error('Error: ファイル名を指定してください');
    process.exit(1);
  }

  if (!fs.existsSync(filename)) {
    console.error(`Error: ファイルが見つかりません: ${filename}`);
    process.exit(1);
  }

  try {
    const code = fs.readFileSync(filename, 'utf8');
    const checker = new MermaidComplexityChecker({
      simpleThreshold,
      moderateThreshold
    });
    const result = checker.check(code);

    if (!result.valid) {
      console.error(`Error: ${result.error}`);
      process.exit(1);
    }

    if (jsonOutput) {
      console.log(JSON.stringify(result, null, 2));
    } else {
      console.log('\n=== Mermaid Complexity Analysis ===\n');
      console.log(`File: ${filename}`);
      console.log(`Diagram Type: ${result.diagramType}`);
      console.log(`\nMetrics:`);
      console.log(`  Elements: ${result.metrics.elements}`);
      if (result.metrics.relationships > 0) console.log(`  Relationships: ${result.metrics.relationships}`);
      if (result.metrics.nesting > 0) console.log(`  Max Nesting: ${result.metrics.nesting}`);
      if (result.metrics.attributes > 0) console.log(`  Attributes: ${result.metrics.attributes}`);
      if (result.metrics.methods > 0) console.log(`  Methods: ${result.metrics.methods}`);
      if (result.metrics.branches > 0) console.log(`  Branches: ${result.metrics.branches}`);
      if (result.metrics.subgraphs > 0) console.log(`  Subgraphs: ${result.metrics.subgraphs}`);

      console.log(`\nComplexity:`);
      console.log(`  Score: ${result.complexity.score}`);
      console.log(`  Level: ${result.complexity.level.toUpperCase()}`);
      console.log(`  Thresholds: Simple < ${result.complexity.threshold.simple}, Moderate < ${result.complexity.threshold.moderate}`);

      console.log(`\nRecommendations:`);
      result.recommendations.forEach((rec, i) => {
        const icon = rec.type === 'success' ? '✅' : rec.type === 'warning' ? '⚠️' : '❌';
        console.log(`  ${icon} ${rec.message}`);
        if (rec.action) {
          console.log(`     → ${rec.action}`);
        }
      });

      console.log('');
    }

    // 終了コード: Complex なら1, Simple/Moderate なら0
    process.exit(result.complexity.level === 'complex' ? 1 : 0);

  } catch (error) {
    console.error(`Error: ${error.message}`);
    process.exit(1);
  }
}

module.exports = { MermaidComplexityChecker };

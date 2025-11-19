#!/usr/bin/env node

/**
 * Mermaid Diagram Validator (Lightweight)
 *
 * 正規表現ベースの軽量バリデーター
 * mermaid.js依存性なしで基本的な構文チェックを実行
 *
 * Usage:
 *   node mermaid-validator.js <file.mmd>
 *   node mermaid-validator.js <file.mmd> --json
 *
 * @version 1.0.0
 * @author KENJI OYAMA
 * @license MIT
 */

const fs = require('fs');
const path = require('path');

class MermaidValidator {
  constructor() {
    this.errors = [];
    this.warnings = [];
    this.info = [];
  }

  /**
   * Mermaidコードをバリデート
   * @param {string} code - Mermaidコード
   * @returns {object} バリデーション結果
   */
  validate(code) {
    this.errors = [];
    this.warnings = [];
    this.info = [];

    // Phase 1: 基本構文チェック
    this.checkCodeBlock(code);
    this.checkDiagramDeclaration(code);
    this.checkComments(code);
    this.checkQuotes(code);
    this.checkArrows(code);
    this.checkSpecialChars(code);

    // Phase 2: 図タイプ別チェック
    const diagramType = this.detectDiagramType(code);
    if (diagramType) {
      this.checkDiagramSpecific(code, diagramType);
    }

    // Phase 3: 複雑度チェック
    const complexity = this.calculateComplexity(code, diagramType);
    if (complexity.level !== 'simple') {
      this.warnings.push({
        type: 'COMPLEXITY',
        message: `図の複雑度が${complexity.level}です（スコア: ${complexity.score}）`,
        recommendation: complexity.level === 'complex'
          ? '図を分割することを強く推奨します'
          : '図の簡素化を検討してください'
      });
    }

    return {
      valid: this.errors.length === 0,
      diagramType,
      complexity,
      errors: this.errors,
      warnings: this.warnings,
      info: this.info
    };
  }

  /**
   * コードブロックのチェック
   */
  checkCodeBlock(code) {
    // ```mermaid で開始しているか
    if (!code.trim().startsWith('```mermaid')) {
      this.errors.push({
        type: 'CODE_BLOCK',
        message: 'コードブロックが ```mermaid で開始していません',
        line: 1
      });
    }

    // ``` で終了しているか
    if (!code.trim().endsWith('```')) {
      this.errors.push({
        type: 'CODE_BLOCK',
        message: 'コードブロックが ``` で終了していません',
        line: code.split('\n').length
      });
    }
  }

  /**
   * ダイアグラム宣言のチェック
   */
  checkDiagramDeclaration(code) {
    const lines = code.split('\n');
    const validDeclarations = [
      'classDiagram',
      'sequenceDiagram',
      'stateDiagram-v2',
      'erDiagram',
      'flowchart TB',
      'flowchart TD',
      'flowchart LR',
      'flowchart RL',
      'graph TB',
      'graph TD',
      'graph LR',
      'graph RL'
    ];

    let foundDeclaration = false;
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim();

      // コードブロック開始とコメントをスキップ
      if (line.startsWith('```') || line.startsWith('%%')) {
        continue;
      }

      if (line) {
        foundDeclaration = validDeclarations.some(decl => line.startsWith(decl));

        if (!foundDeclaration) {
          this.errors.push({
            type: 'DIAGRAM_DECLARATION',
            message: `無効なダイアグラム宣言: "${line}"`,
            line: i + 1,
            expected: validDeclarations.join(', ')
          });
        }

        // graph は非推奨
        if (line.startsWith('graph ')) {
          this.warnings.push({
            type: 'DEPRECATED',
            message: '`graph` は非推奨です。`flowchart` の使用を推奨します',
            line: i + 1
          });
        }

        break;
      }
    }

    if (!foundDeclaration) {
      this.errors.push({
        type: 'DIAGRAM_DECLARATION',
        message: 'ダイアグラム宣言が見つかりません',
        line: 1
      });
    }
  }

  /**
   * コメントのチェック
   */
  checkComments(code) {
    const lines = code.split('\n');

    lines.forEach((line, index) => {
      // JavaScriptスタイルのコメント
      if (line.trim().startsWith('//')) {
        this.errors.push({
          type: 'INVALID_COMMENT',
          message: 'JavaScriptスタイルのコメント (//) は無効です。%% を使用してください',
          line: index + 1,
          content: line.trim()
        });
      }

      // HTMLスタイルのコメント
      if (line.includes('<!--') || line.includes('-->')) {
        this.errors.push({
          type: 'INVALID_COMMENT',
          message: 'HTMLスタイルのコメント (<!-- -->) は無効です。%% を使用してください',
          line: index + 1,
          content: line.trim()
        });
      }
    });
  }

  /**
   * 引用符のチェック
   */
  checkQuotes(code) {
    const lines = code.split('\n');

    lines.forEach((line, index) => {
      // コメント行をスキップ
      if (line.trim().startsWith('%%')) {
        return;
      }

      // " の数をチェック
      const doubleQuotes = (line.match(/"/g) || []).length;
      if (doubleQuotes % 2 !== 0) {
        this.errors.push({
          type: 'UNCLOSED_QUOTE',
          message: '閉じていないダブルクォート (") があります',
          line: index + 1,
          content: line.trim()
        });
      }

      // [ と ] のチェック
      const openBrackets = (line.match(/\[/g) || []).length;
      const closeBrackets = (line.match(/\]/g) || []).length;
      if (openBrackets !== closeBrackets) {
        this.errors.push({
          type: 'UNCLOSED_BRACKET',
          message: '閉じていないブラケット ([]) があります',
          line: index + 1,
          content: line.trim()
        });
      }
    });
  }

  /**
   * 矢印記法のチェック
   */
  checkArrows(code) {
    const lines = code.split('\n');
    const validArrows = [
      '-->',
      '--',
      '-.->',
      '-.-',
      '==>',
      '==',
      '--|>',
      '..|>',
      '--o',
      '--*',
      '->>',
      '-->>',
      '->',
      '-->',
      '..>'
    ];

    lines.forEach((line, index) => {
      // コメント行をスキップ
      if (line.trim().startsWith('%%') || line.trim().startsWith('```')) {
        return;
      }

      // 単一の > を検出（無効な矢印の可能性）
      if (line.match(/(?<!-)>(?!>)/)) {
        this.warnings.push({
          type: 'INVALID_ARROW',
          message: '無効な矢印記法の可能性: 単一の > が検出されました',
          line: index + 1,
          content: line.trim(),
          suggestion: '--> または ..> を使用してください'
        });
      }

      // 単一の - を検出（無効な矢印の可能性）
      if (line.match(/\s-\s/) && !line.includes('--')) {
        this.warnings.push({
          type: 'INVALID_ARROW',
          message: '無効な矢印記法の可能性: 単一の - が検出されました',
          line: index + 1,
          content: line.trim(),
          suggestion: '-- または --> を使用してください'
        });
      }
    });
  }

  /**
   * 特殊文字のチェック
   */
  checkSpecialChars(code) {
    const lines = code.split('\n');

    lines.forEach((line, index) => {
      // コメント行をスキップ
      if (line.trim().startsWith('%%') || line.trim().startsWith('```')) {
        return;
      }

      // ラベル内の < > をチェック
      const labelMatch = line.match(/["[]([^"\]]*)["\]]/);
      if (labelMatch && labelMatch[1]) {
        const label = labelMatch[1];

        if (label.includes('<') || label.includes('>')) {
          this.warnings.push({
            type: 'SPECIAL_CHAR',
            message: 'ラベルに特殊文字 < > が含まれています',
            line: index + 1,
            content: line.trim(),
            suggestion: '特殊文字を除去するか、引用符で囲んでください'
          });
        }

        if (label.includes('{') || label.includes('}')) {
          this.warnings.push({
            type: 'SPECIAL_CHAR',
            message: 'ラベルに特殊文字 { } が含まれています',
            line: index + 1,
            content: line.trim(),
            suggestion: '特殊文字を除去してください'
          });
        }

        // ラベルの長さチェック
        if (label.length > 30) {
          this.warnings.push({
            type: 'LONG_LABEL',
            message: `ラベルが長すぎます（${label.length}文字）`,
            line: index + 1,
            content: line.trim(),
            suggestion: '30文字以内に短縮してください'
          });
        }
      }
    });
  }

  /**
   * 図タイプの検出
   */
  detectDiagramType(code) {
    const lines = code.split('\n');

    for (const line of lines) {
      const trimmed = line.trim();

      if (trimmed.startsWith('classDiagram')) return 'class';
      if (trimmed.startsWith('sequenceDiagram')) return 'sequence';
      if (trimmed.startsWith('stateDiagram-v2')) return 'state';
      if (trimmed.startsWith('erDiagram')) return 'er';
      if (trimmed.startsWith('flowchart')) return 'flowchart';
      if (trimmed.startsWith('graph')) return 'graph';
    }

    return null;
  }

  /**
   * 図タイプ別の詳細チェック
   */
  checkDiagramSpecific(code, type) {
    switch (type) {
      case 'class':
        this.checkClassDiagram(code);
        break;
      case 'sequence':
        this.checkSequenceDiagram(code);
        break;
      case 'state':
        this.checkStateDiagram(code);
        break;
      case 'er':
        this.checkERDiagram(code);
        break;
      case 'flowchart':
      case 'graph':
        this.checkFlowchart(code);
        break;
    }
  }

  /**
   * クラス図のチェック
   */
  checkClassDiagram(code) {
    const classCount = (code.match(/^\s*class\s+\w+/gm) || []).length;

    if (classCount > 12) {
      this.warnings.push({
        type: 'TOO_MANY_ELEMENTS',
        message: `クラス数が多すぎます（${classCount}個）。推奨: 12個以下`,
        suggestion: '図を分割してください'
      });
    }

    this.info.push({
      type: 'ELEMENT_COUNT',
      message: `クラス数: ${classCount}`
    });
  }

  /**
   * シーケンス図のチェック
   */
  checkSequenceDiagram(code) {
    const participantCount = (code.match(/^\s*participant\s+/gm) || []).length;
    const messageCount = (code.match(/->>/g) || []).length + (code.match(/-->>/g) || []).length;

    if (participantCount > 7) {
      this.warnings.push({
        type: 'TOO_MANY_ELEMENTS',
        message: `参加者が多すぎます（${participantCount}人）。推奨: 7人以下`,
        suggestion: '図を分割してください'
      });
    }

    if (messageCount > 15) {
      this.warnings.push({
        type: 'TOO_MANY_ELEMENTS',
        message: `メッセージが多すぎます（${messageCount}本）。推奨: 15本以下`,
        suggestion: '不要なメッセージを削除してください'
      });
    }

    this.info.push({
      type: 'ELEMENT_COUNT',
      message: `参加者: ${participantCount}, メッセージ: ${messageCount}`
    });
  }

  /**
   * ステートマシン図のチェック
   */
  checkStateDiagram(code) {
    // stateDiagram-v2 の確認
    if (!code.includes('stateDiagram-v2')) {
      this.errors.push({
        type: 'INVALID_VERSION',
        message: 'stateDiagram は非推奨です。stateDiagram-v2 を使用してください'
      });
    }

    const stateCount = (code.match(/^\s*\w+\s*:/gm) || []).length;

    if (stateCount > 10) {
      this.warnings.push({
        type: 'TOO_MANY_ELEMENTS',
        message: `状態が多すぎます（${stateCount}個）。推奨: 10個以下`,
        suggestion: '図を分割してください'
      });
    }

    this.info.push({
      type: 'ELEMENT_COUNT',
      message: `状態数: ${stateCount}`
    });
  }

  /**
   * ER図のチェック
   */
  checkERDiagram(code) {
    const entityCount = (code.match(/^\s*\w+\s+\{/gm) || []).length;

    if (entityCount > 10) {
      this.warnings.push({
        type: 'TOO_MANY_ELEMENTS',
        message: `エンティティが多すぎます（${entityCount}個）。推奨: 10個以下`,
        suggestion: '図を分割してください'
      });
    }

    this.info.push({
      type: 'ELEMENT_COUNT',
      message: `エンティティ数: ${entityCount}`
    });
  }

  /**
   * フローチャートのチェック
   */
  checkFlowchart(code) {
    const nodeCount = (code.match(/\[[^\]]+\]/g) || []).length;

    if (nodeCount > 15) {
      this.warnings.push({
        type: 'TOO_MANY_ELEMENTS',
        message: `ノードが多すぎます（${nodeCount}個）。推奨: 15個以下`,
        suggestion: '図を分割してください'
      });
    }

    this.info.push({
      type: 'ELEMENT_COUNT',
      message: `ノード数: ${nodeCount}`
    });
  }

  /**
   * 複雑度の計算
   */
  calculateComplexity(code, type) {
    let score = 0;

    switch (type) {
      case 'class':
        const classCount = (code.match(/^\s*class\s+\w+/gm) || []).length;
        const attrCount = (code.match(/[+\-#~]\w+:/g) || []).length;
        const methodCount = (code.match(/[+\-#~]\w+\(/g) || []).length;
        const relationCount = (code.match(/--[>o*|]/g) || []).length;
        score = (classCount * 1.0) + (attrCount * 0.3) + (methodCount * 0.3) + (relationCount * 0.5);
        break;

      case 'sequence':
        const participants = (code.match(/^\s*participant\s+/gm) || []).length;
        const messages = (code.match(/->>/g) || []).length;
        const nesting = (code.match(/^\s*(alt|loop|opt)/gm) || []).length;
        score = (participants * 2.0) + (messages * 1.0) + (nesting * 5.0);
        break;

      case 'state':
        const states = (code.match(/^\s*\w+\s*:/gm) || []).length;
        const transitions = (code.match(/-->/g) || []).length;
        score = (states * 1.5) + (transitions * 1.0);
        break;

      case 'er':
        const entities = (code.match(/^\s*\w+\s+\{/gm) || []).length;
        const attributes = (code.match(/^\s+\w+\s+\w+/gm) || []).length;
        const relationships = (code.match(/\|[|o]\-/g) || []).length;
        score = (entities * 1.5) + (attributes * 0.3) + (relationships * 1.0);
        break;

      case 'flowchart':
      case 'graph':
        const nodes = (code.match(/\[[^\]]+\]/g) || []).length;
        const edges = (code.match(/-->/g) || []).length;
        score = (nodes * 1.0) + (edges * 0.8);
        break;

      default:
        score = 0;
    }

    let level = 'simple';
    if (score >= 40) {
      level = 'complex';
    } else if (score >= 25) {
      level = 'moderate';
    }

    return { score: Math.round(score), level };
  }
}

// CLI実行
if (require.main === module) {
  const args = process.argv.slice(2);

  if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
    console.log(`
Mermaid Diagram Validator (Lightweight)

Usage:
  node mermaid-validator.js <file.mmd>
  node mermaid-validator.js <file.mmd> --json

Options:
  --json    JSON形式で出力
  --help    このヘルプを表示

Example:
  node mermaid-validator.js diagram.mmd
  node mermaid-validator.js diagram.mmd --json
    `);
    process.exit(0);
  }

  const filename = args.find(arg => !arg.startsWith('--'));
  const jsonOutput = args.includes('--json');

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
    const validator = new MermaidValidator();
    const result = validator.validate(code);

    if (jsonOutput) {
      console.log(JSON.stringify(result, null, 2));
    } else {
      console.log('\n=== Mermaid Diagram Validation ===\n');
      console.log(`File: ${filename}`);
      console.log(`Diagram Type: ${result.diagramType || 'Unknown'}`);
      console.log(`Complexity: ${result.complexity.level} (score: ${result.complexity.score})`);
      console.log(`Status: ${result.valid ? '✅ VALID' : '❌ INVALID'}\n`);

      if (result.errors.length > 0) {
        console.log('🚫 ERRORS:');
        result.errors.forEach((err, i) => {
          console.log(`  ${i + 1}. [${err.type}] ${err.message}`);
          if (err.line) console.log(`     Line: ${err.line}`);
          if (err.content) console.log(`     Content: ${err.content}`);
          if (err.expected) console.log(`     Expected: ${err.expected}`);
          console.log('');
        });
      }

      if (result.warnings.length > 0) {
        console.log('⚠️  WARNINGS:');
        result.warnings.forEach((warn, i) => {
          console.log(`  ${i + 1}. [${warn.type}] ${warn.message}`);
          if (warn.line) console.log(`     Line: ${warn.line}`);
          if (warn.content) console.log(`     Content: ${warn.content}`);
          if (warn.suggestion) console.log(`     Suggestion: ${warn.suggestion}`);
          console.log('');
        });
      }

      if (result.info.length > 0) {
        console.log('ℹ️  INFO:');
        result.info.forEach((info, i) => {
          console.log(`  ${i + 1}. [${info.type}] ${info.message}`);
        });
        console.log('');
      }

      if (result.valid && result.warnings.length === 0) {
        console.log('✅ バリデーション成功！すべてのチェックをパスしました。\n');
      }
    }

    // 終了コード: エラーがあれば1, なければ0
    process.exit(result.valid ? 0 : 1);

  } catch (error) {
    console.error(`Error: ${error.message}`);
    process.exit(1);
  }
}

module.exports = { MermaidValidator };

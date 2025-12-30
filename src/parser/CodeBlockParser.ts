import {
	NotationElement,
	Action,
	OracleQuestion,
	MechanicsRoll,
	OracleResult,
	Consequence,
	TableLookup,
	Generator,
	MetaNote,
} from '../types/notation';

/**
 * Parse notation elements within code blocks
 */
export class CodeBlockParser {
	/**
	 * Parse a code block and extract notation elements
	 */
	parseCodeBlock(content: string, startLine: number): NotationElement[] {
		const elements: NotationElement[] = [];
		const lines = content.split('\n');

		for (let i = 0; i < lines.length; i++) {
			const line = lines[i].trim();
			const lineNumber = startLine + i;

			// Skip empty lines
			if (!line) continue;

			// Parse based on prefix
			if (line.startsWith('> ')) {
				elements.push(this.parseAction(line, lineNumber));
			} else if (line.startsWith('?')) {
				elements.push(this.parseOracleQuestion(line, lineNumber));
			} else if (line.startsWith('d:')) {
				elements.push(this.parseMechanicsRoll(line, lineNumber));
			} else if (line.startsWith('->')) {
				elements.push(this.parseOracleResult(line, lineNumber));
			} else if (line.startsWith('=>')) {
				elements.push(this.parseConsequence(line, lineNumber));
			} else if (line.startsWith('tbl:')) {
				elements.push(this.parseTableLookup(line, lineNumber));
			} else if (line.startsWith('gen:')) {
				elements.push(this.parseGenerator(line, lineNumber));
			} else if (line.startsWith('(') && line.includes(':') && line.endsWith(')')) {
				// Potential meta note
				const metaNote = this.parseMetaNote(line, lineNumber);
				if (metaNote) {
					elements.push(metaNote);
				} else {
					elements.push(this.parseTextLine(line, lineNumber));
				}
			} else {
				// Parse other lines (bare tags, dialogue, narrative)
				// These will still be scanned for tags by NotationParser
				elements.push(this.parseTextLine(line, lineNumber));
			}
		}

		return elements;
	}

	/**
	 * Parse action line (> action)
	 */
	private parseAction(line: string, lineNumber: number): Action {
		const content = line.substring(1).trim(); // Remove '>'
		return {
			type: 'action',
			content,
			lineNumber,
		};
	}

	/**
	 * Parse oracle question (? question)
	 */
	private parseOracleQuestion(line: string, lineNumber: number): OracleQuestion {
		const question = line.substring(1).trim(); // Remove '?'
		return {
			type: 'oracle_question',
			question,
			lineNumber,
		};
	}

	/**
	 * Parse mechanics roll (d: roll => outcome)
	 */
	private parseMechanicsRoll(line: string, lineNumber: number): MechanicsRoll {
		const content = line.substring(2).trim(); // Remove 'd:'

		// Split by '=>'
		const parts = content.split('=>').map(p => p.trim());
		const roll = parts[0] || '';
		const outcome = parts[1] || '';

		// Try to determine success
		const success = this.determineSuccess(outcome);

		return {
			type: 'mechanics_roll',
			roll,
			outcome,
			success,
			lineNumber,
		};
	}

	/**
	 * Parse oracle result (-> answer)
	 */
	private parseOracleResult(line: string, lineNumber: number): OracleResult {
		const content = line.substring(2).trim(); // Remove '->'

		// Extract roll if present (in parentheses)
		const rollMatch = content.match(/\(([^)]+)\)/);
		const roll = rollMatch ? rollMatch[1] : undefined;
		const answer = roll ? content.replace(/\s*\([^)]+\)/, '').trim() : content;

		return {
			type: 'oracle_result',
			answer,
			roll,
			lineNumber,
		};
	}

	/**
	 * Parse consequence (=> description)
	 */
	private parseConsequence(line: string, lineNumber: number): Consequence {
		const description = line.substring(2).trim(); // Remove '=>'
		return {
			type: 'consequence',
			description,
			lineNumber,
		};
	}

	/**
	 * Parse table lookup line (tbl: roll => result)
	 */
	private parseTableLookup(line: string, lineNumber: number): TableLookup {
		const content = line.substring(4).trim(); // Remove 'tbl:'

		// Split by '=>'
		const parts = content.split('=>').map(p => p.trim());
		const roll = parts[0] || '';
		const result = parts[1] || '';

		return {
			type: 'table_lookup',
			roll,
			result,
			lineNumber,
		};
	}

	/**
	 * Parse generator line (gen: system rolls => result)
	 */
	private parseGenerator(line: string, lineNumber: number): Generator {
		const content = line.substring(4).trim(); // Remove 'gen:'

		// Split by '=>'
		const parts = content.split('=>').map(p => p.trim());
		const beforeArrow = parts[0] || '';
		const result = parts[1] || '';

		// Try to extract system name and rolls
		// Format: "System roll1 roll2 => result"
		// For now, store the entire before-arrow content as system
		const system = beforeArrow;

		return {
			type: 'generator',
			system,
			rolls: '',
			result,
			lineNumber,
		};
	}

	/**
	 * Parse meta note (note: content)
	 * Returns null if not a valid meta note pattern
	 */
	private parseMetaNote(line: string, lineNumber: number): MetaNote | null {
		// Pattern: (category: content)
		const match = line.match(/^\((note|reflection|house rule|reminder|question):\s*(.+)\)$/i);

		if (!match) {
			return null;
		}

		const categoryRaw = match[1].toLowerCase().replace(/\s+/g, '_');
		const category = (['note', 'reflection', 'house_rule', 'reminder', 'question'].includes(categoryRaw)
			? categoryRaw
			: 'other') as MetaNote['category'];

		const content = match[2].trim();

		return {
			type: 'meta_note',
			category,
			content,
			lineNumber,
		};
	}

	/**
	 * Parse other text lines (bare tags, dialogue, narrative, etc.)
	 */
	private parseTextLine(line: string, lineNumber: number): any {
		return {
			type: 'text',
			content: line,
			lineNumber,
		};
	}

	/**
	 * Try to determine if a roll was successful
	 */
	private determineSuccess(outcome: string): boolean | null {
		const outcomeLower = outcome.toLowerCase();

		// Check for explicit success indicators
		if (outcomeLower.includes('success') || outcomeLower.includes(' s') || outcomeLower === 's') {
			return true;
		}

		// Check for explicit failure indicators
		if (outcomeLower.includes('fail') || outcomeLower.includes(' f') || outcomeLower === 'f') {
			return false;
		}

		// Check for strong hit, weak hit, miss (PbtA/Ironsworn)
		if (outcomeLower.includes('strong') || outcomeLower.includes('hit') && !outcomeLower.includes('weak')) {
			return true;
		}
		if (outcomeLower.includes('miss')) {
			return false;
		}

		// Can't determine
		return null;
	}
}

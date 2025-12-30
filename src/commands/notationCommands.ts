import { App, Editor, MarkdownView, Notice } from 'obsidian';
import { TemplateManager } from '../templates/TemplateManager';
import { getSnippets } from '../templates/snippets';

/**
 * Register all Solo RPG Notation commands
 */
export function registerNotationCommands(
	app: App,
	plugin: any,
	templateManager: TemplateManager
) {
	// Insert Campaign Template
	plugin.addCommand({
		id: 'insert-campaign-template',
		name: 'Insert Campaign Template',
		editorCallback: async (editor: Editor, view: MarkdownView) => {
			try {
				const template = await templateManager.getCampaignTemplate();
				const variables = templateManager.getDefaultVariables();
				const filled = templateManager.fillTemplate(template, variables);
				editor.replaceRange(filled, editor.getCursor());
				new Notice('✓ Campaign template inserted');
			} catch (error) {
				console.error('Error inserting campaign template:', error);
				const errorMsg = error instanceof Error ? error.message : 'Unknown error';
				new Notice(`Could not insert campaign template: ${errorMsg}`);
			}
		}
	});

	// Insert Session Template
	plugin.addCommand({
		id: 'insert-session-template',
		name: 'Insert Session Template',
		editorCallback: async (editor: Editor, view: MarkdownView) => {
			try {
				const template = await templateManager.getSessionTemplate();
				const variables = templateManager.getDefaultVariables();
				const filled = templateManager.fillTemplate(template, variables);
				editor.replaceRange(filled, editor.getCursor());
				new Notice('✓ Session template inserted');
			} catch (error) {
				console.error('Error inserting session template:', error);
				const errorMsg = error instanceof Error ? error.message : 'Unknown error';
				new Notice(`Could not insert session template: ${errorMsg}`);
			}
		}
	});

	// Insert Scene Template
	plugin.addCommand({
		id: 'insert-scene-template',
		name: 'Insert Scene Template',
		editorCallback: async (editor: Editor, view: MarkdownView) => {
			try {
				const template = await templateManager.getSceneTemplate();
				const variables = templateManager.getDefaultVariables();
				const filled = templateManager.fillTemplate(template, variables);
				editor.replaceRange(filled, editor.getCursor());
				new Notice('✓ Scene template inserted');
			} catch (error) {
				console.error('Error inserting scene template:', error);
				const errorMsg = error instanceof Error ? error.message : 'Unknown error';
				new Notice(`Could not insert scene template: ${errorMsg}`);
			}
		}
	});

	// Insert Action Snippet
	plugin.addCommand({
		id: 'insert-action-snippet',
		name: 'Insert Action Snippet',
		editorCallback: (editor: Editor) => {
			const snippet = '> action\nd: roll => outcome\n=> consequence';
			editor.replaceRange(snippet, editor.getCursor());
		}
	});

	// Insert Oracle Snippet
	plugin.addCommand({
		id: 'insert-oracle-snippet',
		name: 'Insert Oracle Snippet',
		editorCallback: (editor: Editor) => {
			const snippet = '? question\n-> answer\n=> consequence';
			editor.replaceRange(snippet, editor.getCursor());
		}
	});

	// Insert NPC Tag
	plugin.addCommand({
		id: 'insert-npc-tag',
		name: 'Insert NPC Tag',
		editorCallback: (editor: Editor) => {
			const snippet = '[N:Name|tags]';
			editor.replaceRange(snippet, editor.getCursor());
		}
	});

	// Insert Location Tag
	plugin.addCommand({
		id: 'insert-location-tag',
		name: 'Insert Location Tag',
		editorCallback: (editor: Editor) => {
			const snippet = '[L:Name|tags]';
			editor.replaceRange(snippet, editor.getCursor());
		}
	});

	// Insert Thread Tag
	plugin.addCommand({
		id: 'insert-thread-tag',
		name: 'Insert Thread Tag',
		editorCallback: (editor: Editor) => {
			const snippet = '[Thread:Name|Open]';
			editor.replaceRange(snippet, editor.getCursor());
		}
	});

	// Insert Clock
	plugin.addCommand({
		id: 'insert-clock',
		name: 'Insert Clock',
		editorCallback: (editor: Editor) => {
			const snippet = '[Clock:Name 0/6]';
			editor.replaceRange(snippet, editor.getCursor());
		}
	});

	// Insert Track
	plugin.addCommand({
		id: 'insert-track',
		name: 'Insert Track',
		editorCallback: (editor: Editor) => {
			const snippet = '[Track:Name 0/10]';
			editor.replaceRange(snippet, editor.getCursor());
		}
	});

	// Insert Timer
	plugin.addCommand({
		id: 'insert-timer',
		name: 'Insert Timer',
		editorCallback: (editor: Editor) => {
			const snippet = '[Timer:Name 5]';
			editor.replaceRange(snippet, editor.getCursor());
		}
	});

	// Insert Action Symbol (>)
	plugin.addCommand({
		id: 'insert-action-symbol',
		name: 'Insert Action Symbol (>)',
		editorCallback: (editor: Editor) => {
			const cursor = editor.getCursor();
			editor.replaceRange('> ', cursor);
			editor.setCursor({
				line: cursor.line,
				ch: cursor.ch + 2
			});
		}
	});

	// Insert Oracle Question Symbol (?)
	plugin.addCommand({
		id: 'insert-oracle-question-symbol',
		name: 'Insert Oracle Question Symbol (?)',
		editorCallback: (editor: Editor) => {
			const cursor = editor.getCursor();
			editor.replaceRange('? ', cursor);
			editor.setCursor({
				line: cursor.line,
				ch: cursor.ch + 2
			});
		}
	});

	// Insert Mechanics Roll Symbol (d:)
	plugin.addCommand({
		id: 'insert-mechanics-roll-symbol',
		name: 'Insert Mechanics Roll Symbol (d:)',
		editorCallback: (editor: Editor) => {
			const cursor = editor.getCursor();
			editor.replaceRange('d: ', cursor);
			editor.setCursor({
				line: cursor.line,
				ch: cursor.ch + 3
			});
		}
	});

	// Insert Oracle Result Symbol (->)
	plugin.addCommand({
		id: 'insert-oracle-result-symbol',
		name: 'Insert Oracle Result Symbol (->)',
		editorCallback: (editor: Editor) => {
			const cursor = editor.getCursor();
			editor.replaceRange('-> ', cursor);
			editor.setCursor({
				line: cursor.line,
				ch: cursor.ch + 3
			});
		}
	});

	// Insert Consequence Symbol (=>)
	plugin.addCommand({
		id: 'insert-consequence-symbol',
		name: 'Insert Consequence Symbol (=>)',
		editorCallback: (editor: Editor) => {
			const cursor = editor.getCursor();
			editor.replaceRange('=> ', cursor);
			editor.setCursor({
				line: cursor.line,
				ch: cursor.ch + 3
			});
		}
	});

	// List all snippets
	plugin.addCommand({
		id: 'list-snippets',
		name: 'List All Snippets',
		callback: () => {
			const snippets = getSnippets();
			const message = snippets.map(s => `${s.trigger}: ${s.description}`).join('\n');
			console.log('Available snippets:\n' + message);
			new Notice('Check console for snippet list');
		}
	});
}

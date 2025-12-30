import { App, TFile } from 'obsidian';
import { SoloRPGSettings } from '../settings';

// Default templates as embedded strings
const CAMPAIGN_TEMPLATE = `---
title: {{title}}
ruleset: {{ruleset}}
genre: {{genre}}
player: {{player}}
pcs: {{pcs}}
start_date: {{start_date}}
last_update: {{last_update}}
tools: {{tools}}
themes: {{themes}}
tone: {{tone}}
notes: {{notes}}
---

# {{title}}

## Session 1
*Date: {{date}} | Duration: {{duration}}*

**Recap:** First session

**Goals:** {{goals}}

### S1 *{{scene_context}}*

\`\`\`
> {{action}}
d: {{roll}} => {{outcome}}
=> {{consequence}}
\`\`\`

{{narrative}}
`;

const SESSION_TEMPLATE = `## Session {{session_number}}
*Date: {{date}} | Duration: {{duration}}*

**Recap:** {{recap}}

**Goals:** {{goals}}

### S{{scene_number}} *{{scene_context}}*

\`\`\`
{{notation}}
\`\`\`
`;

const SCENE_TEMPLATE = `### S{{scene_number}} *{{scene_context}}*

\`\`\`
> {{action}}
d: {{roll}} => {{outcome}}
=> {{consequence}}

? {{question}}
-> {{answer}}
=> {{consequence}}
\`\`\`

{{narrative}}
`;

/**
 * Manages templates for campaigns, sessions, and scenes
 */
export class TemplateManager {
	app: App;
	settings: SoloRPGSettings;

	constructor(app: App, settings: SoloRPGSettings) {
		this.app = app;
		this.settings = settings;
	}

	/**
	 * Get campaign template (custom or default)
	 */
	async getCampaignTemplate(): Promise<string> {
		if (this.settings.useDefaultTemplates || !this.settings.campaignTemplatePath) {
			return this.getDefaultCampaignTemplate();
		}
		return await this.loadCustomTemplate(this.settings.campaignTemplatePath);
	}

	/**
	 * Get session template (custom or default)
	 */
	async getSessionTemplate(): Promise<string> {
		if (this.settings.useDefaultTemplates || !this.settings.sessionTemplatePath) {
			return this.getDefaultSessionTemplate();
		}
		return await this.loadCustomTemplate(this.settings.sessionTemplatePath);
	}

	/**
	 * Get scene template (custom or default)
	 */
	async getSceneTemplate(): Promise<string> {
		if (this.settings.useDefaultTemplates || !this.settings.sceneTemplatePath) {
			return this.getDefaultSceneTemplate();
		}
		return await this.loadCustomTemplate(this.settings.sceneTemplatePath);
	}

	/**
	 * Fill template with variables
	 */
	fillTemplate(template: string, variables: Record<string, string>): string {
		let result = template;

		// Replace {{variable}} placeholders
		for (const [key, value] of Object.entries(variables)) {
			const regex = new RegExp(`\\{\\{${key}\\}\\}`, 'g');
			result = result.replace(regex, value);
		}

		// Replace any remaining placeholders with empty string or prompt
		result = result.replace(/\{\{([^}]+)\}\}/g, (match, key) => {
			return `{{${key}}}`;  // Keep placeholder for user to fill
		});

		return result;
	}

	/**
	 * Get default campaign template
	 */
	private getDefaultCampaignTemplate(): string {
		return CAMPAIGN_TEMPLATE;
	}

	/**
	 * Get default session template
	 */
	private getDefaultSessionTemplate(): string {
		return SESSION_TEMPLATE;
	}

	/**
	 * Get default scene template
	 */
	private getDefaultSceneTemplate(): string {
		return SCENE_TEMPLATE;
	}

	/**
	 * Load custom template from file
	 */
	private async loadCustomTemplate(path: string): Promise<string> {
		try {
			const file = this.app.vault.getAbstractFileByPath(path);
			if (file instanceof TFile) {
				return await this.app.vault.read(file);
			}
			console.warn(`Custom template not found: ${path}, using default`);
			return '';
		} catch (error) {
			console.error(`Error loading custom template: ${error}`);
			return '';
		}
	}

	/**
	 * Get template variables with current date and defaults
	 */
	getDefaultVariables(): Record<string, string> {
		const now = new Date();
		const dateStr = now.toISOString().split('T')[0]; // YYYY-MM-DD

		return {
			date: dateStr,
			start_date: dateStr,
			last_update: dateStr,
			title: 'New Campaign',
			ruleset: 'System',
			genre: 'Genre',
			player: 'Player Name',
			pcs: 'PC Name',
			tools: 'Oracles and tools',
			themes: 'Themes',
			tone: 'Tone',
			notes: 'Notes',
			duration: '2h',
			session_number: '1',
			scene_number: '1',
			scene_context: 'Scene description',
			goals: 'Session goals',
			recap: 'Session recap',
			action: 'action',
			roll: 'roll',
			outcome: 'outcome',
			consequence: 'consequence',
			question: 'question',
			answer: 'answer',
			notation: '> action\nd: roll => outcome\n=> consequence',
			narrative: 'Narrative goes here...',
		};
	}
}

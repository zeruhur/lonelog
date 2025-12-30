import { App, PluginSettingTab, Setting } from 'obsidian';
import SoloRPGNotationPlugin from './main';

export interface SoloRPGSettings {
	// General
	enableAutoCompletion: boolean;
	enableIndexing: boolean;

	// Templates
	campaignTemplatePath: string;
	sessionTemplatePath: string;
	sceneTemplatePath: string;
	useDefaultTemplates: boolean;

	// Parsing
	parseOnFileOpen: boolean;
	parseOnFileSave: boolean;
	indexCacheExpiry: number; // minutes

	// Views
	showDashboardOnStartup: boolean;
	dashboardRefreshInterval: number; // seconds

	// Display
	showProgressBars: boolean;
	clockStyle: 'circle' | 'bar' | 'segments';
	theme: 'auto' | 'light' | 'dark';

	// Advanced
	debugMode: boolean;
	customSnippetsPath: string;
}

export const DEFAULT_SETTINGS: SoloRPGSettings = {
	enableAutoCompletion: true,
	enableIndexing: true,

	campaignTemplatePath: '',
	sessionTemplatePath: '',
	sceneTemplatePath: '',
	useDefaultTemplates: true,

	parseOnFileOpen: true,
	parseOnFileSave: true,
	indexCacheExpiry: 30,

	showDashboardOnStartup: false,
	dashboardRefreshInterval: 30,

	showProgressBars: true,
	clockStyle: 'circle',
	theme: 'auto',

	debugMode: false,
	customSnippetsPath: '',
};

export class SoloRPGSettingTab extends PluginSettingTab {
	plugin: SoloRPGNotationPlugin;

	constructor(app: App, plugin: SoloRPGNotationPlugin) {
		super(app, plugin);
		this.plugin = plugin;
	}

	display(): void {
		const { containerEl } = this;

		containerEl.empty();

		// Header
		containerEl.createEl('h2', { text: 'Solo RPG Notation Settings' });

		// General Section
		containerEl.createEl('h3', { text: 'General' });

		new Setting(containerEl)
			.setName('Enable auto-completion')
			.setDesc('Enable auto-completion for notation patterns')
			.addToggle(toggle => toggle
				.setValue(this.plugin.settings.enableAutoCompletion)
				.onChange(async (value) => {
					this.plugin.settings.enableAutoCompletion = value;
					await this.plugin.saveSettings();
				}));

		new Setting(containerEl)
			.setName('Enable indexing')
			.setDesc('Index campaign files to track NPCs, locations, threads, etc.')
			.addToggle(toggle => toggle
				.setValue(this.plugin.settings.enableIndexing)
				.onChange(async (value) => {
					this.plugin.settings.enableIndexing = value;
					await this.plugin.saveSettings();
				}));

		// Templates Section
		containerEl.createEl('h3', { text: 'Templates' });

		new Setting(containerEl)
			.setName('Use default templates')
			.setDesc('Use built-in templates for campaigns, sessions, and scenes')
			.addToggle(toggle => toggle
				.setValue(this.plugin.settings.useDefaultTemplates)
				.onChange(async (value) => {
					this.plugin.settings.useDefaultTemplates = value;
					await this.plugin.saveSettings();
				}));

		new Setting(containerEl)
			.setName('Campaign template path')
			.setDesc('Path to custom campaign template (leave empty to use default)')
			.addText(text => text
				.setPlaceholder('templates/campaign.md')
				.setValue(this.plugin.settings.campaignTemplatePath)
				.onChange(async (value) => {
					this.plugin.settings.campaignTemplatePath = value;
					await this.plugin.saveSettings();
				}));

		new Setting(containerEl)
			.setName('Session template path')
			.setDesc('Path to custom session template (leave empty to use default)')
			.addText(text => text
				.setPlaceholder('templates/session.md')
				.setValue(this.plugin.settings.sessionTemplatePath)
				.onChange(async (value) => {
					this.plugin.settings.sessionTemplatePath = value;
					await this.plugin.saveSettings();
				}));

		new Setting(containerEl)
			.setName('Scene template path')
			.setDesc('Path to custom scene template (leave empty to use default)')
			.addText(text => text
				.setPlaceholder('templates/scene.md')
				.setValue(this.plugin.settings.sceneTemplatePath)
				.onChange(async (value) => {
					this.plugin.settings.sceneTemplatePath = value;
					await this.plugin.saveSettings();
				}));

		// Parsing Section
		containerEl.createEl('h3', { text: 'Parsing' });

		new Setting(containerEl)
			.setName('Parse on file open')
			.setDesc('Automatically parse campaign files when opened')
			.addToggle(toggle => toggle
				.setValue(this.plugin.settings.parseOnFileOpen)
				.onChange(async (value) => {
					this.plugin.settings.parseOnFileOpen = value;
					await this.plugin.saveSettings();
				}));

		new Setting(containerEl)
			.setName('Parse on file save')
			.setDesc('Automatically reparse campaign files when saved')
			.addToggle(toggle => toggle
				.setValue(this.plugin.settings.parseOnFileSave)
				.onChange(async (value) => {
					this.plugin.settings.parseOnFileSave = value;
					await this.plugin.saveSettings();
				}));

		new Setting(containerEl)
			.setName('Index cache expiry')
			.setDesc('How long to cache parsed data (in minutes)')
			.addText(text => text
				.setPlaceholder('30')
				.setValue(String(this.plugin.settings.indexCacheExpiry))
				.onChange(async (value) => {
					const num = parseInt(value);
					if (!isNaN(num) && num > 0) {
						this.plugin.settings.indexCacheExpiry = num;
						await this.plugin.saveSettings();
					}
				}));

		// Views Section
		containerEl.createEl('h3', { text: 'Views' });

		new Setting(containerEl)
			.setName('Show dashboard on startup')
			.setDesc('Automatically open the campaign dashboard when Obsidian starts')
			.addToggle(toggle => toggle
				.setValue(this.plugin.settings.showDashboardOnStartup)
				.onChange(async (value) => {
					this.plugin.settings.showDashboardOnStartup = value;
					await this.plugin.saveSettings();
				}));

		new Setting(containerEl)
			.setName('Dashboard refresh interval')
			.setDesc('How often to refresh the dashboard (in seconds)')
			.addText(text => text
				.setPlaceholder('30')
				.setValue(String(this.plugin.settings.dashboardRefreshInterval))
				.onChange(async (value) => {
					const num = parseInt(value);
					if (!isNaN(num) && num > 0) {
						this.plugin.settings.dashboardRefreshInterval = num;
						await this.plugin.saveSettings();
					}
				}));

		// Display Section
		containerEl.createEl('h3', { text: 'Display' });

		new Setting(containerEl)
			.setName('Show progress bars')
			.setDesc('Display visual progress bars for clocks, tracks, and timers')
			.addToggle(toggle => toggle
				.setValue(this.plugin.settings.showProgressBars)
				.onChange(async (value) => {
					this.plugin.settings.showProgressBars = value;
					await this.plugin.saveSettings();
				}));

		new Setting(containerEl)
			.setName('Clock style')
			.setDesc('Visual style for clock widgets')
			.addDropdown(dropdown => dropdown
				.addOption('circle', 'Circle')
				.addOption('bar', 'Progress Bar')
				.addOption('segments', 'Segments')
				.setValue(this.plugin.settings.clockStyle)
				.onChange(async (value: 'circle' | 'bar' | 'segments') => {
					this.plugin.settings.clockStyle = value;
					await this.plugin.saveSettings();
				}));

		new Setting(containerEl)
			.setName('Theme')
			.setDesc('Color theme for plugin views')
			.addDropdown(dropdown => dropdown
				.addOption('auto', 'Auto (follow Obsidian)')
				.addOption('light', 'Light')
				.addOption('dark', 'Dark')
				.setValue(this.plugin.settings.theme)
				.onChange(async (value: 'auto' | 'light' | 'dark') => {
					this.plugin.settings.theme = value;
					await this.plugin.saveSettings();
				}));

		// Advanced Section
		containerEl.createEl('h3', { text: 'Advanced' });

		new Setting(containerEl)
			.setName('Debug mode')
			.setDesc('Enable debug logging to console')
			.addToggle(toggle => toggle
				.setValue(this.plugin.settings.debugMode)
				.onChange(async (value) => {
					this.plugin.settings.debugMode = value;
					await this.plugin.saveSettings();
				}));

		new Setting(containerEl)
			.setName('Custom snippets path')
			.setDesc('Path to custom snippets file (leave empty to use defaults)')
			.addText(text => text
				.setPlaceholder('snippets/solo-rpg.json')
				.setValue(this.plugin.settings.customSnippetsPath)
				.onChange(async (value) => {
					this.plugin.settings.customSnippetsPath = value;
					await this.plugin.saveSettings();
				}));
	}
}

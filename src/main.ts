import { Plugin } from 'obsidian';
import { SoloRPGSettings, DEFAULT_SETTINGS, SoloRPGSettingTab } from './settings';
import { TemplateManager } from './templates/TemplateManager';
import { NotationIndexer } from './indexer/NotationIndexer';
import { registerNotationCommands } from './commands/notationCommands';
import { DashboardView, VIEW_TYPE_DASHBOARD } from './views/DashboardView';
import { TagBrowserView, VIEW_TYPE_TAG_BROWSER } from './views/TagBrowserView';
import { ProgressTrackerView, VIEW_TYPE_PROGRESS_TRACKER } from './views/ProgressTrackerView';
import { AllElementsView, VIEW_TYPE_ALL_ELEMENTS } from './views/AllElementsView';
import { RandomEventsView, VIEW_TYPE_RANDOM_EVENTS } from './views/RandomEventsView';
import { MetaNotesView, VIEW_TYPE_META_NOTES } from './views/MetaNotesView';

export default class SoloRPGNotationPlugin extends Plugin {
	settings: SoloRPGSettings;
	templateManager: TemplateManager;
	indexer: NotationIndexer;

	async onload() {
		console.log('Loading Solo RPG Notation plugin');

		// Load settings
		await this.loadSettings();

		// Initialize template manager
		this.templateManager = new TemplateManager(this.app, this.settings);

		// Initialize indexer
		this.indexer = new NotationIndexer(this.app, this.settings);
		if (this.settings.enableIndexing) {
			// Index vault in background
			this.indexer.initialize().catch(error => {
				console.error('Error initializing indexer:', error);
			});
		}

		// Register views
		this.registerViews();

		// Register commands
		registerNotationCommands(this.app, this, this.templateManager);

		// Register indexer commands
		this.registerIndexerCommands();

		// Register view commands
		this.registerViewCommands();

		// Add settings tab
		this.addSettingTab(new SoloRPGSettingTab(this.app, this));

		// Add ribbon icons
		this.addRibbonIcon('dice', 'Solo RPG Notation', () => {
			this.activateView(VIEW_TYPE_DASHBOARD);
		});

		this.addRibbonIcon('tags', 'Tag Browser', () => {
			this.activateView(VIEW_TYPE_TAG_BROWSER);
		});

		this.addRibbonIcon('clock', 'Progress Tracker', () => {
			this.activateView(VIEW_TYPE_PROGRESS_TRACKER);
		});

		this.addRibbonIcon('database', 'All Elements Reference', () => {
			this.activateView(VIEW_TYPE_ALL_ELEMENTS);
		});

		this.addRibbonIcon('dices', 'Random Events', () => {
			this.activateView(VIEW_TYPE_RANDOM_EVENTS);
		});

		this.addRibbonIcon('sticky-note', 'Meta Notes', () => {
			this.activateView(VIEW_TYPE_META_NOTES);
		});

		console.log('Solo RPG Notation plugin loaded successfully');
	}

	async onunload() {
		console.log('Unloading Solo RPG Notation plugin');

		// Clean up indexer
		if (this.indexer) {
			this.indexer.cleanup();
		}

		// Detach views
		this.app.workspace.detachLeavesOfType(VIEW_TYPE_DASHBOARD);
		this.app.workspace.detachLeavesOfType(VIEW_TYPE_TAG_BROWSER);
		this.app.workspace.detachLeavesOfType(VIEW_TYPE_PROGRESS_TRACKER);
		this.app.workspace.detachLeavesOfType(VIEW_TYPE_ALL_ELEMENTS);
		this.app.workspace.detachLeavesOfType(VIEW_TYPE_RANDOM_EVENTS);
		this.app.workspace.detachLeavesOfType(VIEW_TYPE_META_NOTES);
	}

	async loadSettings() {
		this.settings = Object.assign({}, DEFAULT_SETTINGS, await this.loadData());
	}

	async saveSettings() {
		await this.saveData(this.settings);
	}

	/**
	 * Register view types
	 */
	private registerViews() {
		this.registerView(
			VIEW_TYPE_DASHBOARD,
			(leaf) => new DashboardView(leaf, this.indexer)
		);

		this.registerView(
			VIEW_TYPE_TAG_BROWSER,
			(leaf) => new TagBrowserView(leaf, this.indexer)
		);

		this.registerView(
			VIEW_TYPE_PROGRESS_TRACKER,
			(leaf) => new ProgressTrackerView(leaf, this.indexer, this.settings)
		);

		this.registerView(
			VIEW_TYPE_ALL_ELEMENTS,
			(leaf) => new AllElementsView(leaf, this.indexer)
		);

		this.registerView(
			VIEW_TYPE_RANDOM_EVENTS,
			(leaf) => new RandomEventsView(leaf, this.indexer)
		);

		this.registerView(
			VIEW_TYPE_META_NOTES,
			(leaf) => new MetaNotesView(leaf, this.indexer)
		);
	}

	/**
	 * Activate a view
	 */
	async activateView(viewType: string) {
		const { workspace } = this.app;

		let leaf = workspace.getLeavesOfType(viewType)[0];

		if (!leaf) {
			// Create new leaf in right sidebar
			const rightLeaf = workspace.getRightLeaf(false);
			if (rightLeaf) {
				leaf = rightLeaf;
				await leaf.setViewState({ type: viewType, active: true });
			}
		}

		if (leaf) {
			workspace.revealLeaf(leaf);
		}
	}

	/**
	 * Register commands related to indexing
	 */
	private registerIndexerCommands() {
		// Reindex current file
		this.addCommand({
			id: 'reindex-current-file',
			name: 'Reindex Current Campaign',
			checkCallback: (checking: boolean) => {
				const file = this.app.workspace.getActiveFile();
				if (file) {
					if (!checking) {
						this.indexer.indexFile(file);
					}
					return true;
				}
				return false;
			}
		});

		// Reindex entire vault
		this.addCommand({
			id: 'reindex-vault',
			name: 'Reindex All Campaigns',
			callback: async () => {
				await this.indexer.indexVault();
			}
		});

		// Show index stats
		this.addCommand({
			id: 'show-index-stats',
			name: 'Show Index Statistics',
			callback: () => {
				const campaigns = this.indexer.getAllCampaigns();
				const npcs = this.indexer.getAllNPCs();
				const locations = this.indexer.getAllLocations();
				const threads = this.indexer.getAllThreads();

				console.log('=== Solo RPG Notation Index Stats ===');
				console.log(`Campaigns: ${campaigns.length}`);
				console.log(`NPCs: ${npcs.length}`);
				console.log(`Locations: ${locations.length}`);
				console.log(`Threads: ${threads.length}`);
				console.log('===================================');
			}
		});
	}

	/**
	 * Register commands related to views
	 */
	private registerViewCommands() {
		// Open Dashboard
		this.addCommand({
			id: 'open-dashboard',
			name: 'Open Campaign Dashboard',
			callback: () => {
				this.activateView(VIEW_TYPE_DASHBOARD);
			}
		});

		// Open Tag Browser
		this.addCommand({
			id: 'open-tag-browser',
			name: 'Open Tag Browser',
			callback: () => {
				this.activateView(VIEW_TYPE_TAG_BROWSER);
			}
		});

		// Open Progress Tracker
		this.addCommand({
			id: 'open-progress-tracker',
			name: 'Open Progress Tracker',
			callback: () => {
				this.activateView(VIEW_TYPE_PROGRESS_TRACKER);
			}
		});

		// Open All Elements Reference
		this.addCommand({
			id: 'open-all-elements',
			name: 'Open All Elements Reference',
			callback: () => {
				this.activateView(VIEW_TYPE_ALL_ELEMENTS);
			}
		});
	}
}

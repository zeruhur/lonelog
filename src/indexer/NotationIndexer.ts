import { App, TFile, EventRef } from 'obsidian';
import { NotationParser } from '../parser/NotationParser';
import { Campaign, NPC, LocationTag, Thread, SearchResults, CampaignStats } from '../types/notation';
import { SoloRPGSettings } from '../settings';

/**
 * Index and manage all campaign files in the vault
 */
export class NotationIndexer {
	app: App;
	settings: SoloRPGSettings;
	parser: NotationParser;
	campaigns: Map<string, Campaign>;
	private fileChangeListeners: EventRef[] = [];
	private indexingInProgress: boolean = false;

	constructor(app: App, settings: SoloRPGSettings) {
		this.app = app;
		this.settings = settings;
		this.parser = new NotationParser();
		this.campaigns = new Map();
	}

	/**
	 * Initialize the indexer and set up file watchers
	 */
	async initialize(): Promise<void> {
		// Index existing files
		await this.indexVault();

		// Set up file change listeners
		this.setupFileWatchers();
	}

	/**
	 * Index all campaign files in the vault
	 */
	async indexVault(): Promise<void> {
		if (this.indexingInProgress) {
			console.log('Indexing already in progress, skipping...');
			return;
		}

		this.indexingInProgress = true;
		console.log('Starting vault indexing...');

		try {
			const files = this.app.vault.getMarkdownFiles();
			let indexed = 0;

			for (const file of files) {
				if (await this.isCampaignFile(file)) {
					await this.indexFile(file);
					indexed++;
				}
			}

			console.log(`Vault indexing complete: ${indexed} campaign files indexed`);
		} catch (error) {
			console.error('Error indexing vault:', error);
		} finally {
			this.indexingInProgress = false;
		}
	}

	/**
	 * Check if a file is a campaign file (has YAML frontmatter with title or is marked as campaign)
	 */
	private async isCampaignFile(file: TFile): Promise<boolean> {
		try {
			const content = await this.app.vault.read(file);

			// Check for YAML frontmatter
			const frontmatterMatch = content.match(/^---\n([\s\S]*?)\n---/);
			if (!frontmatterMatch) return false;

			// Check if it has typical campaign fields
			const frontmatter = frontmatterMatch[1].toLowerCase();
			return (
				frontmatter.includes('title:') ||
				frontmatter.includes('ruleset:') ||
				frontmatter.includes('genre:') ||
				frontmatter.includes('campaign:')
			);
		} catch (error) {
			console.error(`Error checking if file is campaign: ${file.path}`, error);
			return false;
		}
	}

	/**
	 * Index a single file
	 */
	async indexFile(file: TFile): Promise<void> {
		if (!this.settings.enableIndexing) {
			return;
		}

		try {
			if (this.settings.debugMode) {
				console.log(`Indexing file: ${file.path}`);
			}

			const content = await this.app.vault.read(file);
			const campaign = this.parser.parseCampaignFile(content, file.path);
			this.campaigns.set(file.path, campaign);

			if (this.settings.debugMode) {
				console.log(`Successfully indexed: ${campaign.title}`);
			}
		} catch (error) {
			console.error(`Error indexing file: ${file.path}`, error);
		}
	}

	/**
	 * Remove a file from the index
	 */
	removeFile(filePath: string): void {
		this.campaigns.delete(filePath);
		if (this.settings.debugMode) {
			console.log(`Removed from index: ${filePath}`);
		}
	}

	/**
	 * Set up file watchers to keep index updated
	 */
	private setupFileWatchers(): void {
		// Watch for file modifications
		const modifyRef = this.app.vault.on('modify', async (file) => {
			if (file instanceof TFile && file.extension === 'md') {
				if (this.settings.parseOnFileSave && await this.isCampaignFile(file)) {
					await this.indexFile(file);
				}
			}
		});

		// Watch for file creation
		const createRef = this.app.vault.on('create', async (file) => {
			if (file instanceof TFile && file.extension === 'md') {
				if (await this.isCampaignFile(file)) {
					await this.indexFile(file);
				}
			}
		});

		// Watch for file deletion
		const deleteRef = this.app.vault.on('delete', (file) => {
			if (file instanceof TFile) {
				this.removeFile(file.path);
			}
		});

		// Watch for file rename
		const renameRef = this.app.vault.on('rename', async (file, oldPath) => {
			if (file instanceof TFile && file.extension === 'md') {
				this.removeFile(oldPath);
				if (await this.isCampaignFile(file)) {
					await this.indexFile(file);
				}
			}
		});

		this.fileChangeListeners.push(modifyRef, createRef, deleteRef, renameRef);
	}

	/**
	 * Clean up file watchers
	 */
	cleanup(): void {
		for (const ref of this.fileChangeListeners) {
			this.app.vault.offref(ref);
		}
		this.fileChangeListeners = [];
	}

	// ========== Query Methods ==========

	/**
	 * Get a campaign by file path
	 */
	getCampaign(filePath: string): Campaign | null {
		return this.campaigns.get(filePath) || null;
	}

	/**
	 * Get all campaigns
	 */
	getAllCampaigns(): Campaign[] {
		return Array.from(this.campaigns.values());
	}

	/**
	 * Get all NPCs across all campaigns
	 */
	getAllNPCs(): NPC[] {
		const npcs: NPC[] = [];
		for (const campaign of this.campaigns.values()) {
			npcs.push(...Array.from(campaign.npcs.values()));
		}
		return npcs;
	}

	/**
	 * Get all locations across all campaigns
	 */
	getAllLocations(): LocationTag[] {
		const locations: LocationTag[] = [];
		for (const campaign of this.campaigns.values()) {
			locations.push(...Array.from(campaign.locations.values()));
		}
		return locations;
	}

	/**
	 * Get all threads across all campaigns
	 */
	getAllThreads(): Thread[] {
		const threads: Thread[] = [];
		for (const campaign of this.campaigns.values()) {
			threads.push(...Array.from(campaign.threads.values()));
		}
		return threads;
	}

	/**
	 * Get all progress elements (clocks, tracks, timers, events)
	 */
	getAllProgressElements(): any[] {
		const elements: any[] = [];
		for (const campaign of this.campaigns.values()) {
			elements.push(...Array.from(campaign.clocks.values()));
			elements.push(...Array.from(campaign.tracks.values()));
			elements.push(...Array.from(campaign.timers.values()));
			elements.push(...Array.from(campaign.events.values()));
		}
		return elements;
	}

	/**
	 * Search for elements by query
	 */
	searchElements(query: string): SearchResults {
		const queryLower = query.toLowerCase();
		const results: SearchResults = {
			npcs: [],
			locations: [],
			threads: [],
			progressElements: [],
			totalResults: 0,
		};

		// Search NPCs
		for (const npc of this.getAllNPCs()) {
			if (
				npc.name.toLowerCase().includes(queryLower) ||
				npc.tags.some(tag => tag.toLowerCase().includes(queryLower))
			) {
				results.npcs.push(npc);
			}
		}

		// Search Locations
		for (const location of this.getAllLocations()) {
			if (
				location.name.toLowerCase().includes(queryLower) ||
				location.tags.some(tag => tag.toLowerCase().includes(queryLower))
			) {
				results.locations.push(location);
			}
		}

		// Search Threads
		for (const thread of this.getAllThreads()) {
			if (
				thread.name.toLowerCase().includes(queryLower) ||
				thread.state.toLowerCase().includes(queryLower)
			) {
				results.threads.push(thread);
			}
		}

		// Search Progress Elements
		for (const element of this.getAllProgressElements()) {
			if (element.name.toLowerCase().includes(queryLower)) {
				results.progressElements.push(element);
			}
		}

		results.totalResults =
			results.npcs.length +
			results.locations.length +
			results.threads.length +
			results.progressElements.length;

		return results;
	}

	/**
	 * Get campaign statistics
	 */
	getCampaignStats(filePath: string): CampaignStats | null {
		const campaign = this.getCampaign(filePath);
		if (!campaign) return null;

		const activeThreads = Array.from(campaign.threads.values())
			.filter(t => t.state.toLowerCase() === 'open').length;
		const closedThreads = Array.from(campaign.threads.values())
			.filter(t => t.state.toLowerCase() === 'closed').length;

		const totalScenes = campaign.sessions.reduce(
			(sum, session) => sum + session.scenes.length,
			0
		);

		const totalProgressElements =
			campaign.clocks.size +
			campaign.tracks.size +
			campaign.timers.size +
			campaign.events.size;

		return {
			totalSessions: campaign.sessions.length,
			totalScenes,
			activeThreads,
			closedThreads,
			totalNPCs: campaign.npcs.size,
			totalLocations: campaign.locations.size,
			totalProgressElements,
			lastUpdated: campaign.frontMatter.last_update,
		};
	}

	/**
	 * Get all active threads (state = "Open")
	 */
	getActiveThreads(): Thread[] {
		return this.getAllThreads().filter(t => t.state.toLowerCase() === 'open');
	}

	/**
	 * Get NPCs for a specific campaign
	 */
	getCampaignNPCs(filePath: string): NPC[] {
		const campaign = this.getCampaign(filePath);
		return campaign ? Array.from(campaign.npcs.values()) : [];
	}

	/**
	 * Get locations for a specific campaign
	 */
	getCampaignLocations(filePath: string): LocationTag[] {
		const campaign = this.getCampaign(filePath);
		return campaign ? Array.from(campaign.locations.values()) : [];
	}

	/**
	 * Get threads for a specific campaign
	 */
	getCampaignThreads(filePath: string): Thread[] {
		const campaign = this.getCampaign(filePath);
		return campaign ? Array.from(campaign.threads.values()) : [];
	}
}

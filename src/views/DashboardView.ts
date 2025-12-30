import { ItemView, WorkspaceLeaf, TFile } from 'obsidian';
import { NotationIndexer } from '../indexer/NotationIndexer';
import { Campaign } from '../types/notation';

export const VIEW_TYPE_DASHBOARD = 'solo-rpg-dashboard';

/**
 * Dashboard view showing all campaigns with statistics
 */
export class DashboardView extends ItemView {
	indexer: NotationIndexer;
	private refreshInterval: number | null = null;

	constructor(leaf: WorkspaceLeaf, indexer: NotationIndexer) {
		super(leaf);
		this.indexer = indexer;
	}

	getViewType(): string {
		return VIEW_TYPE_DASHBOARD;
	}

	getDisplayText(): string {
		return 'Campaign Dashboard';
	}

	getIcon(): string {
		return 'dice';
	}

	async onOpen() {
		await this.render();
	}

	async onClose() {
		// Clean up refresh interval
		if (this.refreshInterval !== null) {
			window.clearInterval(this.refreshInterval);
		}
	}

	/**
	 * Render the dashboard
	 */
	async render() {
		const container = this.containerEl.children[1] as HTMLElement;
		container.empty();
		container.addClass('solo-rpg-container');

		// Header
		const header = container.createDiv({ cls: 'solo-rpg-header' });
		header.createEl('h2', { text: 'Solo RPG Campaigns', cls: 'solo-rpg-title' });

		const refreshBtn = header.createEl('button', {
			text: '🔄 Refresh',
			cls: 'solo-rpg-button',
		});
		refreshBtn.addEventListener('click', () => this.render());

		// Get all campaigns
		const campaigns = this.indexer.getAllCampaigns();

		if (campaigns.length === 0) {
			this.renderEmptyState(container);
			return;
		}

		// Campaign list
		const listContainer = container.createDiv({ cls: 'solo-rpg-campaign-list' });

		for (const campaign of campaigns) {
			this.renderCampaignCard(listContainer, campaign);
		}

		// Summary stats
		this.renderSummaryStats(container, campaigns);
	}

	/**
	 * Render empty state when no campaigns exist
	 */
	private renderEmptyState(container: HTMLElement) {
		const empty = container.createDiv({ cls: 'solo-rpg-empty' });
		empty.createDiv({ text: '🎲', cls: 'solo-rpg-empty-icon' });
		empty.createEl('p', {
			text: 'No campaigns found',
			cls: 'solo-rpg-empty-text',
		});
		empty.createEl('p', {
			text: 'Create a new campaign file or use "Insert Campaign Template" to get started',
		});
		empty.createEl('p', {
			text: 'Check out the examples/ folder in the plugin directory for inspiration!',
			cls: 'solo-rpg-empty-hint',
		});
	}

	/**
	 * Render a single campaign card
	 */
	private renderCampaignCard(container: HTMLElement, campaign: Campaign) {
		const card = container.createDiv({ cls: 'solo-rpg-campaign-card' });

		// Make card clickable to open file
		card.addEventListener('click', () => {
			this.openCampaignFile(campaign.file);
		});

		// Title
		card.createEl('div', {
			text: campaign.title,
			cls: 'solo-rpg-campaign-title',
		});

		// Stats
		const stats = this.indexer.getCampaignStats(campaign.file);
		if (stats) {
			const statsContainer = card.createDiv({ cls: 'solo-rpg-campaign-stats' });

			this.createStat(statsContainer, '📅', `${stats.totalSessions} sessions`);
			this.createStat(statsContainer, '🎬', `${stats.totalScenes} scenes`);
			this.createStat(statsContainer, '👥', `${stats.totalNPCs} NPCs`);
			this.createStat(statsContainer, '📍', `${stats.totalLocations} locations`);
			this.createStat(statsContainer, '🧵', `${stats.activeThreads} active threads`);

			if (stats.totalProgressElements > 0) {
				this.createStat(
					statsContainer,
					'⏱️',
					`${stats.totalProgressElements} trackers`
				);
			}
		}

		// Metadata
		const metadata = card.createDiv({ cls: 'solo-rpg-campaign-meta' });
		if (campaign.frontMatter.ruleset) {
			metadata.createEl('span', {
				text: `System: ${campaign.frontMatter.ruleset}`,
			});
		}
		if (campaign.frontMatter.genre) {
			metadata.createEl('span', {
				text: ` | Genre: ${campaign.frontMatter.genre}`,
			});
		}
		if (campaign.frontMatter.last_update) {
			metadata.createEl('span', {
				text: ` | Updated: ${campaign.frontMatter.last_update}`,
			});
		}
	}

	/**
	 * Create a stat item
	 */
	private createStat(container: HTMLElement, icon: string, text: string) {
		const stat = container.createDiv({ cls: 'solo-rpg-campaign-stat' });
		stat.createSpan({ text: icon });
		stat.createSpan({ text: ` ${text}` });
	}

	/**
	 * Render summary statistics
	 */
	private renderSummaryStats(container: HTMLElement, campaigns: Campaign[]) {
		const summary = container.createDiv({ cls: 'solo-rpg-summary' });
		summary.createEl('h3', { text: 'Vault Summary' });

		const totalNPCs = this.indexer.getAllNPCs().length;
		const totalLocations = this.indexer.getAllLocations().length;
		const totalThreads = this.indexer.getAllThreads().length;
		const activeThreads = this.indexer.getActiveThreads().length;
		const totalProgress = this.indexer.getAllProgressElements().length;

		const statsGrid = summary.createDiv({ cls: 'solo-rpg-stats-grid' });

		this.createStatBox(statsGrid, '🎲', campaigns.length.toString(), 'Campaigns');
		this.createStatBox(statsGrid, '👥', totalNPCs.toString(), 'NPCs');
		this.createStatBox(statsGrid, '📍', totalLocations.toString(), 'Locations');
		this.createStatBox(
			statsGrid,
			'🧵',
			`${activeThreads}/${totalThreads}`,
			'Active Threads'
		);
		this.createStatBox(statsGrid, '⏱️', totalProgress.toString(), 'Trackers');
	}

	/**
	 * Create a stat box
	 */
	private createStatBox(
		container: HTMLElement,
		icon: string,
		value: string,
		label: string
	) {
		const box = container.createDiv({ cls: 'solo-rpg-stat-box' });
		box.createDiv({ text: icon, cls: 'solo-rpg-stat-icon' });
		box.createDiv({ text: value, cls: 'solo-rpg-stat-value' });
		box.createDiv({ text: label, cls: 'solo-rpg-stat-label' });
	}

	/**
	 * Open a campaign file
	 */
	private async openCampaignFile(filePath: string) {
		const file = this.app.vault.getAbstractFileByPath(filePath);
		if (file instanceof TFile) {
			await this.app.workspace.getLeaf(false).openFile(file);
		}
	}
}

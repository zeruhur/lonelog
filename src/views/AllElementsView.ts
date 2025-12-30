import { ItemView, WorkspaceLeaf, TFile, Notice } from 'obsidian';
import { NotationIndexer } from '../indexer/NotationIndexer';
import {
	UnifiedElement,
	normalizeNPC,
	normalizeLocation,
	normalizeThread,
	normalizeClock,
	normalizeTrack,
	normalizeTimer,
	normalizeEvent,
	normalizePC,
} from '../utils/elementHelpers';

export const VIEW_TYPE_ALL_ELEMENTS = 'solo-rpg-all-elements';

type SortColumn = 'name' | 'type' | 'mentions' | 'lastSeen';
type SortDirection = 'asc' | 'desc';

/**
 * All Elements Reference View - Shows all game elements in one table
 */
export class AllElementsView extends ItemView {
	indexer: NotationIndexer;
	private searchQuery: string = '';
	private typeFilter: Set<string> = new Set(['NPC', 'Location', 'Thread', 'Clock', 'Track', 'Timer', 'Event', 'PC']);
	private campaignFilter: string = 'all';
	private sortColumn: SortColumn = 'name';
	private sortDirection: SortDirection = 'asc';

	constructor(leaf: WorkspaceLeaf, indexer: NotationIndexer) {
		super(leaf);
		this.indexer = indexer;
	}

	getViewType(): string {
		return VIEW_TYPE_ALL_ELEMENTS;
	}

	getDisplayText(): string {
		return 'All Elements Reference';
	}

	getIcon(): string {
		return 'database';
	}

	async onOpen() {
		await this.render();
	}

	async onClose() {
		// Cleanup if needed
	}

	/**
	 * Render the all elements view
	 */
	async render() {
		const container = this.containerEl.children[1] as HTMLElement;
		container.empty();
		container.addClass('solo-rpg-container');

		// Header
		const header = container.createDiv({ cls: 'solo-rpg-header' });
		header.createEl('h2', { text: 'All Elements Reference', cls: 'solo-rpg-title' });

		const refreshBtn = header.createEl('button', { text: '↻ Refresh' });
		refreshBtn.addEventListener('click', () => this.render());

		// Filter panel
		this.renderFilterPanel(container);

		// Get filtered and sorted elements
		const elements = this.getFilteredAndSortedElements();

		// Table
		if (elements.length === 0) {
			const empty = container.createDiv({ cls: 'solo-rpg-empty-state' });
			empty.createEl('p', { text: 'No elements found matching the current filters.' });
			empty.createEl('p', { text: 'Try adjusting your filters or add game elements to your campaigns.' });
		} else {
			this.renderTable(container, elements);

			// Footer
			const footer = container.createDiv({ cls: 'solo-rpg-elements-footer' });
			const allElements = this.getAllElements();
			footer.createEl('p', { text: `Showing ${elements.length} of ${allElements.length} elements` });
		}
	}

	/**
	 * Render filter panel
	 */
	private renderFilterPanel(container: HTMLElement) {
		const panel = container.createDiv({ cls: 'solo-rpg-filter-panel' });

		// Search input
		const searchContainer = panel.createDiv({ cls: 'solo-rpg-search-container' });
		const searchInput = searchContainer.createEl('input', {
			type: 'text',
			placeholder: 'Search elements...',
			value: this.searchQuery,
		});
		searchInput.addEventListener('input', (e) => {
			this.searchQuery = (e.target as HTMLInputElement).value;
			this.render();
		});

		// Type filters
		const typeLabel = panel.createEl('label', { text: 'Element Types:' });
		typeLabel.style.fontWeight = 'bold';
		typeLabel.style.marginBottom = '4px';
		typeLabel.style.display = 'block';

		const typeFilters = panel.createDiv({ cls: 'solo-rpg-type-filters' });
		const types = ['NPC', 'Location', 'Thread', 'Clock', 'Track', 'Timer', 'Event', 'PC'];
		for (const type of types) {
			const chip = typeFilters.createDiv({
				cls: `solo-rpg-type-chip ${this.typeFilter.has(type) ? 'active' : ''}`,
				text: type,
			});
			chip.addEventListener('click', () => {
				this.handleTypeFilterToggle(type);
			});
		}

		// Campaign filter
		const campaigns = this.indexer.getAllCampaigns();
		if (campaigns.length > 1) {
			const campaignLabel = panel.createEl('label', { text: 'Campaign:' });
			campaignLabel.style.fontWeight = 'bold';
			campaignLabel.style.marginBottom = '4px';
			campaignLabel.style.display = 'block';

			const campaignSelect = panel.createEl('select');
			campaignSelect.style.width = '100%';
			campaignSelect.style.padding = '4px';

			const allOption = campaignSelect.createEl('option', { text: 'All Campaigns', value: 'all' });
			for (const campaign of campaigns) {
				campaignSelect.createEl('option', { text: campaign.title, value: campaign.title });
			}
			campaignSelect.value = this.campaignFilter;
			campaignSelect.addEventListener('change', (e) => {
				this.campaignFilter = (e.target as HTMLSelectElement).value;
				this.render();
			});
		}
	}

	/**
	 * Render table
	 */
	private renderTable(container: HTMLElement, elements: UnifiedElement[]) {
		const tableContainer = container.createDiv({ cls: 'solo-rpg-table-container' });
		const table = tableContainer.createEl('table', { cls: 'solo-rpg-elements-table' });

		// Header
		this.renderTableHeader(table);

		// Body
		const tbody = table.createEl('tbody');
		for (const element of elements) {
			this.renderTableRow(tbody, element);
		}
	}

	/**
	 * Render table header
	 */
	private renderTableHeader(table: HTMLElement) {
		const thead = table.createEl('thead');
		const headerRow = thead.createEl('tr');

		const columns: { key: SortColumn | null; label: string }[] = [
			{ key: 'name', label: 'Name' },
			{ key: 'type', label: 'Type' },
			{ key: null, label: 'Campaign' },
			{ key: null, label: 'Tags' },
			{ key: 'mentions', label: 'Mentions' },
			{ key: 'lastSeen', label: 'Last Seen' },
			{ key: null, label: 'Progress/Status' },
		];

		for (const col of columns) {
			const th = headerRow.createEl('th');
			th.textContent = col.label;

			if (col.key) {
				th.style.cursor = 'pointer';
				th.addEventListener('click', () => this.handleColumnSort(col.key!));

				// Add sort indicator
				if (this.sortColumn === col.key) {
					const indicator = th.createEl('span', { cls: 'solo-rpg-sort-indicator' });
					indicator.textContent = this.sortDirection === 'asc' ? ' ▲' : ' ▼';
				}
			}
		}
	}

	/**
	 * Render table row
	 */
	private renderTableRow(tbody: HTMLElement, element: UnifiedElement) {
		const row = tbody.createEl('tr', { cls: 'solo-rpg-elements-row' });
		row.addEventListener('click', () => this.handleRowClick(element));

		// Name
		const nameCell = row.createEl('td');
		nameCell.createEl('strong', { text: element.name });

		// Type
		row.createEl('td', { text: element.type });

		// Campaign
		row.createEl('td', { text: element.campaign });

		// Tags
		const tagsCell = row.createEl('td');
		if (element.tags.length > 0) {
			const tagsDiv = tagsCell.createDiv({ cls: 'solo-rpg-element-tags' });
			const displayTags = element.tags.slice(0, 3);
			for (const tag of displayTags) {
				tagsDiv.createEl('span', { text: tag, cls: 'solo-rpg-tag' });
			}
			if (element.tags.length > 3) {
				tagsDiv.createEl('span', { text: `+${element.tags.length - 3} more`, cls: 'solo-rpg-tag-more' });
			}
		} else {
			tagsCell.textContent = '—';
		}

		// Mentions
		row.createEl('td', { text: element.mentions.toString() });

		// Last Seen
		row.createEl('td', { text: element.lastSeen });

		// Progress/Status
		const progressCell = row.createEl('td');
		if (element.progress) {
			progressCell.textContent = element.progress;
		} else {
			progressCell.textContent = '—';
		}
	}

	/**
	 * Get all elements from all campaigns
	 */
	private getAllElements(): UnifiedElement[] {
		const elements: UnifiedElement[] = [];
		const campaigns = this.indexer.getAllCampaigns();

		for (const campaign of campaigns) {
			// NPCs
			for (const npc of campaign.npcs.values()) {
				elements.push(normalizeNPC(npc, campaign));
			}

			// Locations
			for (const location of campaign.locations.values()) {
				elements.push(normalizeLocation(location, campaign));
			}

			// Threads
			for (const thread of campaign.threads.values()) {
				elements.push(normalizeThread(thread, campaign));
			}

			// Clocks
			for (const clock of campaign.clocks.values()) {
				elements.push(normalizeClock(clock, campaign));
			}

			// Tracks
			for (const track of campaign.tracks.values()) {
				elements.push(normalizeTrack(track, campaign));
			}

			// Timers
			for (const timer of campaign.timers.values()) {
				elements.push(normalizeTimer(timer, campaign));
			}

			// Events
			for (const event of campaign.events.values()) {
				elements.push(normalizeEvent(event, campaign));
			}

			// Player Characters
			for (const pc of campaign.playerCharacters.values()) {
				elements.push(normalizePC(pc, campaign));
			}
		}

		return elements;
	}

	/**
	 * Get filtered and sorted elements
	 */
	private getFilteredAndSortedElements(): UnifiedElement[] {
		let elements = this.getAllElements();

		// Apply type filter
		elements = elements.filter(e => this.typeFilter.has(e.type));

		// Apply campaign filter
		if (this.campaignFilter !== 'all') {
			elements = elements.filter(e => e.campaign === this.campaignFilter);
		}

		// Apply search
		if (this.searchQuery) {
			elements = elements.filter(e => this.matchesSearch(e));
		}

		// Apply sort
		elements.sort((a, b) => this.compareElements(a, b));

		return elements;
	}

	/**
	 * Check if element matches search query
	 */
	private matchesSearch(element: UnifiedElement): boolean {
		const query = this.searchQuery.toLowerCase();
		return (
			element.name.toLowerCase().includes(query) ||
			element.type.toLowerCase().includes(query) ||
			element.campaign.toLowerCase().includes(query) ||
			element.tags.some(tag => tag.toLowerCase().includes(query))
		);
	}

	/**
	 * Compare elements for sorting
	 */
	private compareElements(a: UnifiedElement, b: UnifiedElement): number {
		let result = 0;

		switch (this.sortColumn) {
			case 'name':
				result = a.name.localeCompare(b.name);
				break;
			case 'type':
				result = a.type.localeCompare(b.type);
				break;
			case 'mentions':
				result = a.mentions - b.mentions;
				break;
			case 'lastSeen':
				result = a.lastSeen.localeCompare(b.lastSeen);
				break;
		}

		return this.sortDirection === 'asc' ? result : -result;
	}

	/**
	 * Handle type filter toggle
	 */
	private handleTypeFilterToggle(type: string) {
		if (this.typeFilter.has(type)) {
			this.typeFilter.delete(type);
		} else {
			this.typeFilter.add(type);
		}
		this.render();
	}

	/**
	 * Handle column sort
	 */
	private handleColumnSort(column: SortColumn) {
		if (this.sortColumn === column) {
			// Toggle direction
			this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
		} else {
			// New column, default to ascending
			this.sortColumn = column;
			this.sortDirection = 'asc';
		}
		this.render();
	}

	/**
	 * Handle row click - navigate to element location
	 */
	private async handleRowClick(element: UnifiedElement) {
		const file = this.app.vault.getAbstractFileByPath(element.navigateTo.file);
		if (!(file instanceof TFile)) {
			new Notice(`File not found: ${element.navigateTo.file}`);
			return;
		}

		try {
			const leaf = this.app.workspace.getLeaf(false);
			await leaf.openFile(file);

			// Scroll to line
			const view = this.app.workspace.getActiveViewOfType(ItemView);
			if (view) {
				// @ts-ignore - accessing editor
				const editor = view.editor;
				if (editor) {
					const lineCount = editor.lineCount();
					if (element.navigateTo.lineNumber >= lineCount) {
						new Notice('Location not found in file, opened at top');
						editor.setCursor({ line: 0, ch: 0 });
					} else {
						editor.setCursor({ line: element.navigateTo.lineNumber, ch: 0 });
						editor.scrollIntoView({ from: { line: element.navigateTo.lineNumber, ch: 0 }, to: { line: element.navigateTo.lineNumber, ch: 0 } }, true);
					}
				}
			}
		} catch (error) {
			console.error('Error navigating to element:', error);
			new Notice('Could not navigate to element location');
		}
	}
}

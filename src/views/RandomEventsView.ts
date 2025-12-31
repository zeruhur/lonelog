import { ItemView, WorkspaceLeaf, TFile, Notice } from 'obsidian';
import { NotationIndexer } from '../indexer/NotationIndexer';
import { TableLookup, Generator, Location } from '../types/notation';

export const VIEW_TYPE_RANDOM_EVENTS = 'solo-rpg-random-events';

type EventType = 'all' | 'tables' | 'generators';

interface RandomEvent {
	type: 'table' | 'generator';
	data: TableLookup | Generator;
	location: Location;
	campaign: string;
	session: string;
	scene: string;
}

export class RandomEventsView extends ItemView {
	indexer: NotationIndexer;
	private searchQuery: string = '';
	private filterType: EventType = 'all';

	constructor(leaf: WorkspaceLeaf, indexer: NotationIndexer) {
		super(leaf);
		this.indexer = indexer;
	}

	getViewType(): string {
		return VIEW_TYPE_RANDOM_EVENTS;
	}

	getDisplayText(): string {
		return 'Random Events';
	}

	getIcon(): string {
		return 'dices';
	}

	async onOpen() {
		await this.render();
	}

	async onClose() {
		// Cleanup if needed
	}

	async render() {
		const container = this.containerEl.children[1] as HTMLElement;
		container.empty();
		container.addClass('solo-rpg-container');

		// Header
		const header = container.createDiv({ cls: 'solo-rpg-header' });
		header.createEl('h2', { text: 'Random Events', cls: 'solo-rpg-title' });

		const refreshBtn = header.createEl('button', { text: '↻ Refresh' });
		refreshBtn.addEventListener('click', () => this.render());

		// Search and filter
		this.renderSearchAndFilter(container);

		// Get all events
		const events = this.getAllRandomEvents();

		// Table
		if (events.length === 0) {
			const empty = container.createDiv({ cls: 'solo-rpg-empty-state' });
			empty.createEl('p', { text: 'No random events found matching the current filters.' });
			empty.createEl('p', { text: 'Add table lookups with: tbl: d100=42 => result' });
			empty.createEl('p', { text: 'Add generators with: gen: System => result' });
		} else {
			this.renderEventsList(container, events);

			// Footer
			const footer = container.createDiv({ cls: 'solo-rpg-elements-footer' });
			footer.createEl('p', { text: `Showing ${events.length} random events` });
		}
	}

	private renderSearchAndFilter(container: HTMLElement) {
		const panel = container.createDiv({ cls: 'solo-rpg-filter-panel' });

		// Search
		const searchInput = panel.createEl('input', {
			type: 'text',
			placeholder: 'Search events...',
			value: this.searchQuery,
		});
		searchInput.addEventListener('input', (e) => {
			this.searchQuery = (e.target as HTMLInputElement).value;
			this.render();
		});

		// Type filter
		const filterContainer = panel.createDiv({ cls: 'solo-rpg-type-filters' });
		const types: { value: EventType; label: string }[] = [
			{ value: 'all', label: 'All' },
			{ value: 'tables', label: 'Tables' },
			{ value: 'generators', label: 'Generators' },
		];

		for (const type of types) {
			const chip = filterContainer.createDiv({
				cls: `solo-rpg-type-chip ${this.filterType === type.value ? 'active' : ''}`,
				text: type.label,
			});
			chip.addEventListener('click', () => {
				this.filterType = type.value;
				this.render();
			});
		}
	}

	private renderEventsList(container: HTMLElement, events: RandomEvent[]) {
		const list = container.createDiv({ cls: 'solo-rpg-element-list' });

		for (const event of events) {
			this.renderEventCard(list, event);
		}
	}

	private renderEventCard(container: HTMLElement, event: RandomEvent) {
		const card = container.createDiv({ cls: 'solo-rpg-element-card' });

		// Type badge
		const typeText = event.type === 'table' ? 'Table Lookup' : 'Generator';
		card.createDiv({ text: typeText, cls: 'solo-rpg-tag' });

		// Event details
		if (event.type === 'table') {
			const data = event.data as TableLookup;
			card.createDiv({ text: `${data.roll} => ${data.result}`, cls: 'solo-rpg-element-name' });
		} else {
			const data = event.data as Generator;
			card.createDiv({ text: `${data.system} => ${data.result}`, cls: 'solo-rpg-element-name' });
		}

		// Location metadata
		const meta = card.createDiv({ cls: 'solo-rpg-element-meta' });
		meta.createSpan({ text: `${event.campaign}` });
		if (event.session && event.scene) {
			meta.createSpan({ text: ` | ${event.session}, ${event.scene}` });
		}

		// Navigation
		card.addEventListener('click', () => {
			this.navigateToLocation(event.location.file, event.location.lineNumber);
		});
	}

	private getAllRandomEvents(): RandomEvent[] {
		const events: RandomEvent[] = [];
		const campaigns = this.indexer.getAllCampaigns();

		for (const campaign of campaigns) {
			for (const session of campaign.sessions) {
				for (const scene of session.scenes) {
					for (const element of scene.elements) {
						let shouldInclude = false;
						let eventType: 'table' | 'generator' | null = null;

						if (element.type === 'table_lookup') {
							shouldInclude = this.filterType === 'all' || this.filterType === 'tables';
							eventType = 'table';
						} else if (element.type === 'generator') {
							shouldInclude = this.filterType === 'all' || this.filterType === 'generators';
							eventType = 'generator';
						}

						if (shouldInclude && eventType) {
							const location: Location = {
								file: campaign.file,
								lineNumber: element.lineNumber,
								session: `Session ${session.number}`,
								scene: scene.number,
							};

							// Apply search filter
							if (this.searchQuery) {
								const query = this.searchQuery.toLowerCase();
								const searchText = element.type === 'table_lookup'
									? `${(element as TableLookup).roll} ${(element as TableLookup).result}`
									: `${(element as Generator).system} ${(element as Generator).result}`;

								if (!searchText.toLowerCase().includes(query)) {
									continue;
								}
							}

							events.push({
								type: eventType,
								data: element as TableLookup | Generator,
								location,
								campaign: campaign.title,
								session: `Session ${session.number}`,
								scene: scene.number,
							});
						}
					}
				}
			}
		}

		return events;
	}

	private async navigateToLocation(filePath: string, lineNumber: number) {
		const file = this.app.vault.getAbstractFileByPath(filePath);
		if (!(file instanceof TFile)) {
			new Notice(`File not found: ${filePath}`);
			return;
		}

		try {
			const leaf = this.app.workspace.getLeaf(false);
			await leaf.openFile(file);

			const view = this.app.workspace.getActiveViewOfType(ItemView);
			if (view) {
				// @ts-ignore
				const editor = view.editor;
				if (editor) {
					editor.setCursor({ line: lineNumber, ch: 0 });
					editor.scrollIntoView(
						{ from: { line: lineNumber, ch: 0 }, to: { line: lineNumber, ch: 0 } },
						true
					);
				}
			}
		} catch (error) {
			console.error('Error navigating to location:', error);
			new Notice('Could not navigate to location');
		}
	}
}

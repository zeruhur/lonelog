import { ItemView, WorkspaceLeaf, TFile, Notice } from 'obsidian';
import { NotationIndexer } from '../indexer/NotationIndexer';
import { NPC, LocationTag, Thread, Reference } from '../types/notation';

export const VIEW_TYPE_TAG_BROWSER = 'solo-rpg-tag-browser';

type TabType = 'npcs' | 'locations' | 'threads' | 'references';

/**
 * Tag browser view for NPCs, Locations, and Threads
 */
export class TagBrowserView extends ItemView {
	indexer: NotationIndexer;
	private currentTab: TabType = 'npcs';
	private searchQuery: string = '';

	constructor(leaf: WorkspaceLeaf, indexer: NotationIndexer) {
		super(leaf);
		this.indexer = indexer;
	}

	getViewType(): string {
		return VIEW_TYPE_TAG_BROWSER;
	}

	getDisplayText(): string {
		return 'Tag Browser';
	}

	getIcon(): string {
		return 'tags';
	}

	async onOpen() {
		await this.render();
	}

	async onClose() {
		// Cleanup if needed
	}

	/**
	 * Render the tag browser
	 */
	async render() {
		const container = this.containerEl.children[1] as HTMLElement;
		container.empty();
		container.addClass('solo-rpg-container');

		// Header
		const header = container.createDiv({ cls: 'solo-rpg-header' });
		header.createEl('h2', { text: 'Tag Browser', cls: 'solo-rpg-title' });

		// Tabs
		this.renderTabs(container);

		// Search
		this.renderSearch(container);

		// Content based on active tab
		this.renderTabContent(container);
	}

	/**
	 * Render tabs
	 */
	private renderTabs(container: HTMLElement) {
		const tabs = container.createDiv({ cls: 'solo-rpg-tabs' });

		const npcTab = tabs.createDiv({
			cls: `solo-rpg-tab ${this.currentTab === 'npcs' ? 'active' : ''}`,
			text: 'NPCs',
		});
		npcTab.addEventListener('click', () => {
			this.currentTab = 'npcs';
			this.render();
		});

		const locTab = tabs.createDiv({
			cls: `solo-rpg-tab ${this.currentTab === 'locations' ? 'active' : ''}`,
			text: 'Locations',
		});
		locTab.addEventListener('click', () => {
			this.currentTab = 'locations';
			this.render();
		});

		const threadTab = tabs.createDiv({
			cls: `solo-rpg-tab ${this.currentTab === 'threads' ? 'active' : ''}`,
			text: 'Threads',
		});
		threadTab.addEventListener('click', () => {
			this.currentTab = 'threads';
			this.render();
		});

		const referencesTab = tabs.createDiv({
			cls: `solo-rpg-tab ${this.currentTab === 'references' ? 'active' : ''}`,
			text: 'References',
		});
		referencesTab.addEventListener('click', () => {
			this.currentTab = 'references';
			this.render();
		});
	}

	/**
	 * Render search bar
	 */
	private renderSearch(container: HTMLElement) {
		const search = container.createEl('input', {
			type: 'text',
			cls: 'solo-rpg-search',
			placeholder: 'Search...',
			value: this.searchQuery,
		});

		search.addEventListener('input', (e) => {
			this.searchQuery = (e.target as HTMLInputElement).value;
			this.render();
		});
	}

	/**
	 * Render content based on active tab
	 */
	private renderTabContent(container: HTMLElement) {
		const content = container.createDiv({ cls: 'solo-rpg-tab-content' });

		switch (this.currentTab) {
			case 'npcs':
				this.renderNPCs(content);
				break;
			case 'locations':
				this.renderLocations(content);
				break;
			case 'threads':
				this.renderThreads(content);
				break;
			case 'references':
				this.renderReferences(content);
				break;
		}
	}

	/**
	 * Render NPCs list
	 */
	private renderNPCs(container: HTMLElement) {
		let npcs = this.indexer.getAllNPCs();

		// Filter by search query
		if (this.searchQuery) {
			const query = this.searchQuery.toLowerCase();
			npcs = npcs.filter(
				(npc) =>
					npc.name.toLowerCase().includes(query) ||
					npc.tags.some((tag) => tag.toLowerCase().includes(query))
			);
		}

		if (npcs.length === 0) {
			this.renderEmptyState(
				container,
				'No NPCs found',
				'Create one with notation: [N:Name|tags] in a code block'
			);
			return;
		}

		const list = container.createDiv({ cls: 'solo-rpg-element-list' });

		for (const npc of npcs) {
			this.renderNPCCard(list, npc);
		}
	}

	/**
	 * Render a single NPC card
	 */
	private renderNPCCard(container: HTMLElement, npc: NPC) {
		const card = container.createDiv({ cls: 'solo-rpg-element-card' });

		// Name
		card.createDiv({
			text: npc.name,
			cls: 'solo-rpg-element-name',
		});

		// Tags
		if (npc.tags.length > 0) {
			const tagsContainer = card.createDiv({ cls: 'solo-rpg-element-tags' });
			for (const tag of npc.tags) {
				tagsContainer.createSpan({
					text: tag,
					cls: 'solo-rpg-tag',
				});
			}
		}

		// Metadata
		const meta = card.createDiv({ cls: 'solo-rpg-element-meta' });
		meta.createSpan({ text: `Mentions: ${npc.mentions.length}` });

		const lastMention = npc.mentions[npc.mentions.length - 1];
		if (lastMention.session && lastMention.scene) {
			meta.createSpan({
				text: ` | Last seen: ${lastMention.session}, ${lastMention.scene}`,
			});
		}

		// Click to navigate
		card.addEventListener('click', () => {
			this.navigateToLocation(npc.firstMention.file, npc.firstMention.lineNumber);
		});
	}

	/**
	 * Render Locations list
	 */
	private renderLocations(container: HTMLElement) {
		let locations = this.indexer.getAllLocations();

		// Filter by search query
		if (this.searchQuery) {
			const query = this.searchQuery.toLowerCase();
			locations = locations.filter(
				(loc) =>
					loc.name.toLowerCase().includes(query) ||
					loc.tags.some((tag) => tag.toLowerCase().includes(query))
			);
		}

		if (locations.length === 0) {
			this.renderEmptyState(
				container,
				'No locations found',
				'Create one with notation: [L:Name|tags] in a code block'
			);
			return;
		}

		const list = container.createDiv({ cls: 'solo-rpg-element-list' });

		for (const location of locations) {
			this.renderLocationCard(list, location);
		}
	}

	/**
	 * Render a single Location card
	 */
	private renderLocationCard(container: HTMLElement, location: LocationTag) {
		const card = container.createDiv({ cls: 'solo-rpg-element-card' });

		// Name
		card.createDiv({
			text: location.name,
			cls: 'solo-rpg-element-name',
		});

		// Tags
		if (location.tags.length > 0) {
			const tagsContainer = card.createDiv({ cls: 'solo-rpg-element-tags' });
			for (const tag of location.tags) {
				tagsContainer.createSpan({
					text: tag,
					cls: 'solo-rpg-tag',
				});
			}
		}

		// Metadata
		const meta = card.createDiv({ cls: 'solo-rpg-element-meta' });
		meta.createSpan({ text: `Mentions: ${location.mentions.length}` });

		const lastMention = location.mentions[location.mentions.length - 1];
		if (lastMention.session && lastMention.scene) {
			meta.createSpan({
				text: ` | Last seen: ${lastMention.session}, ${lastMention.scene}`,
			});
		}

		// Click to navigate
		card.addEventListener('click', () => {
			this.navigateToLocation(
				location.firstMention.file,
				location.firstMention.lineNumber
			);
		});
	}

	/**
	 * Render Threads list
	 */
	private renderThreads(container: HTMLElement) {
		let threads = this.indexer.getAllThreads();

		// Filter by search query
		if (this.searchQuery) {
			const query = this.searchQuery.toLowerCase();
			threads = threads.filter(
				(thread) =>
					thread.name.toLowerCase().includes(query) ||
					thread.state.toLowerCase().includes(query)
			);
		}

		if (threads.length === 0) {
			this.renderEmptyState(
				container,
				'No threads found',
				'Create one with notation: [Thread:Name|Open] in a code block'
			);
			return;
		}

		const list = container.createDiv({ cls: 'solo-rpg-element-list' });

		for (const thread of threads) {
			this.renderThreadCard(list, thread);
		}
	}

	/**
	 * Render a single Thread card
	 */
	private renderThreadCard(container: HTMLElement, thread: Thread) {
		const card = container.createDiv({ cls: 'solo-rpg-element-card' });

		// Name
		card.createDiv({
			text: thread.name,
			cls: 'solo-rpg-element-name',
		});

		// State badge
		const stateColor = this.getThreadStateColor(thread.state);
		const stateBadge = card.createSpan({
			text: thread.state,
			cls: 'solo-rpg-tag',
		});
		stateBadge.style.backgroundColor = stateColor;

		// Metadata
		const meta = card.createDiv({ cls: 'solo-rpg-element-meta' });
		meta.createSpan({ text: `Mentions: ${thread.mentions.length}` });

		const lastMention = thread.mentions[thread.mentions.length - 1];
		if (lastMention.session && lastMention.scene) {
			meta.createSpan({
				text: ` | Last seen: ${lastMention.session}, ${lastMention.scene}`,
			});
		}

		// Click to navigate
		card.addEventListener('click', () => {
			this.navigateToLocation(
				thread.firstMention.file,
				thread.firstMention.lineNumber
			);
		});
	}

	/**
	 * Render references tab
	 */
	private renderReferences(container: HTMLElement) {
		let references = this.getAllReferences();

		// Apply search filter
		if (this.searchQuery) {
			const query = this.searchQuery.toLowerCase();
			references = references.filter(
				(ref) =>
					ref.name.toLowerCase().includes(query) ||
					ref.type.toLowerCase().includes(query)
			);
		}

		// Empty state
		if (references.length === 0) {
			this.renderEmptyState(
				container,
				'No references found',
				'Reference existing elements with: [#N:Name] or [#L:Name]'
			);
			return;
		}

		// Render list
		const list = container.createDiv({ cls: 'solo-rpg-element-list' });
		for (const ref of references) {
			this.renderReferenceCard(list, ref);
		}
	}

	/**
	 * Get all references from all campaigns
	 */
	private getAllReferences(): Reference[] {
		const references: Reference[] = [];
		for (const campaign of this.indexer.getAllCampaigns()) {
			references.push(...Array.from(campaign.references.values()));
		}
		return references;
	}

	/**
	 * Render individual reference card
	 */
	private renderReferenceCard(container: HTMLElement, reference: Reference) {
		const card = container.createDiv({ cls: 'solo-rpg-element-card' });

		// Reference name with type badge
		const nameContainer = card.createDiv({ cls: 'solo-rpg-element-name' });
		nameContainer.createSpan({ text: reference.name });

		// Type badge
		const typeBadge = nameContainer.createSpan({
			text: ` (${reference.type})`,
			cls: 'solo-rpg-tag'
		});

		// Metadata
		const meta = card.createDiv({ cls: 'solo-rpg-element-meta' });
		meta.createSpan({ text: `Mentions: ${reference.mentions.length}` });

		// Last seen location
		if (reference.mentions.length > 0) {
			const lastMention = reference.mentions[reference.mentions.length - 1];
			if (lastMention.session && lastMention.scene) {
				meta.createSpan({
					text: ` | Last seen: ${lastMention.session}, ${lastMention.scene}`,
				});
			}
		}

		// Navigation on click
		card.addEventListener('click', () => {
			this.navigateToLocation(
				reference.firstMention.file,
				reference.firstMention.lineNumber
			);
		});
	}

	/**
	 * Get color for thread state
	 */
	private getThreadStateColor(state: string): string {
		const stateLower = state.toLowerCase();
		if (stateLower === 'open') return 'var(--interactive-accent)';
		if (stateLower === 'closed') return 'var(--text-success)';
		if (stateLower === 'abandoned') return 'var(--text-muted)';
		return 'var(--background-secondary)';
	}

	/**
	 * Render empty state with helpful notation hints
	 */
	private renderEmptyState(container: HTMLElement, message: string, hint?: string) {
		const empty = container.createDiv({ cls: 'solo-rpg-empty' });
		empty.createEl('p', {
			text: message,
			cls: 'solo-rpg-empty-text',
		});

		if (hint) {
			const hintEl = empty.createEl('p', {
				cls: 'solo-rpg-empty-hint',
			});
			hintEl.createSpan({ text: hint });
		}
	}

	/**
	 * Navigate to a location in a file
	 */
	private async navigateToLocation(filePath: string, lineNumber: number) {
		const file = this.app.vault.getAbstractFileByPath(filePath);
		if (!(file instanceof TFile)) {
			new Notice(`File not found: ${filePath}`);
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
					if (lineNumber >= lineCount) {
						new Notice('Location not found in file, opened at top');
						editor.setCursor({ line: 0, ch: 0 });
					} else {
						editor.setCursor({ line: lineNumber, ch: 0 });
						editor.scrollIntoView({ from: { line: lineNumber, ch: 0 }, to: { line: lineNumber, ch: 0 } }, true);
					}
				}
			}
		} catch (error) {
			console.error('Navigation error:', error);
			new Notice(`Could not navigate to location: ${error instanceof Error ? error.message : 'Unknown error'}`);
		}
	}
}

import { ItemView, WorkspaceLeaf, TFile, Notice } from 'obsidian';
import { NotationIndexer } from '../indexer/NotationIndexer';
import { MetaNote, Location } from '../types/notation';

export const VIEW_TYPE_META_NOTES = 'solo-rpg-meta-notes';

type CategoryFilter = 'all' | 'note' | 'reflection' | 'house_rule' | 'reminder' | 'question';

interface MetaNoteWithContext {
	note: MetaNote;
	location: Location;
	campaign: string;
	session: string;
	scene: string;
}

export class MetaNotesView extends ItemView {
	indexer: NotationIndexer;
	private searchQuery: string = '';
	private categoryFilter: CategoryFilter = 'all';

	constructor(leaf: WorkspaceLeaf, indexer: NotationIndexer) {
		super(leaf);
		this.indexer = indexer;
	}

	getViewType(): string {
		return VIEW_TYPE_META_NOTES;
	}

	getDisplayText(): string {
		return 'Meta Notes';
	}

	getIcon(): string {
		return 'sticky-note';
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
		header.createEl('h2', { text: 'Meta Notes', cls: 'solo-rpg-title' });

		const refreshBtn = header.createEl('button', { text: '↻ Refresh' });
		refreshBtn.addEventListener('click', () => this.render());

		// Search and filter
		this.renderSearchAndFilter(container);

		// Get all notes
		const notes = this.getAllMetaNotes();

		// Display
		if (notes.length === 0) {
			const empty = container.createDiv({ cls: 'solo-rpg-empty-state' });
			empty.createEl('p', { text: 'No meta notes found matching the current filters.' });
			empty.createEl('p', { text: 'Add notes with: (note: content)' });
			empty.createEl('p', { text: 'Categories: note, reflection, house rule, reminder, question' });
		} else {
			this.renderNotesList(container, notes);

			// Footer
			const footer = container.createDiv({ cls: 'solo-rpg-elements-footer' });
			footer.createEl('p', { text: `Showing ${notes.length} meta notes` });
		}
	}

	private renderSearchAndFilter(container: HTMLElement) {
		const panel = container.createDiv({ cls: 'solo-rpg-filter-panel' });

		// Search
		const searchInput = panel.createEl('input', {
			type: 'text',
			placeholder: 'Search notes...',
			value: this.searchQuery,
		});
		searchInput.addEventListener('input', (e) => {
			this.searchQuery = (e.target as HTMLInputElement).value;
			this.render();
		});

		// Category filter
		const filterLabel = panel.createEl('label', { text: 'Category:' });
		filterLabel.style.fontWeight = 'bold';
		filterLabel.style.marginBottom = '4px';
		filterLabel.style.display = 'block';

		const filterContainer = panel.createDiv({ cls: 'solo-rpg-type-filters' });
		const categories: { value: CategoryFilter; label: string }[] = [
			{ value: 'all', label: 'All' },
			{ value: 'note', label: 'Notes' },
			{ value: 'reflection', label: 'Reflections' },
			{ value: 'house_rule', label: 'House Rules' },
			{ value: 'reminder', label: 'Reminders' },
			{ value: 'question', label: 'Questions' },
		];

		for (const cat of categories) {
			const chip = filterContainer.createDiv({
				cls: `solo-rpg-type-chip ${this.categoryFilter === cat.value ? 'active' : ''}`,
				text: cat.label,
			});
			chip.addEventListener('click', () => {
				this.categoryFilter = cat.value;
				this.render();
			});
		}
	}

	private renderNotesList(container: HTMLElement, notes: MetaNoteWithContext[]) {
		const list = container.createDiv({ cls: 'solo-rpg-element-list' });

		for (const noteCtx of notes) {
			this.renderNoteCard(list, noteCtx);
		}
	}

	private renderNoteCard(container: HTMLElement, noteCtx: MetaNoteWithContext) {
		const card = container.createDiv({ cls: 'solo-rpg-element-card' });

		// Category badge
		const categoryLabel = noteCtx.note.category.replace('_', ' ');
		card.createDiv({
			text: categoryLabel.charAt(0).toUpperCase() + categoryLabel.slice(1),
			cls: 'solo-rpg-tag'
		});

		// Note content
		card.createDiv({ text: noteCtx.note.content, cls: 'solo-rpg-element-name' });

		// Location metadata
		const meta = card.createDiv({ cls: 'solo-rpg-element-meta' });
		meta.createSpan({ text: `${noteCtx.campaign}` });
		if (noteCtx.session && noteCtx.scene) {
			meta.createSpan({ text: ` | ${noteCtx.session}, ${noteCtx.scene}` });
		}

		// Navigation
		card.addEventListener('click', () => {
			this.navigateToLocation(noteCtx.location.file, noteCtx.location.lineNumber);
		});
	}

	private getAllMetaNotes(): MetaNoteWithContext[] {
		const notes: MetaNoteWithContext[] = [];
		const campaigns = this.indexer.getAllCampaigns();

		for (const campaign of campaigns) {
			for (const session of campaign.sessions) {
				for (const scene of session.scenes) {
					for (const element of scene.elements) {
						if (element.type === 'meta_note') {
							// Apply category filter
							if (this.categoryFilter !== 'all' && element.category !== this.categoryFilter) {
								continue;
							}

							// Apply search filter
							if (this.searchQuery) {
								const query = this.searchQuery.toLowerCase();
								if (!element.content.toLowerCase().includes(query)) {
									continue;
								}
							}

							const location: Location = {
								file: campaign.file,
								lineNumber: element.lineNumber,
								session: `Session ${session.number}`,
								scene: scene.number,
							};

							notes.push({
								note: element,
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

		return notes;
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

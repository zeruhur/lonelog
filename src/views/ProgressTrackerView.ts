import { ItemView, WorkspaceLeaf, TFile, Notice } from 'obsidian';
import { NotationIndexer } from '../indexer/NotationIndexer';
import { Clock, Track, Timer, Event } from '../types/notation';
import { ProgressParser } from '../parser/ProgressParser';
import { SoloRPGSettings } from '../settings';

export const VIEW_TYPE_PROGRESS_TRACKER = 'solo-rpg-progress-tracker';

type TabType = 'clocks' | 'tracks' | 'timers';

/**
 * Progress tracker view for Clocks, Tracks, and Timers
 */
export class ProgressTrackerView extends ItemView {
	indexer: NotationIndexer;
	settings: SoloRPGSettings;
	progressParser: ProgressParser;
	private currentTab: TabType = 'clocks';

	constructor(leaf: WorkspaceLeaf, indexer: NotationIndexer, settings: SoloRPGSettings) {
		super(leaf);
		this.indexer = indexer;
		this.settings = settings;
		this.progressParser = new ProgressParser();
	}

	getViewType(): string {
		return VIEW_TYPE_PROGRESS_TRACKER;
	}

	getDisplayText(): string {
		return 'Progress Tracker';
	}

	getIcon(): string {
		return 'clock';
	}

	async onOpen() {
		await this.render();
	}

	async onClose() {
		// Cleanup if needed
	}

	/**
	 * Render the progress tracker
	 */
	async render() {
		const container = this.containerEl.children[1] as HTMLElement;
		container.empty();
		container.addClass('solo-rpg-container');

		// Header
		const header = container.createDiv({ cls: 'solo-rpg-header' });
		header.createEl('h2', { text: 'Progress Tracker', cls: 'solo-rpg-title' });

		// Tabs
		this.renderTabs(container);

		// Content based on active tab
		this.renderTabContent(container);
	}

	/**
	 * Render tabs
	 */
	private renderTabs(container: HTMLElement) {
		const tabs = container.createDiv({ cls: 'solo-rpg-tabs' });

		const clockTab = tabs.createDiv({
			cls: `solo-rpg-tab ${this.currentTab === 'clocks' ? 'active' : ''}`,
			text: 'Clocks',
		});
		clockTab.addEventListener('click', () => {
			this.currentTab = 'clocks';
			this.render();
		});

		const trackTab = tabs.createDiv({
			cls: `solo-rpg-tab ${this.currentTab === 'tracks' ? 'active' : ''}`,
			text: 'Tracks',
		});
		trackTab.addEventListener('click', () => {
			this.currentTab = 'tracks';
			this.render();
		});

		const timerTab = tabs.createDiv({
			cls: `solo-rpg-tab ${this.currentTab === 'timers' ? 'active' : ''}`,
			text: 'Timers',
		});
		timerTab.addEventListener('click', () => {
			this.currentTab = 'timers';
			this.render();
		});
	}

	/**
	 * Render content based on active tab
	 */
	private renderTabContent(container: HTMLElement) {
		const content = container.createDiv({ cls: 'solo-rpg-tab-content' });

		switch (this.currentTab) {
			case 'clocks':
				this.renderClocks(content);
				break;
			case 'tracks':
				this.renderTracks(content);
				break;
			case 'timers':
				this.renderTimers(content);
				break;
		}
	}

	/**
	 * Render Clocks list
	 */
	private renderClocks(container: HTMLElement) {
		const campaigns = this.indexer.getAllCampaigns();
		const allClocks: Clock[] = [];

		for (const campaign of campaigns) {
			allClocks.push(...Array.from(campaign.clocks.values()));
		}

		// Also get events (which are like clocks)
		for (const campaign of campaigns) {
			allClocks.push(...Array.from(campaign.events.values()));
		}

		if (allClocks.length === 0) {
			this.renderEmptyState(
				container,
				'No clocks found',
				'Create one with notation: [Clock:Name 0/6]'
			);
			return;
		}

		const list = container.createDiv({ cls: 'solo-rpg-progress-list' });

		for (const clock of allClocks) {
			this.renderClockItem(list, clock);
		}
	}

	/**
	 * Render a single Clock item
	 */
	private renderClockItem(container: HTMLElement, clock: Clock | Event) {
		const item = container.createDiv({ cls: 'solo-rpg-progress-item' });

		// Header
		const header = item.createDiv({ cls: 'solo-rpg-progress-header' });
		header.createDiv({
			text: clock.name,
			cls: 'solo-rpg-progress-name',
		});
		header.createDiv({
			text: `${clock.current}/${clock.total}`,
			cls: 'solo-rpg-progress-value',
		});

		// Progress visualization
		if (this.settings.showProgressBars) {
			if (this.settings.clockStyle === 'circle') {
				this.renderCircleProgress(item, clock.current, clock.total);
			} else if (this.settings.clockStyle === 'segments') {
				this.renderSegmentProgress(item, clock.current, clock.total);
			} else {
				this.renderBarProgress(item, clock.current, clock.total);
			}
		}

		// Status
		const percentage = this.progressParser.calculateProgress(clock.current, clock.total);
		const status = item.createDiv({ cls: 'solo-rpg-progress-status' });

		if (this.progressParser.isComplete(clock.current, clock.total)) {
			status.createSpan({ text: '✅ Complete', cls: 'complete' });
		} else if (this.progressParser.isNearComplete(clock.current, clock.total)) {
			status.createSpan({ text: '⚠️ Near complete', cls: 'warning' });
		} else {
			status.createSpan({ text: `${percentage}%` });
		}

		// Click to navigate
		item.addEventListener('click', () => {
			if (clock.locations.length > 0) {
				const loc = clock.locations[0];
				this.navigateToLocation(loc.file, loc.lineNumber);
			}
		});
	}

	/**
	 * Render Tracks list
	 */
	private renderTracks(container: HTMLElement) {
		const campaigns = this.indexer.getAllCampaigns();
		const allTracks: Track[] = [];

		for (const campaign of campaigns) {
			allTracks.push(...Array.from(campaign.tracks.values()));
		}

		if (allTracks.length === 0) {
			this.renderEmptyState(
				container,
				'No tracks found',
				'Create one with notation: [Track:Name 0/10]'
			);
			return;
		}

		const list = container.createDiv({ cls: 'solo-rpg-progress-list' });

		for (const track of allTracks) {
			this.renderTrackItem(list, track);
		}
	}

	/**
	 * Render a single Track item
	 */
	private renderTrackItem(container: HTMLElement, track: Track) {
		const item = container.createDiv({ cls: 'solo-rpg-progress-item' });

		// Header
		const header = item.createDiv({ cls: 'solo-rpg-progress-header' });
		header.createDiv({
			text: track.name,
			cls: 'solo-rpg-progress-name',
		});
		header.createDiv({
			text: `${track.current}/${track.total}`,
			cls: 'solo-rpg-progress-value',
		});

		// Progress bar
		if (this.settings.showProgressBars) {
			this.renderBarProgress(item, track.current, track.total);
		}

		// Status
		const percentage = this.progressParser.calculateProgress(track.current, track.total);
		const status = item.createDiv({ cls: 'solo-rpg-progress-status' });

		if (this.progressParser.isComplete(track.current, track.total)) {
			status.createSpan({ text: '✅ Complete', cls: 'complete' });
		} else if (this.progressParser.isNearComplete(track.current, track.total)) {
			status.createSpan({ text: '🎯 Almost there!', cls: 'near-complete' });
		} else {
			status.createSpan({ text: `${percentage}%` });
		}

		// Click to navigate
		item.addEventListener('click', () => {
			if (track.locations.length > 0) {
				const loc = track.locations[0];
				this.navigateToLocation(loc.file, loc.lineNumber);
			}
		});
	}

	/**
	 * Render Timers list
	 */
	private renderTimers(container: HTMLElement) {
		const campaigns = this.indexer.getAllCampaigns();
		const allTimers: Timer[] = [];

		for (const campaign of campaigns) {
			allTimers.push(...Array.from(campaign.timers.values()));
		}

		if (allTimers.length === 0) {
			this.renderEmptyState(
				container,
				'No timers found',
				'Create one with notation: [Timer:Name 5]'
			);
			return;
		}

		const list = container.createDiv({ cls: 'solo-rpg-progress-list' });

		for (const timer of allTimers) {
			this.renderTimerItem(list, timer);
		}
	}

	/**
	 * Render a single Timer item
	 */
	private renderTimerItem(container: HTMLElement, timer: Timer) {
		const item = container.createDiv({ cls: 'solo-rpg-progress-item' });

		// Header
		const header = item.createDiv({ cls: 'solo-rpg-progress-header' });
		header.createDiv({
			text: timer.name,
			cls: 'solo-rpg-progress-name',
		});

		const valueDiv = header.createDiv({ cls: 'solo-rpg-timer-value' });
		if (this.progressParser.isTimerUrgent(timer.value)) {
			valueDiv.addClass('urgent');
		}
		valueDiv.setText(timer.value.toString());

		// Status
		const status = item.createDiv({ cls: 'solo-rpg-progress-status' });
		if (timer.value === 0) {
			status.createSpan({ text: '⏰ Time\'s up!', cls: 'expired' });
		} else if (this.progressParser.isTimerUrgent(timer.value)) {
			status.createSpan({ text: '⚠️ Urgent!', cls: 'urgent' });
		} else {
			status.createSpan({ text: `${timer.value} remaining` });
		}

		// Click to navigate
		item.addEventListener('click', () => {
			if (timer.locations.length > 0) {
				const loc = timer.locations[0];
				this.navigateToLocation(loc.file, loc.lineNumber);
			}
		});
	}

	/**
	 * Render circle progress indicator
	 */
	private renderCircleProgress(container: HTMLElement, current: number, total: number) {
		const percentage = (current / total) * 100;
		const svg = container.createSvg('svg', { cls: 'solo-rpg-progress-circle' });
		svg.setAttribute('viewBox', '0 0 36 36');

		// Background circle
		const bgCircle = svg.createSvg('circle', { cls: 'solo-rpg-progress-circle-bg' });
		bgCircle.setAttribute('cx', '18');
		bgCircle.setAttribute('cy', '18');
		bgCircle.setAttribute('r', '15.915');

		// Progress circle
		const progressCircle = svg.createSvg('circle', { cls: 'solo-rpg-progress-circle-fill' });
		progressCircle.setAttribute('cx', '18');
		progressCircle.setAttribute('cy', '18');
		progressCircle.setAttribute('r', '15.915');
		progressCircle.setAttribute('stroke-dasharray', `${percentage} 100`);
	}

	/**
	 * Render segment progress indicator (pie segments)
	 */
	private renderSegmentProgress(container: HTMLElement, current: number, total: number) {
		const segments = container.createDiv({ cls: 'solo-rpg-progress-segments' });

		for (let i = 0; i < total; i++) {
			const segment = segments.createDiv({ cls: 'solo-rpg-progress-segment' });
			if (i < current) {
				segment.addClass('filled');
			}
		}
	}

	/**
	 * Render bar progress indicator
	 */
	private renderBarProgress(container: HTMLElement, current: number, total: number) {
		const percentage = (current / total) * 100;
		const barContainer = container.createDiv({ cls: 'solo-rpg-progress-bar-container' });
		const bar = barContainer.createDiv({ cls: 'solo-rpg-progress-bar-fill' });
		bar.style.width = `${percentage}%`;
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

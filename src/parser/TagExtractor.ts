import {
	NPC,
	LocationTag,
	Thread,
	PlayerCharacter,
	Clock,
	Track,
	Timer,
	Event,
	Location,
	ExtractedTags,
} from '../types/notation';

/**
 * Regex patterns for extracting tags
 */
const TAG_PATTERNS = {
	npc: /\[N:([^|\]]+)(?:\|([^\]]+))?\]/g,
	npcRef: /\[#N:([^|\]]+)(?:\|([^\]]+))?\]/g,
	location: /\[L:([^|\]]+)(?:\|([^\]]+))?\]/g,
	locationRef: /\[#L:([^|\]]+)(?:\|([^\]]+))?\]/g,
	thread: /\[Thread:([^|\]]+)\|([^\]]+)\]/g,
	clock: /\[Clock:([^\]]+)\s+(\d+)\/(\d+)\]/g,
	track: /\[Track:([^\]]+)\s+(\d+)\/(\d+)\]/g,
	timer: /\[Timer:([^\]]+)\s+(\d+)\]/g,
	event: /\[E:([^\]]+)\s+(\d+)\/(\d+)\]/g,
	pc: /\[PC:([^|\]]+)(?:\|([^\]]+))?\]/g,
};

/**
 * Extract tags from notation content
 */
export class TagExtractor {
	/**
	 * Extract all tags from content
	 */
	extractTags(content: string, location: Location): ExtractedTags {
		return {
			npcs: this.extractNPCs(content, location),
			locations: this.extractLocations(content, location),
			threads: this.extractThreads(content, location),
			clocks: this.extractClocks(content, location),
			tracks: this.extractTracks(content, location),
			timers: this.extractTimers(content, location),
			events: this.extractEvents(content, location),
			playerCharacters: this.extractPlayerCharacters(content, location),
		};
	}

	/**
	 * Extract NPCs
	 */
	extractNPCs(content: string, location: Location): NPC[] {
		const npcs: NPC[] = [];
		const pattern = new RegExp(TAG_PATTERNS.npc);
		let match;

		while ((match = pattern.exec(content)) !== null) {
			const name = match[1].trim();
			const tagsStr = match[2] || '';
			const tags = tagsStr.split('|').map(t => t.trim()).filter(t => t);

			npcs.push({
				id: `npc:${name.toLowerCase()}`,
				name,
				tags,
				firstMention: location,
				mentions: [location],
			});
		}

		return npcs;
	}

	/**
	 * Extract Locations
	 */
	extractLocations(content: string, location: Location): LocationTag[] {
		const locations: LocationTag[] = [];
		const pattern = new RegExp(TAG_PATTERNS.location);
		let match;

		while ((match = pattern.exec(content)) !== null) {
			const name = match[1].trim();
			const tagsStr = match[2] || '';
			const tags = tagsStr.split('|').map(t => t.trim()).filter(t => t);

			locations.push({
				id: `location:${name.toLowerCase()}`,
				name,
				tags,
				firstMention: location,
				mentions: [location],
			});
		}

		return locations;
	}

	/**
	 * Extract Threads
	 */
	extractThreads(content: string, location: Location): Thread[] {
		const threads: Thread[] = [];
		const pattern = new RegExp(TAG_PATTERNS.thread);
		let match;

		while ((match = pattern.exec(content)) !== null) {
			const name = match[1].trim();
			const state = match[2].trim();

			threads.push({
				id: `thread:${name.toLowerCase()}`,
				name,
				state,
				firstMention: location,
				mentions: [location],
			});
		}

		return threads;
	}

	/**
	 * Extract Clocks
	 */
	extractClocks(content: string, location: Location): Clock[] {
		const clocks: Clock[] = [];
		const pattern = new RegExp(TAG_PATTERNS.clock);
		let match;

		while ((match = pattern.exec(content)) !== null) {
			const name = match[1].trim();
			const current = parseInt(match[2]);
			const total = parseInt(match[3]);

			clocks.push({
				id: `clock:${name.toLowerCase()}`,
				name,
				current,
				total,
				locations: [location],
			});
		}

		return clocks;
	}

	/**
	 * Extract Tracks
	 */
	extractTracks(content: string, location: Location): Track[] {
		const tracks: Track[] = [];
		const pattern = new RegExp(TAG_PATTERNS.track);
		let match;

		while ((match = pattern.exec(content)) !== null) {
			const name = match[1].trim();
			const current = parseInt(match[2]);
			const total = parseInt(match[3]);

			tracks.push({
				id: `track:${name.toLowerCase()}`,
				name,
				current,
				total,
				locations: [location],
			});
		}

		return tracks;
	}

	/**
	 * Extract Timers
	 */
	extractTimers(content: string, location: Location): Timer[] {
		const timers: Timer[] = [];
		const pattern = new RegExp(TAG_PATTERNS.timer);
		let match;

		while ((match = pattern.exec(content)) !== null) {
			const name = match[1].trim();
			const value = parseInt(match[2]);

			timers.push({
				id: `timer:${name.toLowerCase()}`,
				name,
				value,
				locations: [location],
			});
		}

		return timers;
	}

	/**
	 * Extract Events
	 */
	extractEvents(content: string, location: Location): Event[] {
		const events: Event[] = [];
		const pattern = new RegExp(TAG_PATTERNS.event);
		let match;

		while ((match = pattern.exec(content)) !== null) {
			const name = match[1].trim();
			const current = parseInt(match[2]);
			const total = parseInt(match[3]);

			events.push({
				id: `event:${name.toLowerCase()}`,
				name,
				current,
				total,
				locations: [location],
			});
		}

		return events;
	}

	/**
	 * Extract Player Characters
	 */
	extractPlayerCharacters(content: string, location: Location): PlayerCharacter[] {
		const pcs: PlayerCharacter[] = [];
		const pattern = new RegExp(TAG_PATTERNS.pc);
		let match;

		while ((match = pattern.exec(content)) !== null) {
			const name = match[1].trim();
			const statsStr = match[2] || '';
			const stats = new Map<string, string>();

			// Parse stats (format: key:value or key value)
			if (statsStr) {
				const statPairs = statsStr.split('|');
				for (const pair of statPairs) {
					const [key, value] = pair.split(/[:=]/).map(s => s.trim());
					if (key && value) {
						stats.set(key, value);
					}
				}
			}

			pcs.push({
				id: `pc:${name.toLowerCase()}`,
				name,
				stats,
				locations: [location],
			});
		}

		return pcs;
	}

	/**
	 * Check if a line contains a reference tag (e.g., [#N:Name])
	 */
	isReference(content: string): boolean {
		return /\[#[NL]:/.test(content);
	}

	/**
	 * Extract reference names from content
	 */
	extractReferences(content: string): { type: 'npc' | 'location', name: string }[] {
		const refs: { type: 'npc' | 'location', name: string }[] = [];

		// NPC references (e.g., [#N:Name] or [#N:Name|tag])
		const npcRefPattern = new RegExp(TAG_PATTERNS.npcRef);
		let match;
		while ((match = npcRefPattern.exec(content)) !== null) {
			refs.push({ type: 'npc', name: match[1].trim() });
		}

		// Location references (e.g., [#L:Name] or [#L:Name|tag])
		const locationRefPattern = new RegExp(TAG_PATTERNS.locationRef);
		while ((match = locationRefPattern.exec(content)) !== null) {
			refs.push({ type: 'location', name: match[1].trim() });
		}

		return refs;
	}
}

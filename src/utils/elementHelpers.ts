import {
	Campaign,
	NPC,
	LocationTag,
	Thread,
	Clock,
	Track,
	Timer,
	Event,
	PlayerCharacter,
	Location,
} from '../types/notation';

/**
 * Unified element interface for the All Elements View
 */
export interface UnifiedElement {
	id: string;
	name: string;
	type: 'NPC' | 'Location' | 'Thread' | 'Clock' | 'Track' | 'Timer' | 'Event' | 'PC';
	campaign: string;
	tags: string[];
	mentions: number;
	lastSeen: string;
	progress?: string;
	navigateTo: Location;
}

/**
 * Get campaign name from campaign object
 */
export function getCampaignName(campaign: Campaign): string {
	return campaign.title || 'Untitled Campaign';
}

/**
 * Format last seen location
 */
export function formatLastSeen(location: Location): string {
	if (location.session && location.scene) {
		return `${location.session}, Scene ${location.scene}`;
	} else if (location.session) {
		return location.session;
	} else {
		return `Line ${location.lineNumber}`;
	}
}

/**
 * Format progress as "X/Y (Z%)"
 */
export function formatProgress(current: number, total: number): string {
	const percentage = total > 0 ? Math.round((current / total) * 100) : 0;
	return `${current}/${total} (${percentage}%)`;
}

/**
 * Normalize NPC to UnifiedElement
 */
export function normalizeNPC(npc: NPC, campaign: Campaign): UnifiedElement {
	return {
		id: npc.id,
		name: npc.name,
		type: 'NPC',
		campaign: getCampaignName(campaign),
		tags: npc.tags,
		mentions: npc.mentions.length,
		lastSeen: npc.mentions.length > 0
			? formatLastSeen(npc.mentions[npc.mentions.length - 1])
			: formatLastSeen(npc.firstMention),
		navigateTo: npc.firstMention,
	};
}

/**
 * Normalize Location to UnifiedElement
 */
export function normalizeLocation(location: LocationTag, campaign: Campaign): UnifiedElement {
	return {
		id: location.id,
		name: location.name,
		type: 'Location',
		campaign: getCampaignName(campaign),
		tags: location.tags,
		mentions: location.mentions.length,
		lastSeen: location.mentions.length > 0
			? formatLastSeen(location.mentions[location.mentions.length - 1])
			: formatLastSeen(location.firstMention),
		navigateTo: location.firstMention,
	};
}

/**
 * Normalize Thread to UnifiedElement
 */
export function normalizeThread(thread: Thread, campaign: Campaign): UnifiedElement {
	return {
		id: thread.id,
		name: thread.name,
		type: 'Thread',
		campaign: getCampaignName(campaign),
		tags: [],
		mentions: thread.mentions.length,
		lastSeen: thread.mentions.length > 0
			? formatLastSeen(thread.mentions[thread.mentions.length - 1])
			: formatLastSeen(thread.firstMention),
		progress: thread.state,
		navigateTo: thread.firstMention,
	};
}

/**
 * Normalize Clock to UnifiedElement
 */
export function normalizeClock(clock: Clock, campaign: Campaign): UnifiedElement {
	return {
		id: clock.id,
		name: clock.name,
		type: 'Clock',
		campaign: getCampaignName(campaign),
		tags: [],
		mentions: clock.locations.length,
		lastSeen: clock.locations.length > 0
			? formatLastSeen(clock.locations[clock.locations.length - 1])
			: 'N/A',
		progress: formatProgress(clock.current, clock.total),
		navigateTo: clock.locations.length > 0
			? clock.locations[0]
			: { file: campaign.file, lineNumber: 0 },
	};
}

/**
 * Normalize Track to UnifiedElement
 */
export function normalizeTrack(track: Track, campaign: Campaign): UnifiedElement {
	return {
		id: track.id,
		name: track.name,
		type: 'Track',
		campaign: getCampaignName(campaign),
		tags: [],
		mentions: track.locations.length,
		lastSeen: track.locations.length > 0
			? formatLastSeen(track.locations[track.locations.length - 1])
			: 'N/A',
		progress: formatProgress(track.current, track.total),
		navigateTo: track.locations.length > 0
			? track.locations[0]
			: { file: campaign.file, lineNumber: 0 },
	};
}

/**
 * Normalize Timer to UnifiedElement
 */
export function normalizeTimer(timer: Timer, campaign: Campaign): UnifiedElement {
	return {
		id: timer.id,
		name: timer.name,
		type: 'Timer',
		campaign: getCampaignName(campaign),
		tags: [],
		mentions: timer.locations.length,
		lastSeen: timer.locations.length > 0
			? formatLastSeen(timer.locations[timer.locations.length - 1])
			: 'N/A',
		progress: `${timer.value}`,
		navigateTo: timer.locations.length > 0
			? timer.locations[0]
			: { file: campaign.file, lineNumber: 0 },
	};
}

/**
 * Normalize Event to UnifiedElement
 */
export function normalizeEvent(event: Event, campaign: Campaign): UnifiedElement {
	return {
		id: event.id,
		name: event.name,
		type: 'Event',
		campaign: getCampaignName(campaign),
		tags: [],
		mentions: event.locations.length,
		lastSeen: event.locations.length > 0
			? formatLastSeen(event.locations[event.locations.length - 1])
			: 'N/A',
		progress: formatProgress(event.current, event.total),
		navigateTo: event.locations.length > 0
			? event.locations[0]
			: { file: campaign.file, lineNumber: 0 },
	};
}

/**
 * Normalize Player Character to UnifiedElement
 */
export function normalizePC(pc: PlayerCharacter, campaign: Campaign): UnifiedElement {
	const stats: string[] = [];
	pc.stats.forEach((value, key) => {
		stats.push(`${key}: ${value}`);
	});

	return {
		id: pc.id,
		name: pc.name,
		type: 'PC',
		campaign: getCampaignName(campaign),
		tags: stats,
		mentions: pc.locations.length,
		lastSeen: pc.locations.length > 0
			? formatLastSeen(pc.locations[pc.locations.length - 1])
			: 'N/A',
		navigateTo: pc.locations.length > 0
			? pc.locations[0]
			: { file: campaign.file, lineNumber: 0 },
	};
}

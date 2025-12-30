/**
 * Snippet definitions for Solo RPG Notation
 */

export interface Snippet {
	trigger: string;
	description: string;
	content: string;
}

export const SNIPPETS: Snippet[] = [
	// Core notation patterns
	{
		trigger: 'action',
		description: 'Player action sequence',
		content: '> ${1:action}\nd: ${2:roll} => ${3:outcome}\n=> ${4:consequence}',
	},
	{
		trigger: 'oracle',
		description: 'Oracle question sequence',
		content: '? ${1:question}\n-> ${2:answer}\n=> ${3:consequence}',
	},
	{
		trigger: 'combined',
		description: 'Combined action and oracle',
		content: '> ${1:action}\nd: ${2:roll} => ${3:outcome}\n=> ${4:consequence}\n\n? ${5:question}\n-> ${6:answer}\n=> ${7:consequence}',
	},

	// Tags
	{
		trigger: 'npc',
		description: 'NPC tag',
		content: '[N:${1:Name}|${2:tags}]',
	},
	{
		trigger: 'npcref',
		description: 'NPC reference',
		content: '[#N:${1:Name}]',
	},
	{
		trigger: 'location',
		description: 'Location tag',
		content: '[L:${1:Name}|${2:tags}]',
	},
	{
		trigger: 'thread',
		description: 'Story thread',
		content: '[Thread:${1:Name}|${2:Open}]',
	},
	{
		trigger: 'pc',
		description: 'Player character',
		content: '[PC:${1:Name}|${2:stats}]',
	},

	// Progress tracking
	{
		trigger: 'clock',
		description: 'Clock (fills up)',
		content: '[Clock:${1:Name} ${2:0}/${3:6}]',
	},
	{
		trigger: 'track',
		description: 'Progress track',
		content: '[Track:${1:Name} ${2:0}/${3:10}]',
	},
	{
		trigger: 'timer',
		description: 'Countdown timer',
		content: '[Timer:${1:Name} ${2:5}]',
	},
	{
		trigger: 'event',
		description: 'Event clock',
		content: '[E:${1:Name} ${2:0}/${3:6}]',
	},

	// Structure
	{
		trigger: 'scene',
		description: 'Scene header',
		content: '### S${1:1} *${2:context}*\n\n```\n${3}\n```',
	},
	{
		trigger: 'session',
		description: 'Session header',
		content: '## Session ${1:1}\n*Date: ${2:YYYY-MM-DD} | Duration: ${3:2h}*\n\n**Recap:** ${4}\n\n**Goals:** ${5}',
	},

	// Dialogue
	{
		trigger: 'dialogue',
		description: 'NPC dialogue',
		content: 'N (${1:Name}): "${2:speech}"\nPC: "${3:response}"',
	},

	// Narrative blocks
	{
		trigger: 'narrative',
		description: 'Narrative block',
		content: '---\n${1:narrative}\n---',
	},

	// Meta notes
	{
		trigger: 'note',
		description: 'Meta note',
		content: '(note: ${1:your note here})',
	},

	// Random tables
	{
		trigger: 'table',
		description: 'Table lookup',
		content: 'tbl: d${1:100}=${2:result} => "${3:outcome}"',
	},
	{
		trigger: 'generator',
		description: 'Complex generator',
		content: 'gen: ${1:system} => ${2:result}',
	},
];

/**
 * Get all snippets or filter by trigger
 */
export function getSnippets(filter?: string): Snippet[] {
	if (!filter) {
		return SNIPPETS;
	}
	return SNIPPETS.filter(s =>
		s.trigger.toLowerCase().includes(filter.toLowerCase()) ||
		s.description.toLowerCase().includes(filter.toLowerCase())
	);
}

/**
 * Get a specific snippet by trigger
 */
export function getSnippet(trigger: string): Snippet | undefined {
	return SNIPPETS.find(s => s.trigger === trigger);
}

/**
 * Type definitions for Solo RPG Notation system
 */

// ========== Location in document ==========
export interface Location {
	file: string;
	lineNumber: number;
	session?: string;
	scene?: string;
}

// ========== Core Notation Elements ==========

export type NotationElement =
	| Action
	| OracleQuestion
	| MechanicsRoll
	| OracleResult
	| Consequence
	| TextLine
	| TableLookup
	| Generator
	| MetaNote;

export interface Action {
	type: 'action';
	content: string;
	lineNumber: number;
}

export interface OracleQuestion {
	type: 'oracle_question';
	question: string;
	lineNumber: number;
}

export interface MechanicsRoll {
	type: 'mechanics_roll';
	roll: string;
	outcome: string;
	success: boolean | null;
	lineNumber: number;
}

export interface OracleResult {
	type: 'oracle_result';
	answer: string;
	roll?: string;
	lineNumber: number;
}

export interface Consequence {
	type: 'consequence';
	description: string;
	lineNumber: number;
}

export interface TextLine {
	type: 'text';
	content: string;
	lineNumber: number;
}

export interface TableLookup {
	type: 'table_lookup';
	roll: string;
	result: string;
	lineNumber: number;
}

export interface Generator {
	type: 'generator';
	system: string;
	rolls: string;
	result: string;
	lineNumber: number;
}

export interface MetaNote {
	type: 'meta_note';
	category: 'note' | 'reflection' | 'house_rule' | 'reminder' | 'question' | 'other';
	content: string;
	lineNumber: number;
}

// ========== Persistent Elements ==========

export interface Reference {
	id: string;
	name: string;
	type: 'npc' | 'location';
	firstMention: Location;
	mentions: Location[];
}

export interface NPC {
	id: string;
	name: string;
	tags: string[];
	firstMention: Location;
	mentions: Location[];
}

export interface LocationTag {
	id: string;
	name: string;
	tags: string[];
	firstMention: Location;
	mentions: Location[];
}

export interface Thread {
	id: string;
	name: string;
	state: 'Open' | 'Closed' | 'Abandoned' | string;
	firstMention: Location;
	mentions: Location[];
}

export interface PlayerCharacter {
	id: string;
	name: string;
	stats: Map<string, string>;
	locations: Location[];
}

// ========== Progress Tracking ==========

export interface Clock {
	id: string;
	name: string;
	current: number;
	total: number;
	locations: Location[];
}

export interface Track {
	id: string;
	name: string;
	current: number;
	total: number;
	locations: Location[];
}

export interface Timer {
	id: string;
	name: string;
	value: number;
	locations: Location[];
}

export interface Event {
	id: string;
	name: string;
	current: number;
	total: number;
	locations: Location[];
}

// ========== Scene Structure ==========

export interface Scene {
	id: string;
	number: string; // S1, S2a, T1-S3, etc.
	context?: string;
	startLine: number;
	endLine: number;
	elements: NotationElement[];
}

export interface Session {
	number: number;
	date?: string;
	duration?: string;
	scenes: Scene[];
	startLine: number;
	endLine: number;
	recap?: string;
	goals?: string;
	metadata: Map<string, string>;
}

export interface Campaign {
	file: string;
	title: string;
	frontMatter: Record<string, any>;
	sessions: Session[];
	npcs: Map<string, NPC>;
	locations: Map<string, LocationTag>;
	threads: Map<string, Thread>;
	clocks: Map<string, Clock>;
	tracks: Map<string, Track>;
	timers: Map<string, Timer>;
	events: Map<string, Event>;
	playerCharacters: Map<string, PlayerCharacter>;
	references: Map<string, Reference>;
}

// ========== Extracted Tags ==========

export interface ExtractedTags {
	npcs: NPC[];
	locations: LocationTag[];
	threads: Thread[];
	clocks: Clock[];
	tracks: Track[];
	timers: Timer[];
	events: Event[];
	playerCharacters: PlayerCharacter[];
}

// ========== Progress Elements Union ==========

export type ProgressElement = Clock | Track | Timer | Event;

// ========== Search Results ==========

export interface SearchResults {
	npcs: NPC[];
	locations: LocationTag[];
	threads: Thread[];
	progressElements: ProgressElement[];
	totalResults: number;
}

// ========== Utility Types ==========

export interface CampaignStats {
	totalSessions: number;
	totalScenes: number;
	activeThreads: number;
	closedThreads: number;
	totalNPCs: number;
	totalLocations: number;
	totalProgressElements: number;
	lastUpdated?: string;
}

// ========== Type Guards ==========

export function isAction(element: NotationElement): element is Action {
	return element.type === 'action';
}

export function isOracleQuestion(element: NotationElement): element is OracleQuestion {
	return element.type === 'oracle_question';
}

export function isMechanicsRoll(element: NotationElement): element is MechanicsRoll {
	return element.type === 'mechanics_roll';
}

export function isOracleResult(element: NotationElement): element is OracleResult {
	return element.type === 'oracle_result';
}

export function isConsequence(element: NotationElement): element is Consequence {
	return element.type === 'consequence';
}

export function isClock(element: ProgressElement): element is Clock {
	return 'current' in element && 'total' in element && element.id.startsWith('clock:');
}

export function isTrack(element: ProgressElement): element is Track {
	return 'current' in element && 'total' in element && element.id.startsWith('track:');
}

export function isTimer(element: ProgressElement): element is Timer {
	return 'value' in element && element.id.startsWith('timer:');
}

export function isEvent(element: ProgressElement): element is Event {
	return 'current' in element && 'total' in element && element.id.startsWith('event:');
}

export function isTableLookup(element: NotationElement): element is TableLookup {
	return element.type === 'table_lookup';
}

export function isGenerator(element: NotationElement): element is Generator {
	return element.type === 'generator';
}

export function isMetaNote(element: NotationElement): element is MetaNote {
	return element.type === 'meta_note';
}

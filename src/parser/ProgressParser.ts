import { Clock, Track, Timer, Event, Location } from '../types/notation';

/**
 * Parse and validate progress tracking elements
 */
export class ProgressParser {
	/**
	 * Validate clock values
	 */
	validateClock(clock: Clock): boolean {
		return (
			clock.current >= 0 &&
			clock.total > 0 &&
			clock.current <= clock.total
		);
	}

	/**
	 * Validate track values
	 */
	validateTrack(track: Track): boolean {
		return (
			track.current >= 0 &&
			track.total > 0 &&
			track.current <= track.total
		);
	}

	/**
	 * Validate timer value
	 */
	validateTimer(timer: Timer): boolean {
		return timer.value >= 0;
	}

	/**
	 * Validate event values
	 */
	validateEvent(event: Event): boolean {
		return (
			event.current >= 0 &&
			event.total > 0 &&
			event.current <= event.total
		);
	}

	/**
	 * Calculate progress percentage for clock/track/event
	 */
	calculateProgress(current: number, total: number): number {
		if (total === 0) return 0;
		return Math.round((current / total) * 100);
	}

	/**
	 * Check if a clock/track/event is complete
	 */
	isComplete(current: number, total: number): boolean {
		return current >= total;
	}

	/**
	 * Check if a clock/track/event is near completion (>= 75%)
	 */
	isNearComplete(current: number, total: number): boolean {
		return this.calculateProgress(current, total) >= 75;
	}

	/**
	 * Check if a timer is urgent (<= 2)
	 */
	isTimerUrgent(value: number): boolean {
		return value <= 2;
	}

	/**
	 * Merge multiple instances of the same progress element
	 * (to track changes across mentions)
	 */
	mergeClocks(clocks: Clock[]): Map<string, Clock> {
		const merged = new Map<string, Clock>();

		for (const clock of clocks) {
			const existing = merged.get(clock.id);
			if (existing) {
				// Update with latest values and add location
				existing.current = clock.current;
				existing.total = clock.total;
				existing.locations.push(...clock.locations);
			} else {
				merged.set(clock.id, { ...clock });
			}
		}

		return merged;
	}

	/**
	 * Merge tracks
	 */
	mergeTracks(tracks: Track[]): Map<string, Track> {
		const merged = new Map<string, Track>();

		for (const track of tracks) {
			const existing = merged.get(track.id);
			if (existing) {
				existing.current = track.current;
				existing.total = track.total;
				existing.locations.push(...track.locations);
			} else {
				merged.set(track.id, { ...track });
			}
		}

		return merged;
	}

	/**
	 * Merge timers
	 */
	mergeTimers(timers: Timer[]): Map<string, Timer> {
		const merged = new Map<string, Timer>();

		for (const timer of timers) {
			const existing = merged.get(timer.id);
			if (existing) {
				existing.value = timer.value;
				existing.locations.push(...timer.locations);
			} else {
				merged.set(timer.id, { ...timer });
			}
		}

		return merged;
	}

	/**
	 * Merge events
	 */
	mergeEvents(events: Event[]): Map<string, Event> {
		const merged = new Map<string, Event>();

		for (const event of events) {
			const existing = merged.get(event.id);
			if (existing) {
				existing.current = event.current;
				existing.total = event.total;
				existing.locations.push(...event.locations);
			} else {
				merged.set(event.id, { ...event });
			}
		}

		return merged;
	}

	/**
	 * Get progress history for an element (showing changes over time)
	 */
	getProgressHistory(element: Clock | Track | Event): { location: Location, value: number }[] {
		// For now, just return locations with current value
		// Could be enhanced to track actual value changes if we parse chronologically
		return element.locations.map(loc => ({
			location: loc,
			value: element.current,
		}));
	}

	/**
	 * Get timer history
	 */
	getTimerHistory(timer: Timer): { location: Location, value: number }[] {
		return timer.locations.map(loc => ({
			location: loc,
			value: timer.value,
		}));
	}
}

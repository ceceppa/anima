## A retained snapshot of exactly how one group execution was resolved and
## scheduled.
##
## Playing an [AnimaGroupMotion] resolves its targets and derives a schedule
## once, right at the start. This record is that snapshot, kept for the rest
## of the run. Reversing, tracing, or inspecting the group afterward reads
## this record instead of resolving and scheduling the group again, so a
## reverse always replays exactly what actually happened — including which
## targets were actually found — rather than a fresh, and potentially
## different, resolution.
class_name AnimaExecutionRecord
extends RefCounted

## One resolved target's place in an execution.
class Entry:
	## The resolved target this entry animates.
	var target: Node
	## This target's position in the resolved list, before ordering. Used to
	## keep a stable order when two entries share a rank.
	var original_index: int = 0
	## This target's wave. Entries that share a rank started together.
	var rank: int = 0
	## Seconds after the group began that this target started. Only
	## meaningful for a staggered group.
	var start_offset: float = 0.0

## Every resolved target for this execution, already in start order —
## [code]entries[0][/code] is the target that started first.
var entries: Array[Entry] = []
## The random seed this execution was resolved with. Only meaningful when
## the group's order is [constant AnimaGroupOrder.Kind.RANDOM]; kept here
## regardless so a caller can always trace or replay an execution without
## reaching back into the group's resource.
var seed: int = 0

## Builds a record from a freshly-derived [member AnimaGroupScheduler.Schedule].
static func from_schedule(schedule: AnimaGroupScheduler.Schedule) -> AnimaExecutionRecord:
	var record := AnimaExecutionRecord.new()
	record.seed = schedule.seed
	for scheduled_entry in schedule.entries:
		var entry := Entry.new()
		entry.target = scheduled_entry.target
		entry.original_index = scheduled_entry.original_index
		entry.rank = scheduled_entry.rank
		entry.start_offset = scheduled_entry.start_offset
		record.entries.append(entry)
	return record

## Returns a new record with every entry's rank and start offset mirrored
## around this one, so the target that started last now starts first —
## without reshuffling a [constant AnimaGroupOrder.Kind.RANDOM] order or
## resolving targets again.
func reversed() -> AnimaExecutionRecord:
	var max_rank := 0
	var max_offset := 0.0
	for entry in entries:
		max_rank = maxi(max_rank, entry.rank)
		max_offset = maxf(max_offset, entry.start_offset)

	var record := AnimaExecutionRecord.new()
	record.seed = seed
	for entry in entries:
		var reversed_entry := Entry.new()
		reversed_entry.target = entry.target
		reversed_entry.original_index = entry.original_index
		reversed_entry.rank = max_rank - entry.rank
		reversed_entry.start_offset = max_offset - entry.start_offset
		record.entries.append(reversed_entry)

	record.entries.sort_custom(func(a: Entry, b: Entry) -> bool:
		return a.rank < b.rank if a.rank != b.rank else a.original_index < b.original_index
	)
	return record

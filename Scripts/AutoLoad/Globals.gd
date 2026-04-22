extends Node

static var SHARD_OFFSET = 0

signal SHARD_OFFSET_CHANGED

func set_shard_offset(value: int):
	SHARD_OFFSET = value
	SHARD_OFFSET_CHANGED.emit()

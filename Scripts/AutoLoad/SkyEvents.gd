extends RefCounted
class_name SkyEvents

const DATA = {
	"geyser":  { "period": 120, "offset":  5, "name": "Geyser", "prefix": "Geyser starts in "},
	"grandma":  { "period": 120, "offset":  35, "name": "Grandma", "prefix": "Grandma visits in " },
	"turtle":  { "period": 120, "offset":  50, "name": "Turtle", "prefix": "Turtle arrives in " },
}

static func seconds_until(key: String, utc_second: int) -> int:
	# same math as minutes, just scale by 60
	var cfg = SkyEvents.DATA.get(key)
	if not cfg: return 9999
	var period = cfg.period * 60
	var offset = cfg.offset * 60
	var next = offset - utc_second
	while next < 0: next += period
	return next
	
static func closest_event(now_sec: int) -> Dictionary:
	var best := { "key":"", "sec":999999 }
	for key in DATA:
		var s := seconds_until(key, now_sec)
		if s < best.sec:
			best = { "key":key, "sec":s }
	return best

static func minutes_until(key: String, utc_minute: int) -> int:
	var cfg = DATA.get(key)
	if not cfg: return 9999
	var next = cfg.offset - utc_minute
	while next < 0: next += cfg.period
	return next

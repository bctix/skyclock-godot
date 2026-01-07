extends Node
class_name SkyEvents

# ---------- wax stuff ----------

const DATA = {
	"geyser":  { "period": 120, "offset":  5, "name": "Geyser", "prefix": "Geyser erupts in "},
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

# ---------- shard stuff ----------

const LAND_OFFSET   := 8 * 60 + 40      # 8m40s
const END_OFFSET    := 4 * 3600
const BLACK_INTERVAL:= 8 * 3600
const RED_INTERVAL  := 6 * 3600
const SHARD_TZ      := "America/Los_Angeles"

const REALMS := ["prairie", "forest", "valley", "wasteland", "vault"]

const SHARDS_INFO := [
	{ no_wk=[6,7], interval=BLACK_INTERVAL, offset=1*3600+50*60, maps=["prairie.butterfly","forest.brook","valley.rink","wasteland.temple","vault.starlight"] },
	{ no_wk=[7,1], interval=BLACK_INTERVAL, offset=2*3600+10*60, maps=["prairie.village","forest.boneyard","valley.rink","wasteland.battlefield","vault.starlight"] },
	{ no_wk=[1,2], interval=RED_INTERVAL,   offset=7*3600+40*60, maps=["prairie.cave","forest.end","valley.dreams","wasteland.graveyard","vault.jelly"], def_ac=2 },
	{ no_wk=[2,3], interval=RED_INTERVAL,   offset=2*3600+20*60, maps=["prairie.bird","forest.tree","valley.dreams","wasteland.crab","vault.jelly"], def_ac=2.5 },
	{ no_wk=[3,4], interval=RED_INTERVAL,   offset=3*3600+30*60, maps=["prairie.island","forest.sunny","valley.hermit","wasteland.ark","vault.jelly"], def_ac=3.5 },
]

# ---------- shard meta + occurrences (one-stop) ----------
static func shard_for(iso_date: String) -> Dictionary:
	var dt = Time.get_datetime_dict_from_datetime_string(iso_date + "T00:00:00", true)
	var dow = int(dt.get("weekday", 1))   # 1=Mon … 7=Sun
	var dom = int(dt.get("day", 1))

	var is_red     = dom % 2 == 1
	var realm_idx  = (dom - 1) % 5
	@warning_ignore("integer_division")
	var table_idx  = ((dom - 1) / 2) % 3 + 2 if (dom % 2 == 1) else (dom / 2) % 2
	table_idx = int(table_idx)
	var info  = SHARDS_INFO[table_idx]
	var has   = not (info.no_wk.has(dow))
	var map   = info.maps[realm_idx]
	var reward= info.def_ac if is_red else null

	# build today’s three windows (seconds after midnight)
	var base_offset = info.offset
	var interval    = info.interval
	var occs := []
	for i in 3:
		var start = base_offset + interval * i
		occs.append({
			start = start,
			land  = start + LAND_OFFSET,
			end   = start + END_OFFSET
		})

	return {
		dat = iso_date,
		is_red = is_red,
		has_shard = has,
		map = map,
		realm = REALMS[realm_idx],
		reward_ac = reward,
		realm_idx = realm_idx,
		occurrences = occs
	}

extends RefCounted
## Automatic doorway travel uses explicit screen/world sides, never guessed art.
const VECTORS := {"north":Vector2.UP,"east":Vector2.RIGHT,"south":Vector2.DOWN,"west":Vector2.LEFT}
const OPPOSITE := {"north":"south","south":"north","east":"west","west":"east"}

static func should_enter(position: Vector2, movement: Vector2, portal: Dictionary, cooldown: float) -> bool:
	if cooldown > 0 or not VECTORS.has(portal.get("side","")) or movement.length_squared() < 0.01:
		return false
	var outward: Vector2 = VECTORS[portal.side]
	if movement.normalized().dot(outward) < 0.6: return false
	var at := Vector2(portal.at[0],portal.at[1])
	var half_size := Vector2(12,10) if outward.x == 0 else Vector2(10,12)
	return Rect2(at-half_size,half_size*2).has_point(position)

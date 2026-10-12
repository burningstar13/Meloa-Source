
class_name PerfPoints
extends RefCounted






































const WEIGHT: = 0.95









const SCORE_EXP: = 2.0

static func pp(level: float, score: int) -> float:
	if level <= 0.0 or score <= 0:
		return 0.0
	var base: = 2.0 * pow(level, 2.1)
	return snappedf(base * pow(float(score) / 1000000.0, SCORE_EXP), 0.1)




static func total(best_pps: Array) -> float:
	var vals: Array = []
	for v in best_pps:
		if float(v) > 0.0:
			vals.append(float(v))
	vals.sort()
	vals.reverse()
	var sum: = 0.0
	var w: = 1.0
	for v in vals:
		sum += float(v) * w
		w *= WEIGHT
		if w < 0.001:
			break
	return snappedf(sum, 0.1)



static func total_from_records(records: Dictionary) -> float:
	var pps: Array = []
	for key in records:
		pps.append(float((records[key] as Dictionary).get("pp", 0.0)))
	return total(pps)

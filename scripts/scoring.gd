class_name ScoreRules
extends RefCounted



























const MAX: = 1000000

const COMBO_CAP: = 50




const GRADES: = [["SS", 1000000], ["S", 860000], ["A", 745000], 
	["B", 560000], ["C", 380000]]



const MEH_WEIGHT: = 0.25



const GRADE_ACC: = [["S", 95.0], ["A", 90.0], ["B", 80.0], ["C", 70.0]]



static func combo_weight(c: int) -> float:
	return 1.0 + minf(float(c), float(COMBO_CAP)) / float(COMBO_CAP)



static func combo_portion_max(n: int) -> float:
	if n <= 0:
		return 1.0
	if n <= COMBO_CAP:
		return float(n) + float(n) * float(n - 1) / (2.0 * COMBO_CAP)
	var cap: = float(COMBO_CAP) + float(COMBO_CAP - 1) / 2.0
	return cap + 2.0 * float(n - COMBO_CAP)



static func standardized(acc: float, combo_progress: float, acc_progress: float, 
		mods_mult: = 1.0) -> int:
	var a: = clampf(acc, 0.0, 1.0)
	var v: = float(MAX) * (0.5 * a * clampf(combo_progress, 0.0, 1.0)
		+ 0.5 * pow(a, 5.0) * clampf(acc_progress, 0.0, 1.0))
	return int(round(v * maxf(mods_mult, 0.0)))






static func combo_progress_bound(max_combo: int, judged: int) -> float:
	if judged <= 0:
		return 0.0
	var m: = clampi(max_combo, 0, judged)
	var best: = combo_portion_max(m) + float(judged - m) * combo_weight(maxi(m - 1, 0))
	return clampf(best / combo_portion_max(judged), 0.0, 1.0)





static func reconstruct(acc: float, max_combo: int, judged: int, mods_mult: = 1.0) -> int:
	if judged <= 0:
		return 0
	var m: = clampi(max_combo, 0, judged)
	var est: = (combo_portion_max(m) + float(judged - m)) * clampf(acc, 0.0, 1.0)\
	/ combo_portion_max(judged)
	return standardized(acc, est, 1.0, mods_mult)







static func grade(acc_pct: float, misses: = -1) -> String:
	if acc_pct >= 100.0 and misses <= 0:
		return "SS"
	for g in GRADE_ACC:
		if acc_pct >= float(g[1]):
			if String(g[0]) == "S" and misses > 0:
				continue
			return String(g[0])
	return "D"




static func grade_from_score(score: int) -> String:
	for g in GRADES:
		if score >= int(g[1]):
			return String(g[0])
	return "D"

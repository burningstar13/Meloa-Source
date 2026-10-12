class_name LariBody
extends MascotBody




const P_NECK: = Vector2(2420.0, 1000.0)


func _cfg() -> Dictionary:
	return {
		"name": "Lari", 
		"dir": "res://assets/mascots/LARI/game/body/", 
		"canvas_h": 6000.0, 

		"feet": Vector2(2300.0, 5880.0), 

		"head_top_frac": (5880.0 - 40.0) / 6000.0, 

		"top_aspect": 0.45, 
		"entrance": "rise", 
		"amp": 1.0, 
		"arm_max": 0.16, 

		"p_hips": Vector2(2300.0, 2450.0), 
		"p_neck": P_NECK, 
		"p_arm_g": Vector2(2150.0, 1400.0), 
		"p_arm_d": Vector2(2800.0, 1350.0), 
		"eye": [Vector2(2226.0, 690.0), Vector2(2527.0, 672.0)], 
		"brow": [Vector2(2184.0, 524.0), Vector2(2484.0, 496.0)], 
		"mouth": Vector2(2343.0, 915.0), 
		"pupil_max": Vector2(42.0, 26.0), 

		"springs": [
			{"slug": "g_tail_bas", "pivot": Vector2(2100.0, 650.0), "side": -1.0, "where": "behind"}, 
			{"slug": "d_tail_bas", "pivot": Vector2(2750.0, 600.0), "side": 1.0, "where": "behind"}, 
			{"slug": "g_tail", "pivot": Vector2(2200.0, 300.0), "side": -1.0, "where": "behind"}, 
			{"slug": "d_tail", "pivot": Vector2(2650.0, 300.0), "side": 1.0, "where": "behind"}, 
		], 

		"l_legs": ["g_leg", "g_chaussure", "g_chaussette", "d_leg", "d_chaussure", "d_chaussette"], 
		"l_torso": ["capuche_back", "neck", "skirt", "pull", "g_coat", "d_coat", 
			"g_capuche_front", "d_capuche_front_1", "d_capuche_front_2"], 
		"arm_g_behind": true, 
		"l_arm_g": ["g_hand", "g_manche"], 
		"l_arm_d": ["d_hand", "d_manche"], 
		"l_head_back": ["head_hair", "g_side_meche", "head", "ear", "nose"], 
		"l_eyes": [["g_pupille", "g_cil_bas", "g_cil_haut"], ["d_pupille", "d_cil_bas", "d_cil_haut"]], 
		"l_brows": ["g_sourcil", "d_sourcil"], 
		"l_head_front": ["frange", "d_side_meche", "hair_star"], 

		"face_slots": {
			"eye_g": ["g_pupille", "g_cil_bas", "g_cil_haut"], 
			"eye_d": ["d_pupille", "d_cil_bas", "d_cil_haut"], 
			"sourcil_g": ["g_sourcil"], "sourcil_d": ["d_sourcil"], 
			"mouth": ["mouth"], "nose": ["nose"], 
		}, 
		"face_files": {"g_eyes": "eye_g", "d_eyes": "eye_d", "g_eye": "eye_g", "d_eye": "eye_d", 
			"g_sourcil": "sourcil_g", "d_sourcil": "sourcil_d", "mouth": "mouth", "nose": "nose", 
			"goutte": "deco"}, 
		"face_style": {"hihi": "laugh", "o_o": "panic", "uuhghg": "nervous"}, 
		"face_hide": {"o_o": ["nose"]}, 

		"grade_face": {"SS": [&"hihi", 2.2], "S": [&"hihi", 2.2], 
			"A": [&"uuhghg", 2.4], "B": [&"uuhghg", 2.4], 
			"C": [&"o_o", 2.0], "D": [&"o_o", 2.0]}, 

		"wink": [&"hihi", ["eye_g"]], 
	}

class_name AmeBody
extends MascotBody












const P_NECK: = Vector2(2135.0, 1300.0)


func _cfg() -> Dictionary:
	return {
		"name": "Ame", 
		"dir": "res://assets/mascots/AME/game/body/", 
		"canvas_h": 6000.0, 
		"feet": Vector2(1950.0, 5900.0), 
		"head_top_frac": (5900.0 - 238.0) / 6000.0, 
		"top_aspect": 0.42, 
		"entrance": "rise", 
		"amp": 0.85, 
		"arm_max": 0.0, 
		"p_hips": Vector2(2070.0, 2600.0), 
		"p_neck": P_NECK, 
		"p_arm_g": Vector2(1600.0, 1500.0), 
		"p_arm_d": Vector2(2600.0, 1450.0), 
		"eye": [Vector2(1917.0, 934.0), Vector2(2240.0, 938.0)], 
		"brow": [Vector2(2011.0, 878.0), Vector2(2231.0, 851.0)], 
		"mouth": Vector2(2115.0, 1180.0), 
		"pupil_max": Vector2(30.0, 18.0), 
		"springs": [], 

		"l_torso": ["neck", "pull", "d_hand", "g_manche_haut", "d_manche_haut", "col", 
			"g_hand", "g_manche_bas", "d_manche_bas"], 
		"arm_g_behind": true, 
		"l_arm_g": [], 
		"l_arm_d": [], 
		"legs_front": true, 
		"l_legs": ["d_pants", "g_pants", "d_shoe", "g_shoe"], 
		"l_torso_over": ["g_veste", "d_veste"], 
		"l_head_back": ["head_hair", "g_ear", "d_ear", "head", "frange", "d_side_meche", 
			"g_side_meche", "nose"], 
		"l_eyes": [["g_pupille", "g_cil_bas", "g_cil_haut"], ["d_pupille", "d_cil_bas", "d_cil_haut"]], 
		"l_brows": ["g_sourcil", "d_sourcil"], 
		"l_head_front": ["crosses"], 

		"face_slots": {
			"eye_g": ["g_pupille", "g_cil_bas", "g_cil_haut"], 
			"eye_d": ["d_pupille", "d_cil_bas", "d_cil_haut"], 
			"sourcil_g": ["g_sourcil"], "sourcil_d": ["d_sourcil"], 
			"mouth": ["mouth"], "nose": ["nose"], 
		}, 
		"face_files": {
			"g_pupille": "eye_g", "g_cil_bas": "eye_g", "g_cil_haut": "eye_g", 
			"d_pupille": "eye_d", "d_cil_bas": "eye_d", "d_cil_haut": "eye_d", 
			"g_sourcil": "sourcil_g", "d_sourcil": "sourcil_d", "mouth": "mouth", "nose": "nose", 
		}, 
		"face_style": {"haha": "mock", "heh": "smug", "huh": "startled"}, 
		"face_hide": {}, 

		"grade_face": {"SS": [&"huh", 2.4], "S": [&"huh", 2.4], 
			"A": [&"heh", 2.4], "B": [&"heh", 2.4], 
			"C": [&"haha", 2.4], "D": [&"haha", 2.4]}, 
		"wink": [], 
	}

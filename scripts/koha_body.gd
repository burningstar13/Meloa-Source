class_name KohaBody
extends MascotBody





const P_NECK: = Vector2(2020.0, 1000.0)


func _cfg() -> Dictionary:
	return {
		"name": "Koha", 
		"dir": "res://assets/mascots/KOHA/game/body/", 
		"canvas_h": 6000.0, 
		"feet": Vector2(2000.0, 5880.0), 
		"head_top_frac": (5880.0 - 184.0) / 6000.0, 
		"top_aspect": 0.3, 
		"entrance": "present", 
		"amp": 0.55, 
		"arm_max": 0.05, 
		"p_hips": Vector2(2100.0, 2250.0), 
		"p_neck": P_NECK, 
		"p_arm_g": Vector2(2000.0, 1700.0), 
		"p_arm_d": Vector2(2500.0, 1250.0), 
		"eye": [Vector2(1868.0, 710.0), Vector2(2162.0, 710.0)], 
		"brow": [Vector2(1875.0, 608.0), Vector2(2185.0, 614.0)], 
		"mouth": Vector2(2046.0, 929.0), 
		"pupil_max": Vector2(26.0, 14.0), 


		"springs": [
			{"slug": "g_side_meche", "pivot": Vector2(1758.0, 380.0), "side": -1.0, "where": "front"}, 
			{"slug": "d_side_meche", "pivot": Vector2(2273.0, 420.0), "side": 1.0, "where": "front"}, 
		], 
		"spring_sway": 0.0, "spring_drag": 0.0, "spring_kick": 0.3, "spring_damp": 9.0, 
		"l_legs": ["d_shoe", "g_shoe", "d_pants", "g_pants"], 
		"l_torso": ["neck", "chemise"], 



		"arm_g_behind": false, 
		"l_arm_d": [], 
		"l_arm_g": ["d_manche", "d_hand", "d_manche_front", "g_manche", "g_hand", "g_manche_front"], 
		"l_head_back": ["hair_head", "g_ear", "d_ear", "head", "face_lines", "nose"], 
		"l_eyes": [["g_pupille", "g_cil_bas", "g_cil_haut"], 
			["d_pupille", "d_cil_bas", "d_cil_haut"]], 
		"l_brows": ["g_sourcil", "d_sourcil"], 
		"l_head_front": ["frange"], 
		"l_head_over": ["losange"], 

		"l_eyes_over": [["g_paupiere"], ["d_paupiere"]], 
		"brows_over": true, 
		"face_slots": {
			"eye_g": ["g_pupille", "g_cil_bas", "g_cil_haut", "g_paupiere"], 
			"eye_d": ["d_pupille", "d_cil_bas", "d_cil_haut", "d_paupiere"], 
			"sourcil_g": ["g_sourcil"], "sourcil_d": ["d_sourcil"], 
			"mouth": ["mouth"], "nose": ["nose"], "face_lines": ["face_lines"], 
		}, 
		"face_files": {
			"g_pupille": "eye_g", "g_cil_bas": "eye_g", "g_cil_haut": "eye_g", "g_paupiere": "eye_g", 
			"d_pupille": "eye_d", "d_cil_bas": "eye_d", "d_cil_haut": "eye_d", "d_paupiere": "eye_d", 
			"g_sourcil": "sourcil_g", "d_sourcil": "sourcil_d", "mouth": "mouth", "nose": "nose", 
			"face_line": "face_lines", "ew_line": "deco", "light": "deco", 
		}, 
		"face_style": {"ew": "disgust", "froissee": "sulk", "proud": "proud"}, 
		"face_hide": {}, 

		"grade_face": {"SS": [&"proud", 2.6], "S": [&"proud", 2.6], 
			"A": [&"froissee", 2.4], "B": [&"froissee", 2.4], 
			"C": [&"ew", 2.2], "D": [&"ew", 2.2]}, 

		"wink": [], 
	}

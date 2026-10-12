class_name MascotData
extends Resource












@export var character_id: StringName = &"mascot"
@export var display_name: = "Mascotte"

@export_range(0, 2) var lane: = 0

@export var tint: = Color(0.3, 1.0, 0.85)

@export_group("Calques (même canvas ; G = gauche vu joueur)")
@export var head_tex: Texture2D
@export var pupille_g_tex: Texture2D
@export var pupille_d_tex: Texture2D
@export var cil_g_tex: Texture2D
@export var cil_d_tex: Texture2D
@export var cil_bas_g_tex: Texture2D
@export var cil_bas_d_tex: Texture2D

@export var paupiere_g_tex: Texture2D
@export var paupiere_d_tex: Texture2D

@export var sourcil_g_tex: Texture2D
@export var sourcil_d_tex: Texture2D
@export var mouth_tex: Texture2D
@export var nose_tex: Texture2D


@export var accessory_tex: Texture2D

@export_group("Géométrie (px du canvas des calques)")

@export var canvas_anchor: = Vector2(512.0, 510.0)

@export var eye_center_g: = Vector2(404.0, 564.0)
@export var eye_center_d: = Vector2(592.0, 564.0)


@export var pupil_max: = Vector2(18.0, 11.0)

@export var sourcil_center_g: = Vector2.ZERO
@export var sourcil_center_d: = Vector2.ZERO

@export var art_scale: = 0.13





@export var canvas_px: = 1024.0

@export_group("Placeholder (personnage sans assets)")
@export var head_radius: = 36.0
@export var eye_offset: = Vector2(14.0, -1.0)
@export var eye_size: = Vector2(9.0, 11.0)
@export var iris_radius: = 5.5
@export var brow_offset: = Vector2(14.0, -15.0)
@export var mouth_offset: = Vector2(0.0, 13.0)
@export var accessory_offset: = Vector2(-20.0, -20.0)

@export_group("Expressions")


@export var expressions: Array[MascotExpression] = []



func has_art() -> bool:
	return head_tex != null

class_name MascotExpression
extends Resource







@export var id: StringName = &"neutral"

@export_group("Textures (vide = couche de base)")
@export var pupille_g_tex: Texture2D
@export var pupille_d_tex: Texture2D
@export var cil_g_tex: Texture2D
@export var cil_d_tex: Texture2D
@export var cil_bas_g_tex: Texture2D
@export var cil_bas_d_tex: Texture2D

@export var paupiere_g_tex: Texture2D
@export var paupiere_d_tex: Texture2D


@export var eyes_g_tex: Texture2D
@export var eyes_d_tex: Texture2D



@export var close_eye_g: = false
@export var close_eye_d: = false

@export var sourcil_g_tex: Texture2D
@export var sourcil_d_tex: Texture2D
@export var mouth_tex: Texture2D
@export var nose_tex: Texture2D

@export var accessory_tex: Texture2D


@export var hide_nose: = false

@export var blush_tex: Texture2D


@export var decos: Array[Texture2D] = []



@export var overlay_tex: Texture2D

@export_group("Yeux et regard")



@export_range(0.0, 1.0) var eye_open: = 1.0

@export var pupil_track: = true

@export var pupil_bias: = Vector2.ZERO

@export_group("Sourcils (placeholder / futurs assets)")

@export var brow_offset: = Vector2.ZERO

@export var brow_angle: = 0.0

@export_group("Bouche (placeholder tant que mouth_tex est vide)")

@export_range(-1.0, 1.0) var mouth_curve: = 0.0

@export_range(0.0, 1.0) var mouth_open: = 0.0

@export_group("Tête")

@export var head_tilt: = 0.0

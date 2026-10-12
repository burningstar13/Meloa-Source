extends Node2D







const NOTE_SCENE: = preload("res://scenes/Note.tscn")
const CLICK_TARGET_SCENE: = preload("res://scenes/ClickTarget.tscn")
const FxFonts: = preload("res://scripts/fx_fonts.gd")
const FxImages: = preload("res://scripts/fx_images.gd")




const MASCOT_SCENE: = preload("res://scenes/Mascot.tscn")
const LARI_DATA: = preload("res://assets/mascots/LARI/game/lari.tres")
const AME_DATA: = preload("res://assets/mascots/AME/game/ame.tres")
const KOHA_DATA: = preload("res://assets/mascots/KOHA/game/koha.tres")



const BEAM_TICK: = 0.25
const BEAM_GRACE: = 0.16




const SCORE_BEAM_TICK: = 50


const SCORE_PERFECT: = 300
const SCORE_GOOD: = 100
const SCORE_DODGE: = 100


const COL_BG: = Color(0.1, 0.12, 0.16, 0.92)
const COL_BG_HOVER: = Color(0.17, 0.2, 0.26, 0.95)
const COL_ACCENT: = Color(0.45, 1.0, 0.75)
const COL_PERFECT: = Color(0.45, 0.82, 1.0)
const COL_GOLD: = Color(1.0, 0.82, 0.3)
const COL_RED: = Color(1.0, 0.35, 0.4)








const LANE_COLS_BASE: = [Color(0.3, 1.0, 0.85), Color(0.72, 0.45, 1.0), Color(1.0, 0.78, 0.25)]
var LANE_COLS: = [Color(0.3, 1.0, 0.85), Color(0.72, 0.45, 1.0), Color(1.0, 0.78, 0.25)]
const LANE_PERSPECTIVE: = 0.86


const LANE_COUNT: = 3

@onready var tuning: Tuning = $Tuning
@onready var conductor: Conductor = $Conductor
@onready var world: Playfield = $World
@onready var notes_root: Node2D = $World / Notes
@onready var fx_root: Node2D = $World / FX
@onready var player: Player = $World / Player
@onready var sfx: Sfx = $SFX
@onready var ui_layer: CanvasLayer = $UI


enum Screen{HOME, SELECT, PLAYING, EDITOR}
var screen: int = Screen.HOME
var editor: Node2D = null


var playtest_from: = -1.0

var chart_notes: Array = []



var chart_error: = ""


var chart_warning: = ""
var _chart_offset: = 0.0





var chart_velocity: = 1.0



var kiai_sections: Array = []
var chart_bpm: = 120.0



var chart_end: = 0.0



var chart_practice: = -1.0


var slider_bodies_root: Node2D
var _click_pool: Array = []
var _slider_pool: Array = []
const POOL_MAX: = 48


var skin_back: Node2D
var skin_front: Node2D
var _anim_pool: Array = []
var _anims_alive: = 0
var judge_image: TextureRect



var auto_start: = 0.0
var auto_end: = 0.0









const LOCKED_TRACKS: = ["KAILI", "AUGMENTED TENACITY", 
	"GALAXY COLLAPSE"]




func _is_locked(track: String) -> bool:




	if track in PLAYABLE_FEATURED:
		return false
	return track in LOCKED_TRACKS or track in Tuning.FEATURED






const PLAYABLE_FEATURED: = ["RAVENATIC", "INTO THE FLOW"]






func track_title(track: String) -> String:
	return MapLibrary.title_of(track)


func track_artist(track: String) -> String:
	if MapLibrary.is_user_map(track):
		return MapLibrary.artist_of(track)
	return String(TRACK_INFO.get(track, ""))


func track_desc(track: String) -> String:
	if MapLibrary.is_user_map(track):
		var st: = MapLibrary.status_of(track)
		if st == MapLibrary.STATUS_DOWNLOADED:
			var by: = String(MapLibrary.meta_of(track).get("creator", ""))
			return "Downloaded map%s." % ("  ·  mapped by " + by if by != "" else "")
		return "Your map — local draft." if st == MapLibrary.STATUS_DRAFT\
		else "Your map — published online."
	return String(TRACK_DESC.get(track, ""))
var next_spawn: = 0
var live_notes: Array = []

var score: = 0
var combo: = 0
var max_combo: = 0







const FIRE_COMBO: = 40
var fever: = 0.0
var on_fire: = false
var fire_ignite_ms: = 0
var fire_ignite_lane: = 1
var hp: = 100.0
var judged_count: = 0
var accuracy_sum: = 0.0



var _combo_portion: = 0.0
var _combo_portion_max: = 1.0
var _expected_judgements: = 0
var game_over: = false
var track_done: = false

var invincible: = false


var auto_mode: = false
var auto_cursor: = Vector2.ZERO



var run_assisted: = false


var mods_mult: = 1.0


var _mania_lane: = 1

var _end_fade_tw: Tween = null
var _r_hold: = 0.0
var _r_hint_at: = 0.0
var _pause_aim: = Vector2.ZERO
var _resuming: = false
var _shake_amp: = 0.0


var game_paused: = false
var pause_root: Control

var gameover_root: Control
var _go_title: Label
var _go_sub: Label
var _go_stats: Label
var _go_box: VBoxContainer
var _go_rule: Panel
var _go_dim: Panel
var _go_tw: Tween






var score_label: GlowLabel
var combo_label: Label
var acc_value: GlowLabel
var time_value: GlowLabel
var time_bar_fill: Panel
var time_bar_style: StyleBoxFlat
const TIME_BAR_W: = 200.0
var _hud_score_box: Control
var _hud_hp_box: Control
var _hud_acc_box: Control
var _hud_time_box: Control
var _display_score: = 0.0
var _combo_tw: Tween
var hp_row: HBoxContainer
var hp_bar_fill: Panel
var hp_bar_style: StyleBoxFlat
var hp_track_style: StyleBoxFlat
const HP_BAR_W: = 240.0
var end_panel: Control
var results_screen: ResultsScreen
var _results_token: = 0
var run_samples: Array = []
var invincible_button: Button
var hud_mods_label: Label
var auto_button: Button


var account_panel: Control
var account_status: Label
var acc_email: LineEdit
var acc_user: LineEdit
var acc_pass: LineEdit
var account_item: Button
var account_name_label: Label
var account_dot: Control
var player_badge: PlayerBadge
var lb_overlay: Control
var lb_rows: VBoxContainer



var lb_mode: = "MAP"



var gate_root: Control
var gate_title: Label
var gate_msg: Label
var gate_input: LineEdit
var gate_submit: Button
var gate_retry: Button

var gate_user: LineEdit
var gate_email: LineEdit
var gate_pass: LineEdit
var gate_login_b: Button
var gate_register_b: Button

var gate_update_b: Button
var gate_update_url: = ""


const HEARTBEAT_SEC: = 180.0
const HEARTBEAT_MAX_FAILS: = 2
var _hb_timer: Timer
var _hb_fails: = 0
var _pending_gate: = {}



var hud_root: Control
var menu_root: Control
var home_screen: Control
var select_screen: Control
var play_button: Button

var background: Background


var beat_bus: BeatBus
var orbit_menu: OrbitMenu
var now_bar: NowPlayingBar
var menu_intro: MenuIntro
var home_title: Control
var home_secondary: Control
var mascot_button: Button


var mod_presence: Button
var _mod_presence_busy: = false

var map_select: MapSelect














const MENU_BG_DIR: = "res://assets/menu/"
var menu_bg_tex: Texture2D
var _menu_hover_idx: = -1
var _home_exit_tw: Tween
var _home_fade_tw: Tween
var spectrum: AudioEffectSpectrumAnalyzerInstance
var glow_tex: Texture2D
var font_logo: Font
var font_display: Font
var font_bold: Font
var font_body: Font
var font_judge: Font
var _chart_meta: = {}
var _chart_meta_diff: = {}













const MapImages: = preload("res://scripts/map_images.gd")

const PerfTrace: = preload("res://scripts/perf_trace.gd")

const PerfFlags: = preload("res://scripts/perf_flags.gd")

const Spectrum: = preload("res://scripts/spectrum.gd")

const PerfSelfTest: = preload("res://scripts/perf_selftest.gd")
var track_covers: MapImages = MapImages.new()
var track_bgs: MapImages = MapImages.new("bg")
var track_videos: = {}
var bg_video: VideoStreamPlayer = null
var _bg_video_path: = ""
var _bg_video_last_t: = 0.0


const VIDEO_BG_OFFSET: = {}


var yellow_spans: Array = []
var lane_clear: = 0.0

























var lane_fx: = {}
var fx_texts: Array = []
var fx_themes: Array = []
var fx_breaks: Array = []
var break_windows: Array = []
var _break_node: Node2D = null



var _in_break: = false
var fx_spread: = 1.0
var fx_dx: = [0.0, 0.0, 0.0]
var fx_alpha: = [1.0, 1.0, 1.0]
var fx_pos: = [NAN, NAN, NAN]
var fx_sway_amp: = [0.0, 0.0, 0.0]
var fx_sway_freq: = [0.5, 0.5, 0.5]
var fx_width: = [1.0, 1.0, 1.0]


var fx_gone: = [0.0, 0.0, 0.0]
var fx_pulses: Array = []
var fx_shake_off: = Vector2.ZERO
var fx_glitch: = 0.0


var _fx_labels: Array = []
var fx_images: Array = []
var _fx_image_nodes: Array = []
var _fx_image_cache: = {}
var _fx_deco: FxTextDeco = null
var _fx_font: Font = null
var _glitch_layer: CanvasLayer = null
var _glitch_rect: ColorRect = null



var fx_film: = 0.0
var fx_film_grain: = 1.0
var fx_film_sepia: = 0.0
var _film_layer: CanvasLayer = null
var _film_rect: ColorRect = null



var fx_rot: = 0.0

var fx_particles: = {}
var _fx_particles_node: Node2D = null


var judge_label: Label
var timing_label: Label
var _judge_tw: Tween
var score_delta: Label
var _delta_tw: Tween
var perfect_chain: = 0
var hit_deltas: Array = []





var _bursts_alive: = 0
var _last_shock_ms: = 0
var _last_float_ms: = 0
var _pops_alive: = 0

var _fps_label: Label
var _fps_accum: = 0.0



var _zoom_amp: = 0.0
var _zoom_center: = Vector2.ZERO
var _glitch_alive: = 0


var line_flash: = 0.0
var line_flash_col: = Color.WHITE




const LP_OPEN: = 20500.0
var music_lp: AudioEffectLowPassFilter
var _lp_tw: Tween
var _transitioning: = false
var _pre_roll: = false
var _hover_last: Control = null




var crosshair_node: Node2D
var select_center: Control
var select_cover: TextureRect


var _global_rank: = {}



var _rank_before_map: = -1
var _rank_before_global: = -1
var _rank_snap_token: = 0
var map_records: = {}
var stats_panel: PanelContainer
var stats_body: Label
var credits_panel: PanelContainer



const GRADIENT_TEXT_SHADER: = "\nshader_type canvas_item;\nuniform vec4 col_a : source_color = vec4(1.0);\nuniform vec4 col_b : source_color = vec4(1.0);\nuniform vec4 col_c : source_color = vec4(1.0);\nuniform float width = 400.0;\nuniform float boost = 1.0;\nvarying vec2 v_pos;\nvoid vertex() { v_pos = VERTEX; }\nvoid fragment() {\n\tfloat t = clamp(v_pos.x / width, 0.0, 1.0);\n\tvec4 g = t < 0.5 ? mix(col_a, col_b, t * 2.0) : mix(col_b, col_c, t * 2.0 - 1.0);\n\tCOLOR = vec4(COLOR.rgb * g.rgb * boost, COLOR.a * g.a);\n}"













var _grad_shader: Shader




const CIRCLE_COVER_SHADER: = "\nshader_type canvas_item;\nvoid fragment() {\n\tvec2 d = UV - vec2(0.5);\n\tfloat r = length(d) * 2.0;\n\tfloat edge = 1.0 - smoothstep(0.96, 1.0, r);\n\tfloat vig = 1.0 - smoothstep(0.35, 1.0, r) * 0.45;\n\tCOLOR = vec4(COLOR.rgb * vig * 0.92, COLOR.a * edge);\n}"








var _circle_shader: Shader


var best_score: = 0
var best_combo: = 0


const TRACK_INFO: = {
	"EXTRA MODE": "USAO", 
	"BYE BYE": "3-nen E-gumi Utatan · Assassination Classroom", 
	"SAYONARA": "REDSHiFT ft. Megurine Luka · Arcaea", 
	"GALAXY COLLAPSE": "Kurokotei · Touhou Project", 
	"DEEP SEA": "Chroma · sink to the deep sea world", 
	"SHIAWASE": "Dion Timmer · VIP · Rocket League", 
	"JUST DANCE": "synoxa ft. jayceko · dariacore", 
	"YOUNG GIRL A": "siinamota ft. Kagamine Rin", 
	"DEAR YOU": "DJ Genericname · Higurashi no Naku Koro ni", 
	"YARARARA": "AnythingBecomeMoe ft. Kasane Teto", 
	"RENAI CIRCULATION": "Sengoku Nadeko (CV: Kana Hanazawa)", 
	"CARAMELL XMAS": "Caramella Girls · Xmas Mix", 
	"KAILI": "Kaede Hiyama", 
	"AUGMENTED TENACITY": "N°ALA", 
	"RAVENATIC": "Aeolian", 
	"INTO THE FLOW": "Aeolian", 
	"CHOCOLATE SCRAMBLE": "takehirotei · Heilia's mapset", 
	"LOOPING THE ROOMS": "rusino feat. Hatsune Miku · Andrea's mapset", 
	"INTERNET YAMERO": "Aiobahn feat. KOTOKO · Ducky-'s mapset", 
	"TEST FAISCEAU": "prototype · hold notes", 
}



const PARTNER_TRACKS: = ["KAILI", "AUGMENTED TENACITY"]
const PARTNER_LABEL: = "PARTNER ARTIST"





func is_partner(track: String) -> bool:
	return track in PARTNER_TRACKS or track in Tuning.FEATURED



const TRACK_DESC: = {
	"EXTRA MODE": "The name says extra. It means it.", 
	"BYE BYE": "Short song. Shorter life expectancy.", 
	"SAYONARA": "Yes, another goodbye song. This one means it.", 
	"GALAXY COLLAPSE": "The galaxy isn't the only thing collapsing tonight.", 
	"DEEP SEA": "Good luck.", 
	"SHIAWASE": "'Shiawase' means happiness. The mapper disagrees.", 
	"JUST DANCE": "Hope you like red notes...", 
	"YOUNG GIRL A": "The A stands for aim. You're about to lose yours.", 
	"DEAR YOU": "The friendly one. We all start somewhere.", 
	"YARARARA": "", 
	"RENAI CIRCULATION": "Fuwa fuwari fuwa fuwari !", 
	"CARAMELL XMAS": "Everyone starts with this one !", 
	"KAILI": "Our first signed track. Be gentle with it.", 
	"FREEDOM DIVE": "You know this one. Everyone knows this one.", 
	"AUGMENTED TENACITY": "Featured artist.", 
	"CHOCOLATE SCRAMBLE": "Melts in your ears, not in your hands.", 
	"LOOPING THE ROOMS": "Meet the ghost circles. Follow the numbers.", 
	"INTERNET YAMERO": "Log off. You won't. Neither will the lanes.", 
	"RAVENATIC": "Not the final mapping — still being worked on. Play it anyway.", 
	"INTO THE FLOW": "Dev build only. Find the flow, keep it.", 
	"ENTANGLE NIGHT": "Too much streams for you.", 
	"TEST FAISCEAU": "Beam test range. Hold X and believe.", 
}






const ChartRatingLib = preload("res://scripts/chart_rating.gd")
const PerfLib = preload("res://scripts/performance.gd")
const ScoreLib = preload("res://scripts/scoring.gd")
const FxParticles = preload("res://scripts/fx_particles.gd")


const GRADE_COLS: = {
	"SS": Color(1.0, 0.96, 0.84), 
	"S": Color(1.0, 0.82, 0.3), "A": Color(0.45, 1.0, 0.75), 
	"B": Color(0.45, 0.82, 1.0), "C": Color(1.0, 0.68, 0.25), 
	"D": Color(1.0, 0.35, 0.4), 
}




var settings_ui: Control






var onboarding_ui: Control
var tutorial_ui: Control
var tutorial_active: = false




var orb_menu: Node2D
var menu_side_mascots: Array = []
var _center_spin_stage: = 0



var lane_mascots: LaneMascots



var _mouse_aim: = Vector2.ZERO



var _poll_last: = Vector2.ZERO
var _poll_time: = 0
var _event_pos: = Vector2.ZERO
var _event_time: = 0
var _event_kind: = "none"
var _event_count: = 0





















func _axis(name: String) -> int:
	return TextServerManager.get_primary_interface().name_to_tag(name)


func _font_var(base: Font, axes: Dictionary, spacing: = 0) -> FontVariation:
	var fv: = FontVariation.new()
	fv.base_font = base
	var tagged: = {}
	for k in axes:
		tagged[_axis(k)] = axes[k]
	fv.variation_opentype = tagged
	fv.spacing_glyph = spacing
	return fv


func _setup_typography() -> void :
	var fredoka: Font = load("res://fonts/Fredoka-Variable.ttf")
	var nunito: Font = load("res://fonts/NunitoSans-Variable.ttf")



	if fredoka != null and nunito != null:




		font_logo = _font_var(fredoka, {"wght": 620, "wdth": 112}, 1)


		font_display = _font_var(fredoka, {"wght": 500, "wdth": 100}, 1)


		font_body = _font_var(nunito, {"wght": 400, "wdth": 100, "opsz": 12})
		ThemeDB.fallback_font = font_body


		font_bold = _font_var(nunito, {"wght": 700, "wdth": 100, "opsz": 12})


		font_judge = _font_var(nunito, {"wght": 900, "wdth": 106, "opsz": 12})
	else:


		var inter: Font = load("res://fonts/Inter-Variable.ttf")
		if inter != null:
			font_body = _font_var(inter, {"wght": 400})
			ThemeDB.fallback_font = font_body
			font_bold = _font_var(inter, {"wght": 600}, 1)
			font_display = _font_var(inter, {"wght": 600}, 2)
			font_judge = _font_var(inter, {"wght": 800})
		else:
			ThemeDB.fallback_font = load("res://fonts/Rajdhani-Medium.ttf")
			font_body = ThemeDB.fallback_font
			font_bold = load("res://fonts/Rajdhani-Bold.ttf")
			font_display = load("res://fonts/Audiowide-Regular.ttf")
			font_judge = font_display
		font_logo = font_display


func _ready() -> void :




	get_window().title = "Meloa"


	get_window().files_dropped.connect(_on_files_dropped)





	if not OS.has_feature("editor") and SettingsManager.gpu_is_software():
		var cur: = SettingsManager.gpu_api_current()
		var next_api: = ""
		if cur == "d3d12":
			next_api = "vulkan"
		elif cur == "vulkan":
			next_api = "opengl3"

		if next_api != "" and SettingsManager.gpu_api_requested() != next_api:
			var switched: = SettingsManager.set_gpu_api(next_api)
			push_warning("Software renderer detected (%s) — %s requested for next launch: %s"
				%[SettingsManager.gpu_adapter_name(), next_api, str(switched)])
			_software_gpu_warning.call_deferred(switched, next_api)


	PerfTrace.mark("_ready : entrée")
	preload("res://scripts/stage_render.gd").tuning = tuning
	slider_bodies_root = Node2D.new()
	slider_bodies_root.name = "SliderBodies"
	world.add_child(slider_bodies_root)
	world.move_child(slider_bodies_root, notes_root.get_index())


	skin_back = SkinLayer.new()
	skin_back.name = "SkinBack"
	skin_back.front = false
	skin_back.main = self
	add_child(skin_back)
	move_child(skin_back, world.get_index())
	skin_front = SkinLayer.new()
	skin_front.name = "SkinFront"
	skin_front.front = true
	skin_front.main = self
	add_child(skin_front)
	move_child(skin_front, world.get_index() + 1)
	PerfTrace.mark("couches skin")
	_setup_typography()
	PerfTrace.mark("typographie")

	var env: = Environment.new()
	env.background_mode = Environment.BG_CANVAS
	env.glow_enabled = true
	env.glow_intensity = 1.15
	env.glow_bloom = 0.0
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE


	env.glow_hdr_threshold = 1.15



	if SettingsManager.gpu_is_compat():
		env.glow_enabled = false
	var we: = WorldEnvironment.new()
	we.environment = env
	add_child(we)


	var grad: = Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 1))
	grad.set_color(1, Color(1, 1, 1, 0))
	grad.add_point(0.3, Color(1, 1, 1, 0.5))
	grad.add_point(0.62, Color(1, 1, 1, 0.14))
	var gt: = GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(0.5, 0.02)
	gt.width = 256
	gt.height = 256
	glow_tex = gt

	var analyzer: = AudioEffectSpectrumAnalyzer.new()
	analyzer.buffer_length = 0.06
	AudioServer.add_bus_effect(0, analyzer)


	spectrum = AudioServer.get_bus_effect_instance(0, 
		AudioServer.get_bus_effect_count(0) - 1)
	Spectrum.analyzer = spectrum



	music_lp = AudioEffectLowPassFilter.new()
	music_lp.cutoff_hz = LP_OPEN
	AudioServer.add_bus_effect(AudioServer.get_bus_index("Music"), music_lp)
	conductor.bus = "Music"
	SettingsManager.settings_changed.connect(_on_setting_changed)



	Skins.changed.connect( func() -> void :
		sfx.set_pack(sfx.current_pack)
		for i in 3:
			LANE_COLS[i] = lane_base(i))
	PerfTrace.mark("environnement + audio")


	track_bgs.set_quality(SettingsManager.quality_base)
	if SettingsManager.quality_auto_applied != "":
		_auto_quality_notice.call_deferred(SettingsManager.quality_auto_applied)
	_load_records()
	PerfTrace.mark("records")
	_scan_charts()
	PerfTrace.mark("scan des charts")
	_load_chart()
	PerfTrace.mark("chargement du chart courant")

	var bg_layer: = CanvasLayer.new()
	bg_layer.layer = -1
	add_child(bg_layer)
	background = Background.new()
	background.main = self
	bg_layer.add_child(background)
	PerfTrace.mark("fond")
	_load_menu_background()
	PerfTrace.mark("fond de menu")



	beat_bus = BeatBus.new()
	beat_bus.main = self
	beat_bus.name = "BeatBus"
	add_child(beat_bus)
	beat_bus.beat.connect(_on_menu_beat)
	beat_bus.strong_beat.connect(_on_menu_strong_beat)
	_build_ui()
	PerfTrace.mark("construction de l'interface")
	player.lane_positions = [lane_x(0), lane_x(1), lane_x(2)]
	player.flash_duration = tuning.player_flash_duration
	player.glow_tex = glow_tex
	player.position = Vector2(lane_x(1), tuning.hit_y)







	lane_mascots = LaneMascots.new()
	lane_mascots.main = self
	lane_mascots.tuning = tuning
	world.add_child(lane_mascots)
	lane_mascots.add_mascot(LARI_DATA)
	lane_mascots.add_mascot(AME_DATA)
	lane_mascots.add_mascot(KOHA_DATA)
	PerfTrace.mark("mascottes de lane")
	sfx.volume_db_base = sfx_db()
	conductor.volume_db = music_db()
	world.tuning = tuning
	world.main = self
	world.queue_redraw()
	conductor.finished.connect(_on_track_finished)



	SettingsManager.apply_render_scale()


	if not get_viewport().size_changed.is_connected(SettingsManager.apply_render_scale):
		get_viewport().size_changed.connect(SettingsManager.apply_render_scale)
	_open_menu(Screen.HOME)
	PerfTrace.mark("ouverture du menu")
	PerfTrace.flush()



	if PerfSelfTest.requested():
		var st: Node = PerfSelfTest.new()
		st.main = self
		add_child(st)
		return
	_start_playtest_gate()




	if SettingsManager.menu_intro and (gate_root == null or not gate_root.visible):
		menu_intro.play()
	elif SettingsManager.menu_intro:



		_intro_pending = true



	if not SettingsManager.onboarding_done\
	and (gate_root == null or not gate_root.visible):
		if menu_intro.is_running():
			menu_intro.finished.connect(_maybe_open_onboarding, CONNECT_ONE_SHOT)
		else:
			_maybe_open_onboarding.call_deferred()







static func _num(v: float, fallback: = 0.0) -> float:
	return v if is_finite(v) else fallback










static func _tuples(value: Variant, arity: int) -> Array:
	if not (value is Array):
		return []
	var out: Array = []
	for e in (value as Array):
		if not (e is Array) or (e as Array).size() < arity:
			continue
		var row: Array = []
		var okay: = true
		for i in arity:
			var v = e[i]
			if not (v is float or v is int) or not is_finite(float(v)):
				okay = false
				break
			row.append(float(v))
		if okay:
			out.append(row)
	return out


func _load_chart() -> void :
	var file: = FileAccess.open(tuning.chart_path, FileAccess.READ)
	if file == null:





		MapLibrary.rescan()
		tuning.apply_track(tuning.current_track, tuning.current_diff)
		file = FileAccess.open(tuning.chart_path, FileAccess.READ)
		if file == null:
			tuning.apply_track(String(MapLibrary.tracks().keys()[0]))
			file = FileAccess.open(tuning.chart_path, FileAccess.READ)







	chart_error = ""
	chart_warning = ""
	var raw: = ""
	if file != null:
		raw = file.get_as_text()
		file.close()
	else:
		chart_error = "chart file not found"
	var parsed = JSON.parse_string(raw) if raw != "" else null
	if chart_error == "" and not (parsed is Dictionary):
		chart_error = "unreadable chart (invalid JSON)"
	var data: Dictionary = parsed if parsed is Dictionary else {}
	if chart_error == "" and not (data.get("notes", null) is Array):
		chart_error = "chart has no \"notes\" array"
	if chart_error != "":
		push_warning("chart '%s' : %s" % [tuning.chart_path, chart_error])
		data = {"notes": []}


	var audio_ref: = String(data.get("audio", ""))






	if MapLibrary.is_user_map(tuning.current_track):
		var lib_audio: = MapLibrary.audio_path(tuning.current_track)
		if lib_audio != "" and FileAccess.file_exists(lib_audio):
			audio_ref = lib_audio
	conductor.stream = MapLibrary.load_audio(audio_ref)


	if chart_error == "" and audio_ref != "" and conductor.stream == null:
		chart_error = "audio file missing (%s)" % audio_ref.get_file()



	_chart_offset = clampf(_num(float(data.get("offset", 0.0))), -60.0, 60.0)
	chart_bpm = maxf(_num(float(data.get("bpm", 120.0)), 120.0), 1.0)
	_apply_offset()
	chart_velocity = clampf(_num(float(data.get("velocity", 1.0)), 1.0), 0.1, 10.0)
	chart_end = maxf(_num(float(data.get("end", 0.0))), 0.0)
	kiai_sections = []
	for k in data.get("kiai", []):


		if not (k is Array) or (k as Array).size() < 2:
			push_warning("chart : section kiai malformée, ignorée")
			continue
		kiai_sections.append([_num(float(k[0])), _num(float(k[1]))])
	chart_practice = _num(float(data.get("practice", -1.0)), -1.0)
	_load_lane_fx(data.get("fx", []) if data.get("fx", []) is Array else [])
	chart_notes = []
	var skipped: = 0
	var out_of_lane: = 0
	for n in (data["notes"] as Array):



		if not (n is Dictionary) or not n.has("time") or not n.has("type"):
			skipped += 1
			continue
		if int(n.get("lane", 1)) < 0 or int(n.get("lane", 1)) >= LANE_COUNT:
			out_of_lane += 1
		var note: = {
			"time": _num(float(n["time"])), 




			"lane": clampi(int(n.get("lane", 1)), 0, LANE_COUNT - 1), 
			"type": String(n["type"]), 


			"v": clampf(_num(float(n.get("v", 1.0)), 1.0), 0.05, 20.0), 
		}


		if n.has("x") and n.has("y"):
			note["x"] = _num(float(n["x"]), 640.0)
			note["y"] = _num(float(n["y"]), 360.0)

		if note.type == "beam":
			note["duration"] = maxf(_num(float(n.get("duration", 1.0)), 1.0), 0.02)
			note["path"] = _tuples(n.get("path", []), 2)

		elif note.type == "sliderg":
			note["duration"] = maxf(_num(float(n.get("duration", 1.0)), 1.0), 0.02)
			note["points"] = _tuples(n.get("points", []), 3)


			var reps: Array = []
			var raw_reps = n.get("repeats", [])
			if raw_reps is Array:
				for r in raw_reps:
					if (r is float or r is int) and is_finite(float(r)):
						reps.append(clampf(float(r), 0.0, 1.0))
			note["repeats"] = reps

		elif note.type == "sliderm":
			note["duration"] = maxf(_num(float(n.get("duration", 1.0)), 1.0), 0.02)


		elif note.type == "clickx":
			note["extra"] = _tuples(n.get("extra", []), 3)
			if not note.extra.is_empty():
				note["duration"] = float(note.extra.back()[0]) - note.time
		chart_notes.append(note)




	chart_notes.sort_custom( func(a, b):
		if a.time != b.time:
			return a.time < b.time
		if int(a.lane) != int(b.lane):
			return int(a.lane) < int(b.lane)
		return String(a.type) < String(b.type))
	_assign_order_numbers()
	if skipped > 0:


		push_warning("chart '%s' : %d note(s) sans time/type ignorée(s)"
			%[tuning.chart_path, skipped])
		chart_warning = "%d malformed note(s) skipped" % skipped
	if out_of_lane > 0:
		push_warning("chart '%s' : %d note(s) hors des lanes 0..%d, ramenée(s) dans le terrain"
			%[tuning.chart_path, out_of_lane, LANE_COUNT - 1])
		if chart_warning == "":
			chart_warning = "%d note(s) out of lane range" % out_of_lane



	var authored: Array = chart_notes



	chart_notes = Mods.apply_chart(chart_notes, CHART_W)
	_merge_dodge_stacks()
	_apply_chart_frame()
	_validate_chart()
	_compute_bounds(data)



	_expected_judgements = 0
	for n in chart_notes:
		_expected_judgements += int(n.get("stack", 1))
		if n.type in ["sliderg", "sliderm", "beam"]:
			_expected_judgements += 1
		elif n.type == "clickx":
			_expected_judgements += (n.get("extra", []) as Array).size()
	_combo_portion_max = ScoreLib.combo_portion_max(_expected_judgements)





	_compute_yellow_spans(authored if Mods.has("no_white") else chart_notes)
	_build_breaks()


















const AUTO_TAIL: = 2.2
const AUTO_LEAD: = 2.5
const AUTO_MIN_SKIP: = 5.0
const AUTO_MIN_CUT: = 4.0

func _compute_bounds(data: Dictionary) -> void :
	auto_start = 0.0
	auto_end = 0.0
	var first: = INF
	var last: = - INF
	for n in chart_notes:
		first = minf(first, float(n.time))


		last = maxf(last, float(n.time) + float(n.get("duration", 0.0)))


	for ev in data.get("fx", []):
		if not (ev is Dictionary):
			continue
		var t0: = float(ev.get("time", 0.0))
		first = minf(first, t0)
		last = maxf(last, t0 + maxf(float(ev.get("len", 0.5)), 0.0))
	for k in kiai_sections:
		first = minf(first, float(k[0]))
		last = maxf(last, float(k[1]))
	if first == INF:
		return
	var audio_len: float = conductor.stream.get_length() if conductor.stream != null\
	else 0.0


	if first > AUTO_MIN_SKIP:
		auto_start = maxf(0.0, first - AUTO_LEAD)


	var stop: = last + AUTO_TAIL
	if audio_len > 0.0 and stop < audio_len - AUTO_MIN_CUT:
		auto_end = stop




func map_end() -> float:
	return chart_end if chart_end > 0.0 else auto_end




func map_start() -> float:
	return chart_practice if chart_practice > 0.0 else auto_start











const CHART_W: = 1280.0
const CHART_H: = 720.0


func chart_origin() -> Vector2:
	var vs: = get_viewport_rect().size
	return Vector2(maxf((vs.x - CHART_W) * 0.5, 0.0), maxf((vs.y - CHART_H) * 0.5, 0.0))


func _apply_chart_frame() -> void :
	var o: = chart_origin()
	if o == Vector2.ZERO:
		return
	for n in chart_notes:
		if n.has("x") and n.has("y"):
			n["x"] = float(n["x"]) + o.x
			n["y"] = float(n["y"]) + o.y
		if n.has("points"):
			for p in n["points"]:
				p[1] = float(p[1]) + o.x
				p[2] = float(p[2]) + o.y
		if n.has("extra"):
			for e in n["extra"]:
				e[1] = float(e[1]) + o.x
				e[2] = float(e[2]) + o.y





func _compute_yellow_spans(notes: Array = []) -> void :


	if notes.is_empty():
		notes = chart_notes
	yellow_spans = []
	var start: = -1.0
	var last: = -1.0
	for n in notes:
		if n.type == "click" or n.type == "clickx" or n.type == "sliderg":
			if start < 0.0:
				start = float(n.time)
			last = maxf(last, float(n.time) + float(n.get("duration", 0.0)))
		else:






			var hole: float = minf(last, float(n.time)) - start
			if start >= 0.0 and hole >= 2.5:


				yellow_spans.append([start, float(n.time) - 1.45])
			start = -1.0
			last = -1.0
	if start >= 0.0 and last - start >= 2.5:
		yellow_spans.append([start, last + 0.6])






func _build_breaks() -> void :
	break_windows = []
	for e in fx_breaks:
		var ev: Dictionary = e.ev



		break_windows.append({
			"t0": e.t0, "t1": e.t0 + e.dur, 
			"col": Color.from_string(String(ev.get("color", "#b48cff")), 
				Color(0.71, 0.55, 1.0)), 

			"timer": bool(ev.get("timer", true)), 
		})
	var prev_end: = 0.0
	var first: = true
	for n in chart_notes:
		var nt: = float(n.time)
		if not first and nt - prev_end > 6.0:


			var ws: = prev_end + 1.0
			var we: = nt - 1.5
			for e in fx_texts:
				if e.t0 < we and e.t0 + e.dur > prev_end:
					ws = maxf(ws, e.t0 + e.dur + 0.4)
			var clash: = false
			for w in break_windows:
				if w.t0 < we and w.t1 > ws:
					clash = true
					break
			if not clash and we - ws >= 4.0:
				break_windows.append({"t0": ws, "t1": we, 
					"col": Color(0.71, 0.55, 1.0), "timer": true})
		prev_end = maxf(prev_end, nt + float(n.get("duration", 0.0)))
		first = false
	break_windows.sort_custom( func(a, b): return a.t0 < b.t0)



func _update_break(t: float) -> void :
	_in_break = false
	var cur = null
	for w in break_windows:
		if t >= w.t0 and t <= w.t1:
			cur = w
			break
	if cur == null:
		if _break_node != null:
			_break_node.visible = false
		return
	if _break_node == null:
		_break_node = preload("res://scripts/break_screen.gd").new()
		_break_node.font = font_display
		_break_node.glow_tex = glow_tex
		ui_layer.add_child(_break_node)
		ui_layer.move_child(_break_node, 0)
	_break_node.visible = true
	_break_node.alpha = clampf(minf((t - cur.t0) / 0.6, (cur.t1 - t) / 0.6), 0.0, 1.0)
	_break_node.col = cur.col




	_break_node.remaining = maxf(cur.t1 - t, 0.0)
	_break_node.duration = maxf(cur.t1 - cur.t0, 0.001)
	_break_node.show_timer = bool(cur.get("timer", true))
	_in_break = true







func _validate_chart() -> void :


	var removed: = 0
	for i in 3:
		var gk: = "gone%d" % i
		if not lane_fx.has(gk):
			continue
		for e in lane_fx[gk].evs:
			for n in chart_notes:
				if int(n.get("lane", 1)) != i\
				or n.type not in ["parry", "dodge", "sliderm", "beam"]:
					continue
				if n.time >= float(e.t0) and n.time < float(e.t0) + float(e.dur):
					removed += 1
					push_warning("chart : note '%s' t=%.2f sur la lane %d RETIRÉE (lane_remove %.2f-%.2f)"
						%[n.type, n.time, i, e.t0, e.t0 + e.dur])
	if removed > 0 and chart_warning == "":
		chart_warning = "%d note(s) on a removed lane" % removed
	var half_band: = (tuning.lane_width + tuning.lane_gap) * 0.5
	for s in chart_notes:
		if s.type != "sliderm" and s.type != "sliderg":
			continue
		var s_end: float = s.time + s.duration
		var clicks: = 0
		for n in chart_notes:
			if n == s or n.time < s.time - 0.05 or n.time > s_end + 0.05:
				continue
			if s.type == "sliderm":
				if n.type == "click":
					clicks += 1
					if clicks > 1:
						push_warning("chart : 2e jaune pendant le sliderm t=%.2f" % s.time)
					elif absf(float(n.x) - lane_x(s.lane)) > half_band:
						push_warning("chart : jaune INATTEIGNABLE (hors bande de lane) pendant le sliderm t=%.2f" % s.time)
				else:
					push_warning("chart : note '%s' interdite pendant le sliderm t=%.2f (joueur cloué sur sa lane)" % [n.type, s.time])
			else:
				if n.type == "parry":
					var u: float = (n.time - s.time) / s.duration
					var rail_x: float = _sliderg_pos(s, u).x
					var best: = 0
					for i in 3:
						if absf(rail_x - lane_x(i)) < absf(rail_x - lane_x(best)):
							best = i
					if best != int(n.lane):
						push_warning("chart : blanche lane %d hors du rail (lane %d) pendant le sliderg t=%.2f" % [n.lane, best, s.time])
				elif n.type != "sliderg":
					push_warning("chart : note '%s' déconseillée pendant le sliderg t=%.2f" % [n.type, s.time])



func _sliderg_pos(nd: Dictionary, u: float) -> Vector2:
	var pts: Array = nd.points
	if pts.is_empty():
		return Vector2.ZERO
	u = clampf(u, 0.0, 1.0)
	var prev_u: = float(pts[0][0])
	var prev: = Vector2(pts[0][1], pts[0][2])
	for p in pts:
		if u <= float(p[0]):
			var span: = float(p[0]) - prev_u
			var pt: = Vector2(p[1], p[2])
			return pt if span < 0.0001 else prev.lerp(pt, (u - prev_u) / span)
		prev_u = float(p[0])
		prev = Vector2(p[1], p[2])
	return prev





func start_game(from: = 0.0) -> void :






	if from <= 0.0 and playtest_from < 0.0:
		from = map_start()



	if lb_overlay != null:
		lb_overlay.visible = false
	if account_panel != null:
		account_panel.visible = false
	_apply_hud_flags()
	conductor.stop()
	for n in live_notes:
		if is_instance_valid(n):
			_release_note(n, false)
	live_notes.clear()
	next_spawn = 0
	if from > 0.0:
		while next_spawn < chart_notes.size()\
		and chart_notes[next_spawn].time < from + 0.5:
			next_spawn += 1


	Skins.gameplay = true
	player.glow_tex = game_glow()
	score = 0
	combo = 0
	max_combo = 0
	hp = tuning.hp_max
	judged_count = 0
	accuracy_sum = 0.0
	_combo_portion = 0.0
	run_samples.clear()
	game_over = false
	track_done = false
	perfect_chain = 0
	_extinguish()
	_hide_game_over()
	game_paused = false
	_resuming = false
	conductor.stream_paused = false

	if _end_fade_tw != null and _end_fade_tw.is_valid():
		_end_fade_tw.kill()
	_end_fade_tw = null
	conductor.volume_db = music_db()


	if Mods.has("invincible") != invincible:
		_toggle_invincible(Mods.has("invincible"))
	if Mods.has("auto") != auto_mode:
		_toggle_auto(Mods.has("auto"))


	Telemetry.note_flags(auto_mode, invincible)


	run_assisted = auto_mode or invincible or chart_practice > 0.0\
	or not Mods.ranked()
	mods_mult = Mods.score_mult()
	_refresh_mode_hud()
	_snapshot_ranks()
	if pause_root != null:
		pause_root.visible = false
	hit_deltas.clear()
	_shake_amp = 0.0
	_display_score = 0.0


	_hud_score = -1
	_hud_combo = -1
	_hud_acc = -1
	_hud_time_s = -1
	world.position = Vector2.ZERO
	player.reset()
	end_panel.visible = false
	lane_mascots.reset_all()




	conductor.play_with_lead(maxf(from, 0.0), _lead_in_needed(maxf(from, 0.0)))




	_refresh_hud()




func _process(delta: float) -> void :


	Skins.gameplay = screen == Screen.PLAYING
	_update_mouse_mode()


	if _film_rect != null and _film_rect.visible\
	and (screen != Screen.PLAYING or game_over or track_done):
		_film_off()
	if not _pending_gate.is_empty() and not _gate_busy():
		var g: Dictionary = _pending_gate
		_pending_gate = {}
		_gate_raise(String(g.mode), String(g.msg), g.data)
	_poll_hold_r(delta)
	_poll_hover_sfx()

	track_covers.poll()
	track_bgs.poll()



	if not track_covers.take_arrived().is_empty():
		_on_covers_ready()
	_update_gauntlet_giggle(delta)
	_fps_accum += delta
	if _fps_accum >= 0.25 and _fps_label != null:
		_fps_accum = 0.0

		_fps_label.visible = SettingsManager.vis_on("hud_fps")
		if _fps_label.visible:
			_fps_label.text = "%d FPS" % Engine.get_frames_per_second()


	for i in range(live_notes.size() - 1, -1, -1):
		if not is_instance_valid(live_notes[i]):
			live_notes.remove_at(i)
	_update_shake(delta)
	line_flash = maxf(0.0, line_flash - delta * 4.5)
	_update_bg_video()
	if screen != Screen.PLAYING and fx_spread != 1.0:
		_reset_lane_fx()
	if screen != Screen.PLAYING:
		if screen == Screen.HOME and now_bar != null:
			now_bar.refresh()






		if screen == Screen.HOME and orb_menu != null\
		and (menu_intro == null or not menu_intro.is_running()):
			var look_target: Vector2 = aim_position()
			if _menu_hover_idx >= 0 and orbit_menu != null and orbit_menu.is_open:
				look_target = orbit_menu.button_global(_menu_hover_idx)
			orb_menu.set_look_target(look_target)
			for sm in menu_side_mascots:

				if _center_spin_stage > 0:
					continue
				sm.set_look_target(look_target)
		return
	if _pre_roll:


		world.queue_redraw()
		_refresh_hud()
		return
	if game_over or track_done:
		return
	if game_paused:
		return
	conductor.tick_lead(delta)
	var t: = conductor.get_song_time()
	world.queue_redraw()





	var stop_at: = map_end()
	if stop_at > 0.0 and t >= stop_at and playtest_from < 0.0:
		_end_fade_tw = create_tween()
		_end_fade_tw.tween_property(conductor, "volume_db", music_db() - 32.0, 1.4)
		_end_fade_tw.tween_callback(conductor.stop)
		_complete_map()
		return
	_update_lane_fx(t)


	_lane_x_frame = -1
	_update_break(t)



	var lc_target: = 1.0 if _in_break else 0.0
	for ys in yellow_spans:
		if t >= ys[0] - 0.12 and t <= ys[1]:
			lc_target = 1.0
			break
	lane_clear = move_toward(lane_clear, lc_target, delta * 2.4)






	var kiai_now: = not kiai_sections.is_empty() and _in_kiai(t)
	if not on_fire and kiai_now:
		_ignite()
	elif on_fire and not kiai_now:
		on_fire = false
	var fever_target: = clampf(combo / float(FIRE_COMBO), 0.0, 1.0)\
	* (1.0 if on_fire else 0.6)
	fever = minf(fever_target, fever + delta * 0.6) if fever_target > fever\
	else maxf(fever_target, fever - delta * 2.0)
	player.fever = fever
	_spawn_due(t)
	if auto_mode:
		_run_auto(t, delta)
	else:


		if not Mods.is_mania():
			_update_lane_from_mouse()
		if Mods.has("autoclic"):
			_run_autoclic(t)
	_judge_expired(t)
	_update_beams(t)
	_update_sliders(t)


	var pr: = 0
	for n in live_notes:
		if n.judged or not ("priority" in n):
			continue
		n.priority = pr
		pr += 1


	var breathe: = 1.0 + 0.03 * beat_pulse()
	for n in live_notes:
		n.update_visual(t, tuning)
		if n.type in ["beam", "sliderg", "sliderm"]:
			continue
		if n.type != "click" and n.type != "clickx":
			n.position.x = lane_x_at(n.lane, n.position.y)
		if not n.judged:
			n.scale = Vector2.ONE * breathe
	_refresh_hud()





func _on_covers_ready() -> void :


	if map_select != null:
		map_select.on_covers_ready()






func _spawn_lead(nd: Dictionary) -> float:
	var lead: float = tuning.click_approach_time\
	if nd.type == "click" or nd.type == "clickx" else tuning.travel_time
	if nd.type == "sliderg":
		lead = tuning.sliderg_approach_time
	return lead / (chart_velocity * nd.get("v", 1.0) * _kiai_vmult(nd.time)\
	* SettingsManager.scroll_speed)





func _lead_in_needed(from: float) -> float:


	var start: float = from + conductor.song_offset
	var need: = 0.0
	var i: = next_spawn
	while i < chart_notes.size():
		var nd: Dictionary = chart_notes[i]
		if float(nd.time) > start + 1.5:
			break
		need = maxf(need, _spawn_lead(nd) - (float(nd.time) - start))
		i += 1
	return clampf(need, 0.0, 1.5)


func _spawn_due(t: float) -> void :
	while next_spawn < chart_notes.size():
		var nd: Dictionary = chart_notes[next_spawn]
		var lead: = _spawn_lead(nd)
		if t < nd.time - lead:
			break



		_spawn_note(nd, next_spawn)
		next_spawn += 1



func _kiai_vmult(note_time: float) -> float:
	return tuning.kiai_velocity_mult if _in_kiai(note_time) else 1.0






func _load_lane_fx(events: Array) -> void :
	lane_fx = {}
	fx_texts = []
	fx_images = []
	_fx_image_cache.clear()
	fx_pulses = []
	fx_themes = []
	fx_breaks = []
	_reset_lane_fx()
	for raw in events:
		var ev: Dictionary = raw
		var kind: = String(ev.get("type", ""))
		var e: = {
			"t0": float(ev.get("time", 0.0)), 
			"dur": maxf(float(ev.get("len", 0.5)), 0.001), 
			"to": float(ev.get("to", 1.0)), 
			"ease": String(ev.get("ease", "io")), 
			"ev": ev, 
		}
		var lane: = clampi(int(ev.get("lane", 1)), 0, 2)
		match kind:
			"text":
				fx_texts.append(e)
			"image":
				fx_images.append(e)
			"spread":
				_fx_track("spread", 1.0).append(e)
			"lane_dx":
				_fx_track("dx%d" % lane, 0.0).append(e)
			"lane_pos":



				e["to"] = float(e["to"]) + chart_origin().x
				_fx_track("pos%d" % lane, chart_origin().x
					+ 640.0 + float(lane - 1) * (tuning.lane_width + tuning.lane_gap)).append(e)
			"lane_sway":
				_fx_track("sway%d" % lane, 0.0).append(e)
			"lane_alpha":
				_fx_track("alpha%d" % lane, 1.0).append(e)
			"lane_color":
				_fx_track("col%d" % lane, 0.0).append(e)
			"lane_width":
				_fx_track("width%d" % lane, 1.0).append(e)
			"lane_remove":


				_fx_track("gone%d" % lane, 0.0).append(e)
			"bg_tint":
				_fx_track("bgtint", 0.0).append(e)
			"film":
				_fx_track("film", 0.0).append(e)
			"particles":
				_fx_track("particles", 0.0).append(e)
			"lane_rotate":
				_fx_track("rot", 0.0).append(e)
			"bg_ambient":




				_fx_track("bgamb", 0.0).append(e)
			"bg_theme":


				var prm: Dictionary = ev.get("params", {})
				e["theme"] = String(prm.get("theme", "rings"))
				e["col"] = Color.from_string(String(prm.get("color", "")), 
					Color(0, 0, 0, 0))
				fx_themes.append(e)
			"break":


				fx_breaks.append(e)
			"shake", "glitch":

				e["kind"] = kind
				fx_pulses.append(e)
			_:
				push_warning("fx : type inconnu '%s' (ignoré)" % kind)
	for key in lane_fx:
		var evs: Array = lane_fx[key].evs
		evs.sort_custom( func(a, b): return a.t0 < b.t0)
		var prev_to: float = lane_fx[key].neutral
		for e in evs:
			e["from"] = prev_to
			prev_to = e.to





	for i in 3:
		var pkey: = "pos%d" % i
		if not lane_fx.has(pkey):
			continue
		var pevs: Array = lane_fx[pkey].evs
		for j in pevs.size():
			if j > 0:
				var prev = pevs[j - 1]
				if not bool(prev.ev.get("release", false)):
					continue
				if float(pevs[j].t0) < float(prev.t0) + float(prev.dur):
					continue
			pevs[j]["from"] = _natural_lane_x(i, float(pevs[j].t0))
	fx_texts.sort_custom( func(a, b): return a.t0 < b.t0)
	fx_images.sort_custom( func(a, b): return a.t0 < b.t0)
	fx_themes.sort_custom( func(a, b): return a.t0 < b.t0)
	if not lane_fx.is_empty() or not fx_texts.is_empty():
		print("fx : %d pistes de lanes, %d textes" % [lane_fx.size(), fx_texts.size()])


func _fx_track(key: String, neutral: float) -> Array:
	if not lane_fx.has(key):
		lane_fx[key] = {"neutral": neutral, "evs": []}
	return lane_fx[key].evs


func _reset_lane_fx() -> void :
	_lane_x_frame = -1
	fx_spread = 1.0
	fx_dx = [0.0, 0.0, 0.0]
	fx_alpha = [1.0, 1.0, 1.0]
	fx_pos = [NAN, NAN, NAN]
	fx_sway_amp = [0.0, 0.0, 0.0]
	fx_width = [1.0, 1.0, 1.0]
	fx_gone = [0.0, 0.0, 0.0]
	_film_off()
	fx_rot = 0.0
	if world.rotation != 0.0:
		world.rotation = 0.0
	fx_particles = {}
	if _fx_particles_node != null:
		_fx_particles_node.visible = false
	fx_shake_off = Vector2.ZERO
	fx_glitch = 0.0
	for i in 3:
		LANE_COLS[i] = lane_base(i)


	if player != null:
		player.lane_positions = [lane_x(0), lane_x(1), lane_x(2)]
		player.position.x = player.lane_positions[player.lane]
	if background != null:
		background.modulate = Color(1, 1, 1, background.modulate.a)
		background.ambient_w = 0.0
		background.theme_a = "rings"
		background.theme_b = "rings"
		background.theme_mix = 1.0
		background.theme_col_a = Color(0, 0, 0, 0)
		background.theme_col_b = Color(0, 0, 0, 0)
	for slot in _fx_labels:
		for l in slot.values():
			l.visible = false
	for tr in _fx_image_nodes:
		tr.visible = false
	if _fx_deco != null:
		_fx_deco.items.clear()
	if _glitch_rect != null:
		_glitch_rect.visible = false
	if _break_node != null:
		_break_node.visible = false






func _natural_lane_x(i: int, t: float) -> float:
	var sp: = 1.0
	if lane_fx.has("spread"):
		sp = _fx_value("spread", t)
	var dx: = 0.0
	if lane_fx.has("dx%d" % i):
		dx = _fx_value("dx%d" % i, t)
	return get_viewport_rect().size.x * 0.5\
	+ float(i - 1) * (tuning.lane_width + tuning.lane_gap) * sp + dx


func _fx_value(key: String, t: float) -> float:
	var track: Dictionary = lane_fx[key]
	var evs: Array = track.evs
	var cur = null
	for e in evs:
		if e.t0 <= t:
			cur = e
		else:
			break
	if cur == null:
		return track.neutral
	var u: = clampf((t - cur.t0) / cur.dur, 0.0, 1.0)
	return lerpf(cur.from, cur.to, _fx_ease(u, cur.ease))


static func _fx_ease(u: float, kind: String) -> float:
	match kind:
		"hold":
			return 0.0
		"in":
			return u * u
		"out":
			return 1.0 - (1.0 - u) * (1.0 - u)
		"io":
			return u * u * (3.0 - 2.0 * u)
		"elastic":
			if u <= 0.0 or u >= 1.0:
				return clampf(u, 0.0, 1.0)
			return pow(2.0, -10.0 * u) * sin((u * 10.0 - 0.75) * TAU / 3.0) + 1.0
	return u



func _update_lane_fx(t: float) -> void :
	if lane_fx.is_empty() and fx_texts.is_empty() and fx_themes.is_empty()\
	and fx_images.is_empty():



		player.lane_positions = [lane_x(0), lane_x(1), lane_x(2)]
		player.position.x = player.lane_positions[player.lane]
		return


	if not fx_themes.is_empty() and background != null:
		var prev_theme: = "rings"
		var prev_col: = Color(0, 0, 0, 0)
		var cur = null
		for e in fx_themes:
			if e.t0 <= t:
				if cur != null:
					prev_theme = cur.theme
					prev_col = cur.col
				cur = e
			else:
				break
		if cur == null:
			background.theme_a = "rings"
			background.theme_b = "rings"
			background.theme_mix = 1.0
			background.theme_col_b = Color(0, 0, 0, 0)
		else:
			background.theme_a = prev_theme
			background.theme_col_a = prev_col
			background.theme_b = cur.theme
			background.theme_col_b = cur.col
			background.theme_mix = clampf((t - cur.t0) / cur.dur, 0.0, 1.0)
	for key in lane_fx:
		var v: = _fx_value(key, t)
		var k: String = key
		if k == "spread":
			fx_spread = v
		elif k.begins_with("dx"):
			fx_dx[int(k.substr(2))] = v
		elif k.begins_with("pos"):




			var li2: = int(k.substr(3))
			var evs2: Array = lane_fx[k].evs
			var cur2 = null
			for e in evs2:
				if e.t0 <= t:
					cur2 = e
				else:
					break
			if cur2 == null or (bool(cur2.ev.get("release", false))
					and t >= cur2.t0 + cur2.dur):
				fx_pos[li2] = NAN
			else:
				fx_pos[li2] = v
		elif k.begins_with("sway"):
			var li: = int(k.substr(4))



			var evs: Array = lane_fx[k].evs
			var cur_sw = null
			for e in evs:
				if e.t0 <= t:
					cur_sw = e
			if cur_sw == null:
				fx_sway_amp[li] = 0.0
			else:
				fx_sway_amp[li] = float(cur_sw.to)\
				* FxEval.sway_envelope(t, float(cur_sw.t0), float(cur_sw.dur))
				fx_sway_freq[li] = float(cur_sw.ev.get("params", {}).get("freq", 0.5))
		elif k.begins_with("alpha"):
			fx_alpha[int(k.substr(5))] = v
		elif k.begins_with("col"):
			var lc: = int(k.substr(3))


			LANE_COLS[lc] = FxEval.lane_color(lane_fx[k].evs, lane_base(lc), t)
		elif k.begins_with("width"):
			fx_width[int(k.substr(5))] = maxf(v, 0.1)
		elif k == "film":



			fx_film = FxEval.window_value(lane_fx[k].evs, t)
			var cur_f = null
			for e in lane_fx[k].evs:
				if e.t0 <= t:
					cur_f = e
				else:
					break
			if cur_f != null:
				var fp: Dictionary = cur_f.ev.get("params", {})
				fx_film_grain = clampf(float(fp.get("grain", 1.0)), 0.0, 2.0)
				fx_film_sepia = 1.0 if bool(fp.get("sepia", false)) else 0.0
		elif k == "rot":
			fx_rot = v
		elif k == "particles":


			v = FxEval.window_value(lane_fx[k].evs, t)
			var cur_p = null
			for e in lane_fx[k].evs:
				if e.t0 <= t:
					cur_p = e
				else:
					break
			if cur_p == null or v <= 0.001:
				fx_particles = {}
			else:
				fx_particles = {"amt": clampf(v, 0.0, 1.0), 
					"st": FxParticles.settings(cur_p.ev.get("params", {}))}
		elif k.begins_with("gone"):
			var lgn: = int(k.substr(4))
			var cur_g = null
			for e in lane_fx[k].evs:
				if e.t0 <= t:
					cur_g = e
				else:
					break
			fx_gone[lgn] = 0.0 if cur_g == null\
			else FxEval.remove_envelope(t, float(cur_g.t0), float(cur_g.dur))
		elif k == "bgamb":


			var acol: = Color(0.6, 0.38, 1.0)
			for e in lane_fx[k].evs:
				if e.t0 <= t:
					acol = Color.from_string(
						String(e.ev.get("params", {}).get("color", "#9a61ff")), acol)
			background.ambient_col = acol
			background.ambient_w = clampf(v, 0.0, 1.0)
		elif k == "bgtint":

			var tint: = Color.WHITE
			for e in lane_fx[k].evs:
				if e.t0 <= t:
					tint = Color.from_string(
						String(e.ev.get("params", {}).get("color", "#ffffff")), tint)
			var w: = clampf(v, 0.0, 1.0)
			background.modulate = Color(lerpf(1.0, tint.r, w), 
				lerpf(1.0, tint.g, w), lerpf(1.0, tint.b, w), 
				background.modulate.a)


	fx_shake_off = Vector2.ZERO
	fx_glitch = 0.0
	for e in fx_pulses:
		if t < e.t0 or t > e.t0 + e.dur:
			continue
		var u: float = (t - e.t0) / e.dur
		var env: = 1.0 - _fx_ease(u, e.ease)
		if e.kind == "shake":


			if SettingsManager.vis_on("fx_shake_events"):
				fx_shake_off += FxEval.pulse_shake(t, e.t0, e.dur, e.to)
		else:
			fx_glitch = maxf(fx_glitch, e.to * env)
	_update_glitch_overlay(t)
	_update_film_overlay(t)
	_update_particles(t)

	player.lane_positions = [lane_x(0), lane_x(1), lane_x(2)]
	player.position.x = player.lane_positions[player.lane]
	_fx_update_text(t)
	_fx_update_images(t)















const FX_GLITCH_SHADER: = "\nshader_type canvas_item;\nuniform sampler2D scr : hint_screen_texture, filter_nearest;\nuniform float amt = 0.0;\nuniform float tt = 0.0;\nfloat h(float n) { return fract(sin(n * 127.1) * 43758.5453); }\nvoid fragment() {\n\tvec2 uv = SCREEN_UV;\n\tfloat step_t = floor(tt * 24.0);\n\tfloat band = floor(uv.y * 28.0);\n\tfloat r1 = h(band + step_t * 31.7);\n\tfloat shift = (r1 - 0.5) * 0.07 * amt * step(0.62, h(band * 3.3 + step_t));\n\tuv.x = fract(uv.x + shift);\n\tfloat sp = 0.004 * amt * (0.5 + r1);\n\tvec3 c;\n\tc.r = texture(scr, vec2(fract(uv.x + sp), uv.y)).r;\n\tc.g = texture(scr, uv).g;\n\tc.b = texture(scr, vec2(fract(uv.x - sp), uv.y)).b;\n\tfloat broken = step(0.84, h(band * 7.7 + step_t * 1.3)) * amt;\n\tc = mix(c, c * 0.25, broken);\n\t// bandes TRANSLUCIDES (plus de blanc) : l'overlay s'efface par tranches,\n\t// l'image nette transparaît au travers — le glitch semble se déchirer.\n\tfloat ghost = step(0.90, h(band * 9.1 + step_t * 2.1)) * amt;\n\tCOLOR = vec4(c, 1.0 - ghost * 0.75);\n}"






























const FX_IMAGE_SHADER: = "\nshader_type canvas_item;\nuniform float amt = 0.0;\nuniform float tt = 0.0;\n// case affichée dans la texture (x0, y0, x1, y1 en UV) : une image fixe\n// occupe (0,0,1,1), une vignette de planche GIF sa cellule — le glitch ne\n// doit pas déborder sur les cellules voisines.\nuniform vec4 reg = vec4(0.0, 0.0, 1.0, 1.0);\nvarying vec4 vcol;\nfloat h(float n) { return fract(sin(n * 127.1) * 43758.5453); }\nvoid vertex() { vcol = COLOR; }\nvoid fragment() {\n\tvec2 uv = UV;\n\tvec4 c = texture(TEXTURE, uv);\n\tif (amt > 0.001) {\n\t\tfloat rw = max(reg.z - reg.x, 0.0001);\n\t\tfloat rh = max(reg.w - reg.y, 0.0001);\n\t\tfloat step_t = floor(tt * 24.0);\n\t\tfloat band = floor((uv.y - reg.y) / rh * 18.0);\n\t\tfloat r1 = h(band + step_t * 31.7);\n\t\tfloat shift = (r1 - 0.5) * 0.14 * amt * step(0.55, h(band * 3.3 + step_t)) * rw;\n\t\tuv.x += shift;\n\t\tfloat sp = 0.012 * amt * (0.5 + r1) * rw;\n\t\tc.r = texture(TEXTURE, uv + vec2(sp, 0.0)).r;\n\t\tc.g = texture(TEXTURE, uv).g;\n\t\tc.b = texture(TEXTURE, uv - vec2(sp, 0.0)).b;\n\t\tc.a = texture(TEXTURE, uv).a;\n\t\tfloat broken = step(0.86, h(band * 7.7 + step_t * 1.3)) * amt;\n\t\tc.rgb = mix(c.rgb, c.rgb * 0.2, broken);\n\t\tfloat ghost = step(0.92, h(band * 9.1 + step_t * 2.1)) * amt;\n\t\tc.a *= 1.0 - ghost * 0.8;\n\t\tif (uv.x < reg.x || uv.x > reg.z) { c = vec4(0.0); }\n\t}\n\tCOLOR = c * vcol;\n}"




































const FX_TEXT_SHADER: = "\nshader_type canvas_item;\nuniform vec3 col_a = vec3(1.0);\nuniform vec3 col_b = vec3(1.0);\nuniform float x0 = 0.0;\nuniform float x1 = 100.0;\nuniform float scrw = 1280.0;\nvoid fragment() {\n\tfloat k = clamp((SCREEN_UV.x * scrw - x0) / max(x1 - x0, 1.0), 0.0, 1.0);\n\t// Glyphe MONOCHROME (lettre : rgb gris, la couleur vient de la police\n\t// blanche) -> dégradé néon. Glyphe COLORÉ (emoji bitmap) -> on garde ses\n\t// couleurs : le dégradé HDR x2 saturait tout l'emoji en BLANC (retour\n\t// commu 15/09).\n\tfloat chroma = max(COLOR.r, max(COLOR.g, COLOR.b)) - min(COLOR.r, min(COLOR.g, COLOR.b));\n\tvec3 neon = mix(col_a, col_b, k);\n\tCOLOR.rgb = mix(neon, COLOR.rgb, step(0.06, chroma));\n}"






















func _fx_update_text(t: float) -> void :
	var active: Array = []
	for e in fx_texts:
		if t >= e.t0 and t <= e.t0 + e.dur:
			active.append(e)
			if active.size() >= 8:
				break
	if active.is_empty() and _fx_labels.is_empty():
		return
	if _fx_deco == null:
		_fx_deco = FxTextDeco.new()
		ui_layer.add_child(_fx_deco)
		ui_layer.move_child(_fx_deco, 0)
	while _fx_labels.size() < active.size():



		_fx_labels.append({"main": _fx_make_label()})
	_fx_deco.items.clear()
	var vs2: = get_viewport_rect().size
	for li in _fx_labels.size():
		var slot: Dictionary = _fx_labels[li]
		if li >= active.size():
			for l in slot.values():
				l.visible = false
			continue
		var e: Dictionary = active[li]
		var ev: Dictionary = e.ev
		var tu: float = (t - e.t0) / e.dur
		var txt: = String(ev.get("text", ""))
		var col_a: = Color.from_string(String(ev.get("color", "#e8e6ff")), Color.WHITE)
		var col_b: = Color.from_string(String(ev.get("color_b", 
			ev.get("color", "#b48cff"))), col_a)
		var anim: = String(ev.get("anim", "pop"))
		var alpha: = clampf(minf(tu / 0.08, (1.0 - tu) / 0.15), 0.0, 1.0)
		var p: = clampf(tu / 0.16, 0.0, 1.0)
		var scale: = 1.0
		var rot: = 0.0
		var off: = Vector2.ZERO
		var reveal: = 1.0
		var seed: float = float(e.t0) * 37.31
		match anim:
			"slam":
				var e_out: = 1.0 - pow(1.0 - p, 3.0)
				scale = lerpf(2.4, 1.0, e_out)
				rot = lerpf(-8.0, -3.0, e_out)
			"slide":
				var b: = _fx_back(p)
				off.x = (1.0 - b) * -430.0
				rot = -3.0
			"bounce":
				off.y = (1.0 - _fx_bounce(clampf(tu / 0.22, 0.0, 1.0))) * -270.0
				rot = -2.0
			"shake":
				var e_out2: = 1.0 - pow(1.0 - p, 3.0)
				scale = lerpf(1.8, 1.0, e_out2)
				var damp: = pow(1.0 - clampf(tu, 0.0, 1.0), 1.6)
				off += Vector2(sin(t * 61.0), cos(t * 53.0)) * 9.0 * damp
				rot = -3.0 + sin(t * 47.0) * 2.4 * damp
			"rise":

				var b2: = _fx_back(p)
				off.y = (1.0 - b2) * 150.0
				rot = lerpf(3.0, -3.0, b2)
			"zoom":

				var b3: = _fx_back(p)
				scale = lerpf(0.15, 1.0, b3)
				rot = lerpf(14.0, -3.0, b3)
			"spin":

				var b4: = _fx_back(p)
				scale = lerpf(0.3, 1.0, b4)
				rot = lerpf(-150.0, -3.0, b4)
			"flicker":

				rot = -3.0
				if tu < 0.3:
					var q: = tu / 0.3
					var gate: = _fx_hash(seed + floorf(tu * 46.0))
					if gate > q * q + 0.15:
						alpha *= 0.12
			"type":

				rot = -3.0
				reveal = clampf(tu / 0.35, 0.0, 1.0)
			"float":

				rot = -3.0 + sin(t * 2.1 + seed) * 2.0
				off.y = sin(t * 2.7 + seed) * 7.0
			_:
				var kk: = 1.0 - p
				scale = 1.0 + 0.5 * kk * kk * (3.0 - 2.0 * kk)
				rot = -4.0


		if fx_glitch > 0.1:
			off.x += (floorf(fposmod(t * 31.0 + float(li) * 5.7, 3.0)) - 1.0) * fx_glitch * 0.8
			off.y += (floorf(fposmod(t * 23.0 + float(li) * 3.1, 3.0)) - 1.0) * fx_glitch * 0.35
			if fposmod(t * 19.0 + float(li) * 2.3, 2.0) < 0.7:
				alpha *= 0.45
		var out_p: = clampf((tu - 0.86) / 0.14, 0.0, 1.0)
		scale *= 1.0 - 0.1 * out_p
		var side: = String(ev.get("side", ""))
		var ax: = float(ev.get("x", 0.5))
		if side == "left":
			ax = 0.15
		elif side == "right":
			ax = 0.85
		var ay: = float(ev.get("y", 0.3))
		var vis: = alpha > 0.01 and txt != ""
		for l in slot.values():
			l.visible = vis
		if not vis:
			continue
		var tsize: = int(ev.get("size", 64))


		var heat: = (0.75 + 0.25 * clampf(tu / 0.3, 0.0, 1.0))\
		* (1.0 + 0.05 * sin(t * 13.0 + seed))
		var pos: = Vector2.ZERO

		var passes: Array = [
			[slot.main, 1.0, 1.0, 2.1, 0.3], 
		]


		var fnt: Font = FxFonts.get_font(String(ev.get("font", FxFonts.DEFAULT)))
		for pdef in passes:
			var l2: Label = pdef[0]
			l2.text = txt
			if fnt != null and l2.get_theme_font("font") != fnt:
				l2.add_theme_font_override("font", fnt)
			l2.visible_ratio = reveal
			l2.add_theme_font_size_override("font_size", tsize)
			l2.reset_size()
			l2.pivot_offset = l2.size * 0.5
			var s2: float = scale * pdef[1]
			l2.scale = Vector2(s2, s2)
			l2.rotation_degrees = rot
			pos = Vector2(vs2.x * ax - l2.size.x * 0.5, 
				vs2.y * ay - l2.size.y * 0.5 - 16.0 * tu) + off
			l2.position = pos
			l2.modulate = Color(1, 1, 1, alpha * pdef[2])

			var hdr: float = pdef[3] * heat
			var wa: float = pdef[4]
			var ha: = col_a.lerp(Color.WHITE, wa)
			var hb: = col_b.lerp(Color.WHITE, wa)
			var mat: ShaderMaterial = l2.material
			mat.set_shader_parameter("col_a", Vector3(ha.r, ha.g, ha.b) * hdr)
			mat.set_shader_parameter("col_b", Vector3(hb.r, hb.g, hb.b) * hdr)
			mat.set_shader_parameter("x0", pos.x)
			mat.set_shader_parameter("x1", pos.x + l2.size.x * s2)
			mat.set_shader_parameter("scrw", vs2.x)

		_fx_deco.items.append({
			"rect": Rect2(pos, slot.main.size * scale), 
			"col_a": col_a, 
			"col_b": col_b, 
			"u": tu, 
			"seed": seed, 
			"ring": bool(ev.get("ring", false)), 
		})



func _update_glitch_overlay(t: float) -> void :
	var on: = fx_glitch > 0.5
	if _glitch_rect == null:
		if not on:
			return
		_glitch_layer = CanvasLayer.new()
		_glitch_layer.layer = 20
		add_child(_glitch_layer)
		_glitch_rect = ColorRect.new()
		_glitch_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_glitch_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sh: = Shader.new()
		sh.code = FX_GLITCH_SHADER
		var mat: = ShaderMaterial.new()
		mat.shader = sh
		_glitch_rect.material = mat
		_glitch_layer.add_child(_glitch_rect)
	_glitch_rect.visible = on
	if on:
		var mat2: ShaderMaterial = _glitch_rect.material
		mat2.set_shader_parameter("amt", clampf(fx_glitch / 34.0, 0.0, 1.3))
		mat2.set_shader_parameter("tt", t)





func _update_particles(t: float) -> void :
	var on: = not fx_particles.is_empty() and screen == Screen.PLAYING\
	and SettingsManager.vis_on("fx_burst")
	if _fx_particles_node == null:
		if not on:
			return
		_fx_particles_node = preload("res://scripts/fx_particles_node.gd").new()
		_fx_particles_node.main = self
		background.get_parent().add_child(_fx_particles_node)
	_fx_particles_node.visible = on
	if on:
		_fx_particles_node.song_t = t
		_fx_particles_node.queue_redraw()







func _film_off() -> void :
	fx_film = 0.0
	if _film_rect != null:
		_film_rect.visible = false




func _update_film_overlay(t: float) -> void :
	var on: = fx_film > 0.005 and screen == Screen.PLAYING\
	and not game_over and not track_done
	if _film_rect == null:
		if not on:
			return
		_film_layer = CanvasLayer.new()
		_film_layer.layer = 19
		add_child(_film_layer)
		_film_rect = ColorRect.new()
		_film_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_film_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sh: = Shader.new()
		sh.code = FxEval.FILM_SHADER
		var mat: = ShaderMaterial.new()
		mat.shader = sh
		_film_rect.material = mat
		_film_layer.add_child(_film_rect)
	_film_rect.visible = on
	if on:
		var mat2: ShaderMaterial = _film_rect.material
		mat2.set_shader_parameter("amt", fx_film)
		mat2.set_shader_parameter("tt", t)
		mat2.set_shader_parameter("grain", fx_film_grain)
		mat2.set_shader_parameter("sepia", fx_film_sepia)





func _fx_make_label() -> Label:
	if _fx_font == null:
		var fx_base: Font = load("res://fonts/Fredoka-Variable.ttf")
		if fx_base != null:
			_fx_font = _font_var(fx_base, {"wght": 560, "wdth": 104})
	var l: = Label.new()
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.z_index = 10
	if _fx_font != null:
		l.add_theme_font_override("font", _fx_font)
	elif font_display != null:
		l.add_theme_font_override("font", font_display)
	var sh: = Shader.new()
	sh.code = FX_TEXT_SHADER
	var mat: = ShaderMaterial.new()
	mat.shader = sh
	l.material = mat
	ui_layer.add_child(l)
	ui_layer.move_child(l, 1)
	return l







func _fx_update_images(t: float) -> void :
	var active: Array = []
	for e in fx_images:
		if t >= e.t0 and t <= e.t0 + e.dur:
			active.append(e)
			if active.size() >= 6:
				break
	if active.is_empty() and _fx_image_nodes.is_empty():
		return
	while _fx_image_nodes.size() < active.size():
		_fx_image_nodes.append(_fx_make_image())
	var vs2: = get_viewport_rect().size
	for i in _fx_image_nodes.size():
		var tr: TextureRect = _fx_image_nodes[i]
		if i >= active.size():
			tr.visible = false
			continue
		var e: Dictionary = active[i]
		var ev: Dictionary = e.ev

		var fr: Dictionary = FxImages.frame_of(ev, t - float(e.t0))
		var tex: = _fx_image_tex(FxImages.sheet_file(ev, int(fr.sheet)))
		if tex == null:
			tr.visible = false
			continue
		var tu: float = (t - e.t0) / e.dur
		var pose: = FxEval.image_pose(ev, tu, float(e.dur), t, float(e.t0) * 37.31)
		var alpha: float = pose.alpha
		var off: = Vector2(pose.off.x * vs2.x, pose.off.y * vs2.y)

		if fx_glitch > 0.1:
			off.x += (floorf(fposmod(t * 31.0 + float(i) * 5.7, 3.0)) - 1.0) * fx_glitch * 0.8
			off.y += (floorf(fposmod(t * 23.0 + float(i) * 3.1, 3.0)) - 1.0) * fx_glitch * 0.35
			if fposmod(t * 19.0 + float(i) * 2.3, 2.0) < 0.7:
				alpha *= 0.45
		if alpha <= 0.005:
			tr.visible = false
			continue
		tr.visible = true


		var info: Dictionary = FxImages.region_of(ev, tex, int(fr.idx))
		var atlas: AtlasTexture = tr.texture
		if atlas.atlas != tex:
			atlas.atlas = tex
		atlas.region = info.region
		var w: float = maxf(float(ev.get("width", 0.35)), 0.01) * vs2.x
		var ts: Vector2 = info.size
		var h: float = w * ts.y / maxf(ts.x, 1.0)
		tr.size = Vector2(w, h)
		tr.pivot_offset = Vector2(w, h) * 0.5
		tr.scale = Vector2.ONE * float(pose.scale)
		tr.rotation_degrees = float(pose.rot)
		tr.position = Vector2(vs2.x * float(ev.get("x", 0.5)) - w * 0.5, 
			vs2.y * float(ev.get("y", 0.5)) - h * 0.5) + off
		var tint: = Color.from_string(String(ev.get("color", "")), Color.WHITE)
		if bool(ev.get("glow", false)):
			tint = Color(tint.r * 1.7, tint.g * 1.7, tint.b * 1.7)
		tint.a = alpha
		tr.modulate = tint
		var mat: ShaderMaterial = tr.material
		mat.set_shader_parameter("amt", float(pose.get("glitch", 0.0)))
		mat.set_shader_parameter("tt", t)
		var full: = tex.get_size()
		var rg: Rect2 = info.region
		mat.set_shader_parameter("reg", Vector4(rg.position.x / full.x, rg.position.y / full.y, 
			rg.end.x / full.x, rg.end.y / full.y))


func _fx_make_image() -> TextureRect:
	var tr: = TextureRect.new()
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tr.z_index = 9
	tr.visible = false


	tr.texture = AtlasTexture.new()
	var sh: = Shader.new()
	sh.code = FX_IMAGE_SHADER
	var mat: = ShaderMaterial.new()
	mat.shader = sh
	tr.material = mat
	ui_layer.add_child(tr)
	ui_layer.move_child(tr, 1)
	return tr




func _fx_image_tex(file: String) -> Texture2D:
	if file == "":
		return null
	if _fx_image_cache.has(file):
		return _fx_image_cache[file]
	var tex: = FxImages.load_texture(FxImages.dir_for(tuning.current_track), file)
	if tex == null:
		push_warning("fx image introuvable : %s" % file)
	_fx_image_cache[file] = tex
	return tex



static func _fx_hash(n: float) -> float:
	return fposmod(sin(n * 12.9898) * 43758.5453, 1.0)


static func _fx_back(u: float) -> float:
	var c: = 1.70158
	var v: = u - 1.0
	return 1.0 + v * v * ((c + 1.0) * v + c)


static func _fx_bounce(u: float) -> float:
	var n: = 7.5625
	var d: = 2.75
	if u < 1.0 / d:
		return n * u * u
	elif u < 2.0 / d:
		u -= 1.5 / d
		return n * u * u + 0.75
	elif u < 2.5 / d:
		u -= 2.25 / d
		return n * u * u + 0.9375
	u -= 2.625 / d
	return n * u * u + 0.984375






func _update_bg_video() -> void :
	var path: String = track_videos.get(tuning.current_track, "")
	var want: = path != "" and screen == Screen.PLAYING and not _pre_roll\
	and not game_over and not track_done
	if not want:
		if bg_video != null and bg_video.is_playing():
			bg_video.stop()
		return
	if bg_video == null:
		bg_video = VideoStreamPlayer.new()


		bg_video.modulate = Color(1, 1, 1, 0.0)
		add_child(bg_video)
	if _bg_video_path != path:
		bg_video.stop()


		if path.begins_with("res://") and ResourceLoader.exists(path):
			bg_video.stream = load(path)
		else:
			var vst: = VideoStreamTheora.new()
			vst.file = path
			bg_video.stream = vst
		_bg_video_path = path
	bg_video.paused = game_paused
	if game_paused:
		return
	var t: = conductor.get_song_time()
	if bg_video.is_playing() and t < _bg_video_last_t - 0.25:
		bg_video.stop()
	_bg_video_last_t = t


	var start: = float(VIDEO_BG_OFFSET.get(tuning.current_track, 0.0))
	if MapLibrary.is_user_map(tuning.current_track):
		start = float(MapLibrary.meta_of(tuning.current_track).get("video_offset", 0.0))
	if not bg_video.is_playing() and t >= start:
		bg_video.play()




func bg_video_texture() -> Texture2D:
	if bg_video != null and bg_video.is_playing():
		return bg_video.get_video_texture()
	return null


func _spawn_note(nd: Dictionary, chart_idx: = -1) -> void :
	var node: Node2D
	if nd.type == "click":
		node = _acquire_click()
		node.main = self
		node.set_order(int(nd.get("order", 0)))
		node.time = nd.time
		node.speed = chart_velocity * nd.get("v", 1.0) * _kiai_vmult(nd.time)\
		* SettingsManager.scroll_speed
		node.position = _tame_click_position(
			Vector2(nd.x, nd.y) if nd.has("x") else _click_position_for(nd))

		var nxt: = _next_aim_after(nd, chart_idx)
		if nxt != Vector2.ZERO:
			node.next_aim = nxt - node.position
	elif nd.type == "clickx":

		var cm: Node2D = preload("res://scripts/click_multi.gd").new()
		cm.speed = chart_velocity * nd.get("v", 1.0) * _kiai_vmult(nd.time)\
		* SettingsManager.scroll_speed
		cm.setup(nd.time, _tame_click_position(
			Vector2(nd.x, nd.y) if nd.has("x") else _click_position_for(nd)), 
			nd.get("extra", []))
		cm.font = font_bold
		node = cm
	elif nd.type == "beam":

		var beam: Node2D = preload("res://scripts/beam.gd").new()
		beam.time = nd.time
		beam.duration = nd.duration
		beam.lane = nd.lane
		beam.path = nd.path
		beam.main = self
		beam.speed = chart_velocity * nd.get("v", 1.0) * _kiai_vmult(nd.time)\
		* SettingsManager.scroll_speed
		beam.next_tick = nd.time + BEAM_TICK
		node = beam
	elif nd.type == "sliderg":
		var sg: Node2D = _acquire_slider()
		sg.time = nd.time
		sg.duration = nd.duration
		for p in nd.points:
			sg.points.append([float(p[0]), Vector2(float(p[1]), float(p[2]))])
		sg.repeats = nd.get("repeats", [])
		sg.speed = chart_velocity * nd.get("v", 1.0) * _kiai_vmult(nd.time)\
		* SettingsManager.scroll_speed
		sg.set_order(int(nd.get("order", 0)))
		sg.main = self
		sg.attach_body(slider_bodies_root)
		node = sg
	elif nd.type == "sliderm":
		var sm: Node2D = preload("res://scripts/slider_mania.gd").new()
		sm.time = nd.time
		sm.duration = nd.duration
		sm.lane = nd.lane
		sm.main = self



		sm.speed = chart_velocity * nd.get("v", 1.0) * _kiai_vmult(nd.time)\
		* SettingsManager.scroll_speed
		node = sm
	else:
		node = NOTE_SCENE.instantiate()
		node.time = nd.time
		node.lane = nd.lane
		node.type = nd.type
		node.speed = chart_velocity * nd.get("v", 1.0) * _kiai_vmult(nd.time)\
		* SettingsManager.scroll_speed
		node.position.x = lane_x(nd.lane)
		if nd.type == "dodge":
			node.stack = int(nd.get("stack", 1))
			node.danger = float(node.stack) * tuning.hp_miss_dodge\
			/ maxf(tuning.hp_max, 1.0)
	node.glow_tex = game_glow()
	notes_root.add_child(node)




	var idx: = 0
	for ch in notes_root.get_children():

		if ch == node or not is_instance_valid(ch) or not ("time" in ch):
			continue
		if float(ch.time) > float(nd.time):
			idx = ch.get_index() + 1
		else:
			break
	notes_root.move_child(node, mini(idx, notes_root.get_child_count() - 1))
	live_notes.append(node)





const DODGE_STACK_S: = 0.04











func _merge_dodge_stacks() -> void :
	var merged: Array = []
	var n: = chart_notes.size()
	var i: = 0
	while i < n:
		var a: Dictionary = chart_notes[i]
		if String(a.type) != "dodge" or a.has("stack"):
			merged.append(a)
			i += 1
			continue
		var count: = 1
		var j: = i + 1
		while j < n and float(chart_notes[j].time) - float(a.time) <= DODGE_STACK_S:
			var b: Dictionary = chart_notes[j]
			if String(b.type) == "dodge" and int(b.lane) == int(a.lane)\
			and not b.has("stack"):
				count += 1
				b["stack"] = 0
			j += 1
		a["stack"] = count
		merged.append(a)
		i += 1
	chart_notes = merged.filter( func(nd: Dictionary) -> bool:
		return int(nd.get("stack", 1)) > 0)



func _stack_of(n: Node2D) -> int:
	var v = n.get("stack")
	return maxi(int(v), 1) if v != null else 1












const AIM_LINK_MAX_GAP: = 1.6





func _acquire_click() -> Node2D:
	if _click_pool.is_empty():
		return CLICK_TARGET_SCENE.instantiate()
	return _click_pool.pop_back()


func _acquire_slider() -> Node2D:
	if _slider_pool.is_empty():
		return preload("res://scripts/slider_guide.gd").new()
	return _slider_pool.pop_back()



func _release_note(n: Node, erase: = true) -> void :
	if erase:
		live_notes.erase(n)
	if not is_instance_valid(n):
		return
	var parent: = n.get_parent()
	if n is ClickTarget:
		n.reset()
		if parent != null:
			parent.remove_child(n)
		if _click_pool.size() < POOL_MAX:
			_click_pool.append(n)
		else:
			n.queue_free()
	elif n is SliderGuide:
		n.reset()
		if parent != null:
			parent.remove_child(n)
		if _slider_pool.size() < POOL_MAX:
			_slider_pool.append(n)
		else:
			n.queue_free()
	else:
		n.queue_free()




func _exit_tree() -> void :
	for n in _click_pool:
		if is_instance_valid(n):
			n.free()
	for n in _slider_pool:
		if is_instance_valid(n):
			n.free()
	_click_pool.clear()
	_slider_pool.clear()
	for n in _anim_pool:
		if is_instance_valid(n):
			n.free()
	_anim_pool.clear()




func _skin_fx(event: String, pos: Vector2) -> void :
	if not SettingsManager.vis_on("fx_skin_anims"):
		return
	var a: Dictionary = Skins.anim(event)
	if a.is_empty() or _anims_alive >= tuning.max_fx_alive:
		return
	var n: SkinAnim = _anim_pool.pop_back() if not _anim_pool.is_empty() else SkinAnim.new()
	n.main = self
	fx_root.add_child(n)
	n.setup(a, pos, SettingsManager.note_fx_intensity)
	_anims_alive += 1


func _release_anim(n: Node) -> void :
	_anims_alive = maxi(_anims_alive - 1, 0)
	if not is_instance_valid(n):
		return
	if n.get_parent() != null:
		n.get_parent().remove_child(n)
	if _anim_pool.size() < 32:
		_anim_pool.append(n)
	else:
		n.queue_free()




func _assign_order_numbers() -> void :
	var num: = 0
	var last_end: = -1000000000.0
	for nd in chart_notes:
		var ty: = String(nd.type)
		if ty != "click" and ty != "clickx" and ty != "sliderg":
			continue
		if float(nd.time) - last_end > tuning.order_reset_gap or num >= 99:
			num = 0
		num += 1
		nd["order"] = num
		last_end = float(nd.time) + float(nd.get("duration", 0.0))

func _next_aim_after(nd: Dictionary, chart_idx: int) -> Vector2:



	if chart_idx < 0 or chart_idx + 1 >= chart_notes.size():
		return Vector2.ZERO
	var n: Dictionary = chart_notes[chart_idx + 1]
	if float(n.time) - float(nd.time) > AIM_LINK_MAX_GAP:
		return Vector2.ZERO
	if String(n.type) != "click" and String(n.type) != "clickx":
		return Vector2.ZERO
	return _tame_click_position(
		Vector2(n.x, n.y) if n.has("x") else _click_position_for(n))




func _click_position_for(nd: Dictionary) -> Vector2:
	var rng: = RandomNumberGenerator.new()
	rng.seed = int(round(nd.time * 1000.0)) * 7919 + nd.lane
	var size: = get_viewport_rect().size
	return Vector2(
		rng.randf_range(180.0, size.x - 180.0), 
		rng.randf_range(140.0, tuning.hit_y - 160.0), 
	)






func _tame_click_position(p: Vector2) -> Vector2:


	if tutorial_active:
		return p



	if MapLibrary.is_user_map(tuning.current_track):
		return p
	var k: = 1.0
	match tuning.current_diff:
		"easy":
			k = 0.55
		"normal":
			k = 0.78
	if k >= 1.0:
		return p
	var vs: = get_viewport_rect().size
	var anchor: = Vector2(vs.x * 0.5, tuning.hit_y - 170.0)
	var q: = anchor + (p - anchor) * k
	q.y = clampf(q.y, 130.0, tuning.hit_y - 140.0)
	q.x = clampf(q.x, 170.0, vs.x - 170.0)
	return q






const SYNTH_DEVICE: = 4242






func _input(event: InputEvent) -> void :
	if event.device == SYNTH_DEVICE:
		return
	if event is InputEventMouseMotion:
		_event_pos = event.position
		_event_time = Time.get_ticks_msec()
		_event_kind = "mouse/pen"
		_event_count += 1
	elif event is InputEventScreenDrag:
		_event_pos = event.position
		_event_time = Time.get_ticks_msec()
		_event_kind = "touch/pen"
		_event_count += 1
	elif event is InputEventScreenTouch and event.pressed:
		_event_pos = event.position
		_event_time = Time.get_ticks_msec()
		_event_kind = "touch (tap)"
		_event_count += 1




	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_mouse_aim = (_mouse_aim + event.relative * SettingsManager.mouse_sens)\
		.clamp(Vector2.ZERO, get_viewport_rect().size)






	if event is InputEventMouseButton and event.pressed\
	and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]\
	and _gameplay_click_allowed():
		_on_hit_pressed("mb_left" if event.button_index == MOUSE_BUTTON_LEFT
			else "mb_right")




	if event is InputEventMouseButton or event is InputEventMouseMotion:
		var e: = event.duplicate() as InputEventMouse
		e.device = SYNTH_DEVICE
		e.position = aim_position()
		e.global_position = e.position
		get_viewport().set_input_as_handled()
		get_viewport().push_input(e, true)


func _raw_pointer() -> Vector2:









	var p: Vector2 = get_viewport().get_screen_transform().affine_inverse()\
	* Vector2(DisplayServer.mouse_get_position() - get_window().position)



	var vs: = get_viewport_rect().size
	var in_bounds: = p.x > -64.0 and p.y > -64.0\
	and p.x < vs.x + 64.0 and p.y < vs.y + 64.0
	if in_bounds and p.distance_to(_poll_last) > 0.5:
		_poll_last = p
		_poll_time = Time.get_ticks_msec()
	return _poll_last if _poll_time >= _event_time else _event_pos












func aim_position() -> Vector2:
	var vs: = get_viewport_rect().size
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		return _mouse_aim
	var raw: = _raw_pointer()
	if screen == Screen.PLAYING and SettingsManager.input_device == "TABLET":
		var s: = Vector2(1.0 / SettingsManager.tablet_area_w, 
			1.0 / SettingsManager.tablet_area_h)
		return (vs * 0.5 + (raw - vs * 0.5) * s).clamp(Vector2.ZERO, vs)
	return raw.clamp(Vector2.ZERO, vs)




func aim_is_mapped() -> bool:
	if screen != Screen.PLAYING or SettingsManager.input_device == "MOUSE":
		return false
	return SettingsManager.tablet_area_w < 0.999 or SettingsManager.tablet_area_h < 0.999





func _poll_hold_r(delta: float) -> void :
	var active: = screen == Screen.PLAYING and not game_paused\
	and not game_over and not track_done and not _transitioning\
	and not _pre_roll and playtest_from < 0.0 and not tutorial_active\
	and Input.is_action_pressed("retry")
	if not active:
		_r_hold = 0.0
		return
	_r_hold += delta

	var now: = Time.get_ticks_msec() / 1000.0
	if _r_hold >= 0.12 and now - _r_hint_at > 0.8:
		_r_hint_at = now
		_float_text("hold %s to restart…" % SettingsManager.key_label(SettingsManager.bind_of("retry")), 
			Vector2(get_viewport_rect().size.x * 0.5, 
				get_viewport_rect().size.y - 150.0), 
			Color(0.7, 0.9, 1.0), 22, false)
	if _r_hold >= 0.6:
		_r_hold = 0.0
		Telemetry.map_retried()
		_restart_game(0.0)













func _update_mouse_mode() -> void :
	var want: = Input.MOUSE_MODE_CONFINED_HIDDEN



	if SettingsManager.display_mode == "WINDOWED":
		want = Input.MOUSE_MODE_HIDDEN

	if gate_root != null and is_instance_valid(gate_root):
		want = Input.MOUSE_MODE_VISIBLE
	elif screen == Screen.PLAYING:



		want = Input.MOUSE_MODE_CAPTURED if SettingsManager.input_device == "MOUSE"\
		else Input.MOUSE_MODE_CONFINED_HIDDEN
	if Input.mouse_mode == want:
		return
	if want == Input.MOUSE_MODE_CAPTURED:
		_mouse_aim = _raw_pointer()
	elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		get_viewport().warp_mouse(_mouse_aim)
	Input.mouse_mode = want





func _update_lane_from_mouse() -> void :


	var mx: = world.to_local(aim_position()).x if world.rotation != 0.0\
	else aim_position().x
	var best: = -1
	var best_d: = INF
	for i in 3:


		if fx_gone[i] >= 0.5:
			continue
		var d: float = absf(mx - lane_x(i))
		if d < best_d:
			best_d = d
			best = i
	if best < 0:
		best = player.lane
	player.set_lane(best)







func _run_auto(t: float, delta: float) -> void :

	var next_lane_note = null
	var next_click = null
	var held_beam = null
	var held_slider = null
	var next_sliderg = null
	for n in live_notes:
		if not is_instance_valid(n) or n.judged:
			continue
		if n.type == "click" or n.type == "clickx":


			if next_click == null or n.time < next_click.time:
				next_click = n
		elif n.type == "beam" and n.caught:
			held_beam = n
		elif n.type == "sliderg" or n.type == "sliderm":
			if n.caught:
				held_slider = n
			elif n.type == "sliderg":
				if next_sliderg == null or n.time < next_sliderg.time:
					next_sliderg = n

			elif _auto_lane_note_before(n, next_lane_note):
				next_lane_note = n
		elif _auto_lane_note_before(n, next_lane_note):
			next_lane_note = n








	var target: = Vector2(player.position.x, tuning.hit_y - 180.0)
	var deadline: = 0.35
	if next_lane_note != null:
		if next_lane_note.type == "parry" or next_lane_note.type == "sliderm":
			target.x = lane_x(next_lane_note.lane)
		else:




			var unsafe: = {}
			var unsafe_soon: = {}
			for m in live_notes:
				if not is_instance_valid(m) or m.judged or m.type != "dodge":
					continue
				if absf(m.time - next_lane_note.time) <= 0.08:
					unsafe[m.lane] = true
				if m.time >= next_lane_note.time - 0.08\
				and m.time <= next_lane_note.time + 0.25:
					unsafe_soon[m.lane] = true
			if unsafe.has(player.lane):
				target.x = lane_x(_auto_flee_lane(next_lane_note, 
					unsafe_soon if unsafe_soon.size() < 3 else unsafe))
			else:
				target.x = lane_x(player.lane)
		deadline = next_lane_note.time - t - 0.05
	if next_click != null:



		var flick_time: float = auto_cursor.distance_to(next_click.position)\
		/ tuning.auto_cursor_speed + 0.06
		var lane_duty_first: bool = next_lane_note != null\
		and next_lane_note.time < next_click.time
		if not lane_duty_first or next_click.time - t <= flick_time:
			target = next_click.position
			deadline = next_click.time - t - 0.03


	if held_beam != null:
		target.x = lane_x(held_beam.lane_at(t))
		deadline = 0.08





	if next_sliderg != null and (next_click == null
			or next_click.time >= next_sliderg.time)\
			and (next_lane_note == null
			or next_lane_note.time >= next_sliderg.time):
		var flick2: float = auto_cursor.distance_to(next_sliderg.pos_at(0.0))\
		/ tuning.auto_cursor_speed + 0.06
		if next_sliderg.time - t <= flick2 + 0.25:
			target = next_sliderg.pos_at(0.0)
			deadline = next_sliderg.time - t - 0.03


	if held_slider != null:
		if held_slider.type == "sliderg":
			target = held_slider.pos_at_time(t)
		else:
			target.x = lane_x(held_slider.lane)
		deadline = 0.05


	var k: = clampf(4.0 / maxf(deadline, 0.03), 3.0, 80.0)
	var step: = auto_cursor.lerp(target, 1.0 - exp( - k * delta)) - auto_cursor
	var max_step: = tuning.auto_cursor_speed * delta
	if step.length() > max_step:
		step = step.normalized() * max_step
	auto_cursor += step


	var best: = 0
	var best_d: = INF
	for i in 3:
		var d: float = absf(auto_cursor.x - lane_x(i))
		if d < best_d:
			best_d = d
			best = i
	player.set_lane(best)




	for n in live_notes:
		if not is_instance_valid(n) or n.judged:
			continue
		if t < n.time - 0.003:
			continue
		match n.type:
			"parry":
				if player.lane == n.lane:
					if absf(t - n.time) <= tuning.perfect_s():
						_perfect_parry(n)
					else:
						_good_parry(n)
			"beam":
				if not n.caught and player.lane == n.lane:
					_beam_catch(n, absf(t - n.time) <= tuning.perfect_s())
			"sliderg":
				if not n.caught and t < n.time + n.duration:
					var ref: Vector2 = n.pos_at(0.0) if t <= n.time\
					else n.pos_at_time(t)
					if auto_cursor.distance_to(ref) <= tuning.click_hit_radius + 8.0:
						_slider_take(n, t, "auto")
			"sliderm":
				if not n.caught and t < n.time + n.duration\
				and player.lane == n.lane:
					_slider_take(n, t, "auto")
			"click":
				if auto_cursor.distance_to(n.position) <= tuning.click_hit_radius + 8.0:
					_click_hit(n, absf(t - n.time) <= tuning.perfect_s())
			"clickx":
				if auto_cursor.distance_to(n.position) <= tuning.click_hit_radius + 8.0:
					_clickx_step(n, absf(t - n.time) <= tuning.perfect_s())








func _auto_lane_note_before(a: Node2D, cur) -> bool:
	if cur == null or a.time < cur.time:
		return true
	return a.time == cur.time and cur.type == "dodge" and a.type != "dodge"





func _auto_flee_lane(dodge: Node2D, unsafe: Dictionary) -> int:
	for n in live_notes:
		if not is_instance_valid(n) or n.judged or n.type != "parry":
			continue





		if n.time >= dodge.time and not unsafe.has(n.lane):
			return n.lane
	var best: = player.lane
	var best_d: = INF
	for i in 3:
		if unsafe.has(i) or fx_gone[i] >= 0.5:
			continue
		var d: = absf(lane_x(i) - player.position.x)
		if d < best_d:
			best_d = d
			best = i
	return best


func _toggle_auto(on: bool) -> void :
	auto_mode = on
	if auto_button != null:
		auto_button.set_pressed_no_signal(on)
	Mods.set_on("auto", on)
	Telemetry.note_flags(auto_mode, invincible)
	if on:
		run_assisted = true
		auto_cursor = aim_position()









func _run_autoclic(t: float) -> void :
	_try_slider_catch("autoclic")
	var aim: = aim_position()
	var reach: float = tuning.click_hit_radius + 8.0
	for n in live_notes:
		if not is_instance_valid(n) or n.judged or t < n.time:
			continue


		var on_lane: bool = Mods.is_mania() or n.lane == player.lane
		match n.type:
			"parry":
				if on_lane:
					_perfect_parry(n)
			"beam":
				if on_lane and not n.caught:
					_beam_catch(n, true)
			"click":
				if aim.distance_to(n.global_position) <= reach:
					_click_hit(n, true)
			"clickx":
				if aim.distance_to(n.global_position) <= reach:
					_clickx_step(n, true)








func _open_editor(draft: Dictionary = {}) -> void :



	if map_select != null:
		map_select.flush_chart()
		map_select.flush_heavy()




	var review_mode: = false
	if draft.is_empty() and MapLibrary.is_user_map(tuning.current_track)\
	and MapLibrary.status_of(tuning.current_track) == MapLibrary.STATUS_DOWNLOADED:
		if not Backend.is_reviewer():
			_menu_toast("DOWNLOADED MAP  ·  only its mapper can edit it", COL_GOLD)
			return
		review_mode = true
		var by: = String(MapLibrary.meta_of(tuning.current_track).get("creator", ""))
		_menu_toast("REVIEW MODE  ·  %s's map opens read-only" % (by if by != "" else "this"), COL_GOLD)




	if draft.is_empty() and MapLibrary.is_user_map(tuning.current_track)\
	and MapLibrary.status_of(tuning.current_track) == MapLibrary.STATUS_PUBLISHED:
		var wip: = MapLibrary.fork_wip(tuning.current_track)
		if wip == "":
			_menu_toast("COULD NOT CREATE THE WORKING COPY", COL_RED)
			return
		_scan_charts()
		tuning.apply_track(wip, tuning.current_diff)
		_load_chart()
		_menu_toast("EDITING A WORKING COPY  ·  the published version stays as is", COL_GOLD)
	conductor.stop()
	menu_root.visible = false
	screen = Screen.EDITOR


	Telemetry.set_in_editor(true)

	editor = load("res://scripts/editor.gd").new()
	editor.main = self
	editor.read_only = review_mode
	if draft.is_empty():
		editor.chart_path = tuning.chart_path
		editor.map_track = tuning.current_track
		editor.diff_key = tuning.current_diff
		editor.map_meta = MapLibrary.meta_of(tuning.current_track)
	else:
		editor.draft = draft
		editor.map_meta = draft.meta
		editor.diff_key = String(draft.diff)
	ui_layer.add_child(editor)

	ui_layer.move_child(editor, ui_layer.get_child_count() - 2)




func _exit_editor() -> void :


	var landed: = ""
	var landed_diff: = ""
	if editor != null:
		landed = String(editor.map_track)
		landed_diff = String(editor.diff_key)
		editor.queue_free()
		editor = null
	MapLibrary.rescan()
	_scan_charts()
	if landed != "" and MapLibrary.has(landed):
		tuning.apply_track(landed, landed_diff)
	elif not MapLibrary.has(tuning.current_track):


		tuning.apply_track(String(MapLibrary.tracks().keys()[0]))
	else:
		tuning.apply_track(tuning.current_track, tuning.current_diff)
	_load_chart()




	if landed != "" and MapLibrary.is_user_map(landed) and map_select != null:
		map_select.source = map_select.Source.COMMUNITY
		map_select._quick = "YOUR MAPS"
		map_select._style_quick()
	screen = Screen.SELECT
	menu_root.visible = true
	Telemetry.set_in_editor(false)
	_open_menu(Screen.SELECT)




func _playtest_from(tt: float) -> void :





	var ed_chart: = String(editor.chart_path)
	if editor.is_draft() or ed_chart == "" or not FileAccess.file_exists(ed_chart):
		editor.flash("NOTHING TO TEST YET — save the map (with an audio) first")
		return
	if MapLibrary.is_user_map(String(editor.map_track))\
	and MapLibrary.audio_path(String(editor.map_track)) == "":
		editor.flash("NOTHING TO TEST YET — add an audio to the map first")
		return
	tuning.apply_track(String(editor.map_track), String(editor.diff_key))
	tuning.chart_path = ed_chart






	if _editor_mods_backup == null:
		_editor_mods_backup = SettingsManager.mods.duplicate()
		_editor_mode_backup = Mods.mode_key()
	Mods.clear()
	Mods.set_mode("STANDARD")
	Mods.set_on("auto", true)
	_load_chart()
	if chart_error != "":
		_restore_editor_mods()
		editor.flash("CAN'T TEST — " + chart_error.to_upper())
		return
	editor.visible = false


	editor.set_process_unhandled_input(false)
	editor.set_process(false)
	screen = Screen.PLAYING
	playtest_from = tt
	world.visible = true
	hud_root.visible = true

	conductor.volume_db = music_db()
	if _lp_tw:
		_lp_tw.kill()
	music_lp.cutoff_hz = LP_OPEN



	_pre_roll = false
	_transitioning = false
	start_game(tt)



var _editor_mods_backup = null

var _editor_mode_backup: = ""

func _restore_editor_mods() -> void :
	if _editor_mods_backup == null:
		return
	var back: Array = _editor_mods_backup
	_editor_mods_backup = null
	if auto_mode:
		_toggle_auto(false)
	if _editor_mode_backup != "":
		Mods.set_mode(_editor_mode_backup)
		_editor_mode_backup = ""
	SettingsManager.set_mods(back)



func _return_to_editor() -> void :
	_restore_editor_mods()
	_pre_roll = false
	_transitioning = false
	conductor.stop()
	for n in live_notes:
		if is_instance_valid(n):
			_release_note(n, false)
	live_notes.clear()
	end_panel.visible = false
	hud_root.visible = false
	fever = 0.0
	on_fire = false
	player.fever = 0.0



	for slot in _fx_labels:
		for l in slot.values():
			l.visible = false
	for tr in _fx_image_nodes:
		tr.visible = false
	if _fx_deco != null:
		_fx_deco.items.clear()
		_fx_deco.queue_redraw()
	if _glitch_rect != null:
		_glitch_rect.visible = false
	_film_off()
	if _break_node != null:
		_break_node.visible = false
	world.visible = false
	screen = Screen.EDITOR
	editor.visible = true
	editor.set_process_unhandled_input(true)
	editor.set_process(true)
	editor._seek_to(playtest_from)
	playtest_from = -1.0







func _maybe_open_onboarding() -> void :
	if SettingsManager.onboarding_done or screen != Screen.HOME:
		return
	if onboarding_ui != null and not onboarding_ui.visible:
		onboarding_ui.open()





func start_tutorial() -> void :
	if screen == Screen.PLAYING or _transitioning or tutorial_active:
		return

	if onboarding_ui != null and onboarding_ui.visible:
		return


	SettingsManager.set_game_mode("STANDARD")
	SettingsManager.set_mods([])
	tutorial_active = true
	if lb_overlay != null:
		lb_overlay.visible = false
	if account_panel != null:
		account_panel.visible = false
	if stats_panel != null:
		stats_panel.visible = false
	conductor.stop()
	chart_notes = []
	screen = Screen.PLAYING
	menu_root.visible = false
	world.visible = true
	world.modulate = Color.WHITE
	hud_root.visible = true
	end_panel.visible = false
	if pause_root != null:
		pause_root.visible = false

	conductor.volume_db = music_db()
	if _lp_tw:
		_lp_tw.kill()
	music_lp.cutoff_hz = LP_OPEN

	sfx.play_ui("whoosh")
	tutorial_ui.begin()



func end_tutorial() -> void :
	tutorial_active = false
	conductor.stop()
	for n in live_notes:
		if is_instance_valid(n):
			_release_note(n, false)
	live_notes.clear()
	game_over = false
	track_done = false
	fever = 0.0
	on_fire = false
	player.fever = 0.0
	_load_chart()
	_open_menu(Screen.HOME)











const GAUNTLET_TRACK: = "BOOKMAKER"
const GAUNTLET_CHART: = "res://charts/bookmaker_gauntlet.json"


const GAUNTLET_FALLBACK: = "RAVENATIC"

var gauntlet: = false



var _gauntlet_giggle: = -1.0


func start_gauntlet() -> void :
	_leave_tutorial_state()
	if _is_locked(GAUNTLET_TRACK) or not MapLibrary.tracks().has(GAUNTLET_TRACK)\
	or not ResourceLoader.exists(GAUNTLET_CHART):
		end_tutorial()
		return
	gauntlet = true
	screen = Screen.SELECT
	_launch(GAUNTLET_TRACK, GAUNTLET_CHART)





func _gauntlet_verdict(survived: bool) -> void :
	conductor.stop()
	for n in live_notes:
		if is_instance_valid(n):
			_release_note(n, false)
	live_notes.clear()
	if survived:

		_mascot_pose("cyan", [&"surprised", &"scared", &"blank"])
		_mascot_pose("violet", [&"stunned", &"scared", &"indi"])
		_mascot_pose("yellow", [&"intrigued", &"panic", &"annoyed"])
		sfx.play_ui("impact")
	else:

		_mascot_pose("yellow", [&"lmfao", &"laugh", &"smile"])
		_mascot_pose("violet", [&"lmfao", &"laugh", &"malice"])
		_mascot_pose("cyan", [&"chipie", &"happy", &"smile"])
		_gauntlet_giggle = 0.0



	for i in 3:
		var mm: Mascot = lane_mascots.get_mascot(i)
		if mm != null:
			mm.scale = Vector2.ONE * 1.7
		lane_mascots.mascot_look(i, "mouse")
	tutorial_ui.show_verdict(survived)



func _mascots_unpose() -> void :
	for i in 3:
		var m: Mascot = lane_mascots.get_mascot(i)
		if m != null:
			m.scale = Vector2.ONE
			m.play_reaction(&"neutral", 0.01, true)





func _update_gauntlet_giggle(delta: float) -> void :
	if _gauntlet_giggle < 0.0:
		return
	_gauntlet_giggle -= delta
	if _gauntlet_giggle > 0.0:
		return
	_gauntlet_giggle = 0.16
	for i in 3:
		var m: Mascot = lane_mascots.get_mascot(i)
		if m != null:
			m.beat_kick(0.45 + 0.3 * float((i + Engine.get_frames_drawn() / 10) % 2))







func _mascot_pose(who, prefs: Array) -> void :
	var m: Mascot = lane_mascots.get_mascot(who)
	if m == null:
		return
	for id in prefs:
		if m.has_expression(id):
			m.play_reaction(id, 600.0, true)
			return



func gauntlet_exit(track: = "") -> void :
	gauntlet = false
	_gauntlet_giggle = -1.0
	_mascots_unpose()
	game_over = false
	track_done = false
	tutorial_ui.visible = false
	if track != "" and MapLibrary.tracks().has(track) and not _is_locked(track):
		screen = Screen.SELECT
		_launch(track)
		return
	lane_mascots.reset_all()
	_load_chart()
	_open_menu(Screen.HOME)



func gauntlet_retry() -> void :
	_gauntlet_giggle = -1.0
	_mascots_unpose()
	tutorial_ui.visible = false
	game_over = false
	track_done = false
	lane_mascots.reset_all()
	start_game()




func _leave_tutorial_state() -> void :
	tutorial_active = false
	conductor.stop()
	for n in live_notes:
		if is_instance_valid(n):
			_release_note(n, false)
	live_notes.clear()
	game_over = false
	track_done = false
	fever = 0.0
	on_fire = false
	player.fever = 0.0
	if tutorial_ui != null:
		tutorial_ui.visible = false







func end_tutorial_into(track: String) -> void :
	_leave_tutorial_state()


	if _is_locked(track) or not MapLibrary.tracks().has(track):
		end_tutorial()
		return
	screen = Screen.SELECT
	_launch(track)



func _tut(kind: String, ok: bool) -> void :
	if tutorial_active and tutorial_ui != null:
		tutorial_ui.on_judged(kind, ok)



func _judge_expired(t: float) -> void :
	for n in live_notes:


		if not is_instance_valid(n) or n.judged:
			continue
		match n.type:
			"dodge":

				if t >= n.time:
					if player.lane == n.lane:





						_miss(n)
					else:
						_dodge_success(n)
			"clickx":





				if t > n.time + tuning.last_s():
					if n.remaining() > 1:
						_clickx_miss_step(n)
					else:
						_miss(n)
			"parry", "click":
				if t > n.time + tuning.last_s():
					_miss(n)




func _unhandled_input(event: InputEvent) -> void :


	if settings_ui != null and settings_ui.visible:
		return

	if onboarding_ui != null and onboarding_ui.visible:
		return

	if gate_root != null and is_instance_valid(gate_root) and gate_root.visible:
		return


	if menu_intro != null and menu_intro.is_running():
		if (event is InputEventKey and event.pressed and not event.echo)\
		or (event is InputEventMouseButton and event.pressed):
			menu_intro.skip()
			return

	if event is InputEventKey and event.pressed\
	and event.physical_keycode == KEY_ESCAPE:
		if account_panel != null and account_panel.visible:
			account_panel.visible = false
			sfx.play_ui("back")
			return
		if lb_overlay != null and lb_overlay.visible:
			lb_overlay.visible = false
			sfx.play_ui("back")
			return
	if event is InputEventKey and event.pressed and not event.echo:

		if event.physical_keycode == KEY_ESCAPE:
			if _transitioning:
				return
			if screen == Screen.PLAYING:
				if tutorial_active:
					tutorial_ui.on_escape()
				elif gauntlet and (game_over or track_done):
					gauntlet_exit()
				elif playtest_from >= 0.0:
					_return_to_editor()
				elif game_over or track_done:
					_exit_to_select()
				else:
					_toggle_pause( not game_paused)
			elif screen == Screen.SELECT:



				if map_select != null and map_select.close_popovers():
					return
				sfx.play_ui("back")
				_open_menu(Screen.HOME)
			elif screen == Screen.HOME and orbit_menu != null\
			and orbit_menu.is_open:

				sfx.play_ui("back")
				_toggle_orbit()
			return

		if screen == Screen.HOME and not _transitioning\
		and event.physical_keycode in [KEY_ENTER, KEY_KP_ENTER]:
			if orbit_menu != null and not orbit_menu.is_open:
				_toggle_orbit()
			else:
				sfx.play_ui("menu_play")
				_go_select_animated()
			return




		if screen == Screen.SELECT and not _transitioning:
			if map_select != null and map_select.handle_key(event):
				return
			if event.is_action_pressed("open_editor"):




				if (MapLibrary.is_user_map(tuning.current_track)
						and (MapLibrary.status_of(tuning.current_track)
							!= MapLibrary.STATUS_DOWNLOADED or Backend.is_reviewer()))\
							or OS.has_feature("editor"):
					sfx.play_ui("click")
					_open_editor()
				else:
					_menu_toast("SHIPPED MAP  ·  DEV BUILD ONLY", COL_GOLD)
				return

		if screen == Screen.PLAYING and game_paused:

			if event.is_action_pressed("retry"):
				_pause_restart()
			elif event.is_action_pressed("pause_menu"):
				_pause_menu()
			elif event.is_action_pressed("pause_settings"):
				_open_settings()
			return
		if screen != Screen.PLAYING or _transitioning or _pre_roll:
			return








		if Mods.is_mania():
			for i in 3:
				if event.is_action_pressed(SettingsManager.MANIA_ACTIONS[i]):
					_on_lane_pressed(i)
					return
		else:
			if event.is_action_pressed("hit_primary"):
				_on_hit_pressed("hit_primary")
				return
			if event.is_action_pressed("hit_secondary"):
				_on_hit_pressed("hit_secondary")
				return


		if tutorial_active:
			return



		if event.is_action_pressed("retry"):




			if playtest_from >= 0.0:
				start_game(playtest_from)
			elif game_over or track_done:
				Telemetry.map_retried()
				_restart_game(0.0)
		elif event.physical_keycode == KEY_I:





			if _dev_tools_allowed():
				_toggle_invincible( not invincible)
		elif event.physical_keycode == KEY_TAB:
			if _dev_tools_allowed():
				_toggle_auto( not auto_mode)
		elif event.is_action_pressed("hud_toggle"):



			hud_root.visible = not hud_root.visible
		elif event.is_action_pressed("offset_minus"):
			_nudge_offset(-10.0)
		elif event.is_action_pressed("offset_plus"):
			_nudge_offset(10.0)







func _gameplay_click_allowed() -> bool:
	if screen != Screen.PLAYING or _pre_roll or game_paused:
		return false
	if not SettingsManager.click_hits:
		return false
	if settings_ui != null and settings_ui.visible:
		return false
	if onboarding_ui != null and onboarding_ui.visible:
		return false
	if gate_root != null and is_instance_valid(gate_root) and gate_root.visible:
		return false
	return true







func _on_hit_pressed(src: String) -> void :
	if game_over or track_done:
		return
	if _try_slider_catch(src):
		return



	if Mods.is_mania():
		_try_click()
		return
	_try_hit()







func _on_lane_pressed(lane: int) -> void :
	if game_over or track_done:
		return
	_mania_lane = lane
	player.set_lane(lane)
	if _try_slider_catch(SettingsManager.MANIA_ACTIONS[lane]):
		return
	_try_parry(lane)
	_try_click()



func _source_pressed(src: String) -> bool:
	match src:
		"hit_primary", "hit_secondary", \
		"mania_lane_0", "mania_lane_1", "mania_lane_2":
			return Input.is_action_pressed(src)
		"autoclic":
			return Mods.has("autoclic")
		"mb_left":
			return Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		"mb_right":
			return Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	return false




func _any_slider_held() -> bool:
	for n in live_notes:
		if is_instance_valid(n) and n.type in ["sliderg", "sliderm"]\
		and not n.judged and n.caught:
			return true
	return false




func _hit_window() -> float:
	if _any_slider_held():
		return maxf(tuning.last_s(), tuning.slider_hold_window_ms / 1000.0)
	return tuning.last_s()




func _lane_at_x(x: float) -> int:
	var best: = 0
	var best_d: = INF
	for i in 3:
		if fx_gone[i] >= 0.5:
			continue
		var d: float = absf(x - lane_x(i))
		if d < best_d:
			best_d = d
			best = i
	return best














func _note_window(n: Node2D) -> float:
	var win: = _hit_window()
	var is_yellow: bool = n.type in ["click", "clickx", "sliderg"]
	var lane: int
	if is_yellow:
		var px: float = n.pos_at(0.0).x if n.type == "sliderg" else n.global_position.x
		lane = _lane_at_x(px)
	else:
		lane = n.lane
	var chord: = tuning.perfect_s()
	for m in live_notes:
		if not is_instance_valid(m) or m.judged or m == n:
			continue
		var m_yellow: bool = m.type in ["click", "clickx", "sliderg"]
		if m_yellow == is_yellow:
			continue
		if m_yellow:
			var mx: float = m.pos_at(0.0).x if m.type == "sliderg" else m.global_position.x
			if _lane_at_x(mx) != lane:
				continue
		elif m.type not in ["parry", "sliderm", "beam"] or m.lane != lane:
			continue
		var gap: float = absf(m.time - n.time)
		if gap <= chord or gap >= 2.0 * win:
			continue
		win = minf(win, maxf(gap * 0.5, chord))
	return win







func _early_miss(cands: Array) -> bool:
	if tuning.early_miss_window_ms <= 0.0 or auto_mode:
		return false
	var t: = conductor.get_song_time()
	var win: = _hit_window()
	var best = null
	var best_lead: = INF
	for n in cands:
		var lead: float = n.time - t
		if lead > win and lead <= tuning.early_miss_s() and lead < best_lead:
			best_lead = lead
			best = n
	if best == null:
		return false
	_float_text("TOO EARLY", best.position + Vector2(0, -78), Skins.col("judge_miss"), 18)
	if best.type == "clickx" and best.remaining() > 1:
		_clickx_miss_step(best)
	else:
		_miss(best)
	return true





func _try_hit() -> void :
	_try_parry()
	_try_click()








func _try_parry(lane: = -1) -> void :
	if game_over or track_done:
		return
	var t: = conductor.get_song_time()
	var pl: = lane if lane >= 0 else player.lane

	var best = null
	var best_abs: = INF
	var cands: Array = []
	for n in live_notes:
		if not is_instance_valid(n) or n.judged:
			continue
		if n.type == "parry":
			if n.lane != pl:
				continue
		elif n.type == "beam":
			if n.caught or n.lane != pl:
				continue
		else:
			continue
		cands.append(n)
		var d: float = absf(t - n.time)
		if d <= _note_window(n) and d < best_abs:
			best_abs = d
			best = n
	if best == null:



		_early_miss(cands.filter( func(c): return c.type == "parry"))
		return
	var tier: = tuning.tier_for_delta(best_abs)
	if best.type == "beam":
		_beam_catch(best, tier == "PERFECT", tier == "MEH")
	elif tier == "PERFECT":
		_perfect_parry(best)
	else:
		_good_parry(best, tier == "MEH")



func _try_click() -> void :
	if game_over or track_done:
		return
	var t: = conductor.get_song_time()
	var mouse: = aim_position()
	var best = null
	var best_abs: = INF
	var cands: Array = []
	for n in live_notes:
		if not is_instance_valid(n) or n.judged\
		or (n.type != "click" and n.type != "clickx"):
			continue
		if n.global_position.distance_to(mouse) > tuning.click_hit_radius + 8.0:
			continue
		cands.append(n)
		var d: float = absf(t - n.time)


		if d <= _note_window(n) and d < best_abs:
			best_abs = d
			best = n
	if best == null:
		_early_miss(cands)
		return
	var tier: = tuning.tier_for_delta(best_abs)
	if best.type == "clickx":
		_clickx_step(best, tier == "PERFECT", tier == "MEH")
	else:
		_click_hit(best, tier == "PERFECT", tier == "MEH")





func _in_kiai(t: float) -> bool:
	for k in kiai_sections:
		if t >= k[0] and t <= k[1]:
			return true
	return false




func beat_pulse() -> float:
	if not conductor.playing:
		return 0.0
	var beat: = conductor.get_song_time() * chart_bpm / 60.0
	if beat < 0.0:
		return 0.0
	return exp( - fposmod(beat, 1.0) * 5.0)




func _spawn_click_pop(pos: Vector2, strength: = 1.0) -> void :
	var k: = 1.0
	if _pops_alive >= 4 or not SettingsManager.vis_on("fx_click_pop"):
		return
	_pops_alive += 1
	if not PerfFlags.hit_fx:
		return
	var c: Node2D = preload("res://scripts/click_pop.gd").new()
	c.position = pos
	c.strength = strength * SettingsManager.note_fx_intensity * k
	c.tree_exited.connect( func() -> void : _pops_alive -= 1)


	notes_root.add_child(c)
	notes_root.move_child(c, 0)






func _ignite() -> void :
	on_fire = true
	fire_ignite_ms = Time.get_ticks_msec()
	fire_ignite_lane = player.lane


	if not SettingsManager.fx_fire:
		return
	_shake("events", 7.0)
	_spawn_shockwave(player.position, tuning.shockwave_radius_perfect * 1.2, 
		neon(COL_GOLD, 1.35))
	_spawn_burst(player.position, Color(1.5, 1.15, 0.5), 22, 460.0)
	_float_text("ON FIRE!", Vector2(get_viewport_rect().size.x * 0.5, 210.0), 
		neon(COL_GOLD, 1.3), 56, true)
	_flash_line(neon(COL_GOLD, 1.3), 1.0)
	_skin_fx("ignite", player.position)
	sfx.play_ui("ignite")
	sfx.play_skin("ignite")




func _spawn_glitch(pos: Vector2, strength: float) -> void :
	var k: = 1.0
	if _glitch_alive >= 3 or not SettingsManager.vis_on("fx_glitch"):
		return
	_glitch_alive += 1
	if not PerfFlags.hit_fx:
		return
	var g: Node2D = preload("res://scripts/glitch_burst.gd").new()
	g.position = pos
	g.strength = strength * SettingsManager.note_fx_intensity * k
	g.tree_exited.connect( func() -> void : _glitch_alive -= 1)

	notes_root.add_child(g)
	notes_root.move_child(g, 0)


func _spawn_burst(pos: Vector2, color: Color, count: = 12, speed: = 320.0) -> void :


	var fx: = 1.0
	if _bursts_alive >= 5 or not SettingsManager.vis_on("fx_burst"):
		return
	_bursts_alive += 1
	if not PerfFlags.hit_fx:
		return
	var b: = HitBurst.new()
	b.position = pos
	b.color = color
	b.count = maxi(2, roundi(count * fx))
	b.speed = speed
	b.tree_exited.connect( func() -> void : _bursts_alive -= 1)
	fx_root.add_child(b)



func _pop_combo() -> void :
	combo_label.scale = Vector2(1.32, 1.32)
	combo_label.rotation = 0.05
	if _combo_tw:
		_combo_tw.kill()
	_combo_tw = combo_label.create_tween()
	_combo_tw.tween_property(combo_label, "scale", Vector2.ONE, 0.18)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_combo_tw.parallel().tween_property(combo_label, "rotation", 0.0, 0.18)\
	.set_ease(Tween.EASE_OUT)



func _flash_line(c: Color, strength: = 1.0) -> void :
	if not SettingsManager.vis_on("fx_line_flash"):
		return
	line_flash = maxf(line_flash, strength)
	line_flash_col = c



func _record_delta(delta_ms: float) -> void :


	if auto_mode:
		delta_ms = 0.0
	hit_deltas.append({"d": delta_ms, "t": Time.get_ticks_msec()})
	if hit_deltas.size() > 24:
		hit_deltas.pop_front()






func _show_judgement(text: String, color: Color, delta_ms: float) -> void :
	if auto_mode and not is_nan(delta_ms):
		delta_ms = 0.0

	if is_nan(delta_ms):
		timing_label.text = ""
	else:
		timing_label.text = "%+.0f ms" % delta_ms
		_record_delta(delta_ms)


	if not SettingsManager.fx_judge_text:
		return
	var is_perfect: = text == "PERFECT"


	var jkey: = "judge_perfect" if is_perfect or text == "HELD!"\
	else ("judge_good" if text == "GOOD" else ("judge_miss" if text == "MISS"\
	else ("judge_meh" if text == "MEH" else "")))
	var jtex: Texture2D = Skins.tex(jkey) if jkey != "" else null
	var target: Control = judge_label
	if jtex != null:
		if judge_image == null:
			judge_image = TextureRect.new()
			judge_image.custom_minimum_size = judge_label.custom_minimum_size
			judge_image.size = judge_label.custom_minimum_size
			judge_image.position = judge_label.position
			judge_image.pivot_offset = judge_label.pivot_offset
			judge_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			judge_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			judge_label.get_parent().add_child(judge_image)
		judge_image.texture = jtex
		judge_image.visible = true
		judge_label.modulate.a = 0.0
		target = judge_image
	else:
		if judge_image != null:
			judge_image.visible = false
		judge_label.text = text
		judge_label.add_theme_color_override("font_color", color)

	target.modulate = Color(1.35, 1.35, 1.35) if is_perfect else Color(1.1, 1.1, 1.1)
	target.scale = Vector2(1.45, 1.45) if is_perfect else Vector2(1.25, 1.25)
	target.rotation = 0.03 if is_perfect else 0.0
	if _judge_tw:
		_judge_tw.kill()
	_judge_tw = target.create_tween()
	_judge_tw.tween_property(target, "scale", Vector2.ONE, 0.14)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_judge_tw.parallel().tween_property(target, "modulate", Color.WHITE, 0.16)
	_judge_tw.parallel().tween_property(target, "rotation", 0.0, 0.14)
	_judge_tw.tween_interval(0.24)
	_judge_tw.tween_property(target, "modulate:a", 0.0, 0.2)
	if is_perfect:

		var jpos: = Vector2(get_viewport_rect().size.x * 0.5, tuning.hit_y + 48.0)
		_spawn_burst(jpos, color, 16, 420.0)
		_spawn_shockwave(jpos, 130.0, Color(color.r, color.g, color.b, 0.55))



func _pop_score_delta(points: int) -> void :
	score_delta.text = "+%d" % points
	score_delta.add_theme_color_override("font_color", COL_ACCENT)
	score_delta.scale = Vector2(1.25, 1.25)
	score_delta.modulate.a = 1.0
	if _delta_tw:
		_delta_tw.kill()
	_delta_tw = score_delta.create_tween()
	_delta_tw.tween_property(score_delta, "scale", Vector2.ONE, 0.1)
	_delta_tw.tween_interval(0.3)
	_delta_tw.tween_property(score_delta, "modulate:a", 0.0, 0.25)



func _milestone_burst(m: int) -> void :
	lane_mascots.react_combo_all(m)




	if not SettingsManager.vis_on("hud_combo"):
		return
	var pos: = Vector2(get_viewport_rect().size.x * 0.5, 210.0)
	_float_text("x%d" % m, pos, Skins.col("fx_gold"), 60, true)
	_spawn_burst(pos, Skins.col("fx_gold"), 22, 440.0)

func _perfect_parry(n: Node2D) -> void :
	var delta_ms: float = (conductor.get_song_time() - n.time) * 1000.0
	n.resolve("PERFECT")
	perfect_chain += 1
	_register_hit(SCORE_PERFECT, 1.0)

	_spawn_shockwave(player.position, tuning.shockwave_radius_perfect, 
		neon(Skins.col("wave_perfect")))
	_spawn_burst(player.position, Skins.col("fx_perfect"), 14, 360.0)
	_skin_fx("parry_hit", player.position)
	_show_judgement("PERFECT", Skins.col("judge_perfect"), delta_ms)
	_flash_line(neon(Skins.col("fx_perfect"), 1.25), 1.0)
	player.flash()
	lane_mascots.react_perfect(n.lane)
	sfx.play_sfx("parry_perfect")
	_tut("parry", true)



func _good_parry(n: Node2D, meh: = false) -> void :
	var delta_ms: float = (conductor.get_song_time() - n.time) * 1000.0
	n.resolve("GOOD")
	perfect_chain = 0
	_register_hit(SCORE_GOOD, ScoreLib.MEH_WEIGHT if meh else 0.5)

	_spawn_shockwave(player.position, tuning.shockwave_radius_good, 
		Color(Skins.col("wave_perfect"), 0.5 if meh else 0.7))
	_skin_fx("parry_hit", player.position)
	if meh:
		_show_judgement("MEH", Skins.col("judge_meh"), delta_ms)
	else:
		_show_judgement("GOOD", Skins.col("judge_good"), delta_ms)
	_flash_line(Skins.col("fx_perfect"), 0.45)
	lane_mascots.react_hit(n.lane)
	sfx.play_sfx("parry_good")
	_tut("parry", true)


func _click_hit(n: Node2D, perfect: bool, meh: = false) -> void :
	var delta_ms: float = (conductor.get_song_time() - n.time) * 1000.0


	_record_delta(delta_ms)

























	if perfect:
		n.resolve("PERFECT")
		perfect_chain += 1
		_register_hit(SCORE_PERFECT, 1.0)


		if preload("res://scripts/stage_render.gd").legacy():
			_spawn_click_pop(n.position, 1.0)
		_skin_fx("click_hit", n.position)
		_click_shake(3.5)




		_float_text("PERFECT", n.position + Vector2(0, -62), Skins.col("judge_perfect"), 32)
		lane_mascots.react_perfect(n.lane)
		sfx.play_sfx("click_perfect")
	else:
		n.resolve("GOOD")
		perfect_chain = 0
		_register_hit(SCORE_GOOD, ScoreLib.MEH_WEIGHT if meh else 0.5)



		if preload("res://scripts/stage_render.gd").legacy():
			_spawn_click_pop(n.position, 0.3 if meh else 0.45)
		_skin_fx("click_hit", n.position)
		_click_shake(1.2 if meh else 2.0)
		if meh:
			_float_text("MEH", n.position + Vector2(0, -58), Skins.col("judge_meh"), 24)
		else:
			_float_text("GOOD", n.position + Vector2(0, -58), Skins.col("judge_good"), 26)
		lane_mascots.react_hit(n.lane)
		sfx.play_sfx("click_good")
	_tut("click", true)





func _clickx_step(n: Node2D, perfect: bool, meh: = false) -> void :
	if n.remaining() <= 1:
		_click_hit(n, perfect, meh)
		return
	var delta_ms: float = (conductor.get_song_time() - n.time) * 1000.0
	_record_delta(delta_ms)
	n.advance_step()
	if perfect:
		perfect_chain += 1
		_register_hit(SCORE_PERFECT, 1.0)
		_spawn_click_pop(n.position, 0.7)
		_click_shake(2.2)
		if not _in_yellow_span(conductor.get_song_time()):
			_zoom_punch(n.position, 0.016)
		_float_text(str(n.remaining()), n.position + Vector2(0, -62), Skins.col("judge_perfect"), 30)
		sfx.play_sfx("click_perfect")
	else:
		perfect_chain = 0
		_register_hit(SCORE_GOOD, ScoreLib.MEH_WEIGHT if meh else 0.5)
		_spawn_click_pop(n.position, 0.4)
		_click_shake(1.4)
		_float_text(str(n.remaining()), n.position + Vector2(0, -58), 
			Skins.col("judge_meh" if meh else "judge_good"), 24)
		sfx.play_sfx("click_good")


func _dodge_success(n: Node2D) -> void :
	n.resolve("DODGE")

	for k in _stack_of(n):
		_register_hit(SCORE_DODGE, 1.0, tuning.hp_regen_dodge)


	_spawn_shockwave(n.position, tuning.shockwave_radius_good * 0.9, 
		Color(Skins.col("wave_dodge"), 0.85))
	_spawn_burst(n.position, Skins.col("fx_miss"), 8, 240.0)
	_skin_fx("dodge", n.position)
	_float_text("dodge", n.position + Vector2(0, -40), Skins.col("judge_dodge"), 20)
	_flash_line(Skins.col("flash_dodge"), 0.5)
	lane_mascots.react_dodge(n.lane)
	sfx.play_sfx("dodge")
	_tut("dodge", true)


func _miss(n: Node2D) -> void :
	if auto_mode:


		print("MISS auto : t=%.3f type=%s lane=%d" % [n.time, n.type, n.lane])
	n.resolve("MISS")
	_miss_penalty(n.type, n.lane, n.position, 32, 1.0, _stack_of(n))
	_tut("miss", false)
	if hp <= 0 or Mods.has("sudden"):
		_do_game_over()





func _clickx_miss_step(n: Node2D) -> void :
	if auto_mode:
		print("MISS auto (maillon) : t=%.3f reste=%d" % [n.time, n.remaining()])
	_miss_penalty(n.type, n.lane, n.position, 26, 0.6)
	n.miss_step()
	if hp <= 0 or Mods.has("sudden"):
		_do_game_over()








func _miss_penalty(note_type: String, lane: int, pos: Vector2, size: int, 
		strength: float, count: = 1) -> void :
	var big_break: = combo >= 20
	for k in count:
		Telemetry.note_judged("miss")
	combo = 0
	perfect_chain = 0
	fever = 0.0
	player.fever = 0.0
	if not invincible:
		hp -= _hp_damage(note_type) * count
	judged_count += count
	_recompute_score()

	_skin_fx("click_miss" if note_type == "click" or note_type == "clickx" else "miss", pos)
	_float_text("MISS", pos + Vector2(0, -50), Skins.col("judge_miss"), size, true)
	_flash_line(neon(Skins.col("fx_miss"), 1.2), strength)
	_shake("miss", tuning.shake_miss_intensity * strength)
	_flash_hp_red()
	lane_mascots.react_miss(lane, big_break, note_type == "dodge")
	sfx.play_sfx("miss")





func _update_beams(t: float) -> void :


	var mania: = Mods.is_mania()
	var held: = auto_mode or Input.is_action_pressed("hit_primary")\
	or Input.is_action_pressed("hit_secondary")
	for n in live_notes:
		if not is_instance_valid(n) or n.type != "beam" or n.judged:
			continue
		if not n.caught:
			if t > n.time + tuning.last_s():
				_beam_break(n, t)
			continue
		var end: float = n.time + n.duration
		if t >= end:
			_beam_release(n)
			continue

		var lane_now: int = n.lane_at(t)
		var holding: bool = auto_mode or (Input.is_action_pressed(
			SettingsManager.MANIA_ACTIONS[lane_now]) if mania
			else (held and player.lane == lane_now))
		if holding:
			n.grace = 0.0
			if t >= n.next_tick and t < end - 0.05:
				n.next_tick += BEAM_TICK
				_beam_tick(n, t)
		else:
			n.grace += get_process_delta_time()
			if n.grace > BEAM_GRACE:

				if end - t <= tuning.good_s():
					_beam_release(n, false)
				else:
					_beam_break(n, t)






func _earlier_click_hittable(before_time: float, t: float, aim: Vector2) -> bool:
	for c in live_notes:
		if not is_instance_valid(c) or c.judged\
		or (c.type != "click" and c.type != "clickx"):
			continue
		if c.time >= before_time or absf(t - c.time) > _hit_window():
			continue
		if aim.distance_to(c.position) <= tuning.click_hit_radius + 8.0:
			return true
	return false







func _earlier_lane_hittable(before_time: float, t: float, lane: int) -> bool:
	for c in live_notes:
		if not is_instance_valid(c) or c.judged or c.lane != lane:
			continue
		if c.type == "beam":
			if c.caught:
				continue
		elif c.type != "parry":
			continue
		if c.time >= before_time or absf(t - c.time) > _hit_window():
			continue
		return true
	return false





func _try_slider_catch(src: String) -> bool:
	var t: = conductor.get_song_time()
	var aim: = aim_position()
	for n in live_notes:

		if not is_instance_valid(n) or n.type not in ["sliderg", "sliderm"]\
		or n.judged or n.caught:
			continue
		var end: float = n.time + n.duration
		if t < n.time - tuning.last_s() or t >= end:
			continue
		var head_phase: bool = not n.head_missed and n.held_time == 0.0\
		and absf(t - n.time) <= _note_window(n)



		if head_phase and _earlier_click_hittable(n.time, t, aim):
			continue
		if head_phase and n.type == "sliderm"\
		and _earlier_lane_hittable(n.time, t, n.lane):
			continue
		if n.type == "sliderg":

			var ref: Vector2 = n.pos_at(0.0) if head_phase else n.pos_at_time(t)
			var rad: float = tuning.click_hit_radius + 8.0 if head_phase\
			else tuning.slider_rail_tolerance
			if aim.distance_to(ref) > rad:
				continue
		elif player.lane != n.lane:
			continue
		_slider_take(n, t, src)
		return true
	return false




func _held_source() -> String:
	if Mods.is_mania():
		for a in SettingsManager.MANIA_ACTIONS:
			if Input.is_action_pressed(a):
				return a
	elif Input.is_action_pressed("hit_primary"):
		return "hit_primary"
	elif Input.is_action_pressed("hit_secondary"):
		return "hit_secondary"
	if SettingsManager.click_hits:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			return "mb_left"
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			return "mb_right"
	return ""




func _slider_take(n: Node2D, t: float, src: String) -> void :
	if not n.head_missed and n.held_time == 0.0\
	and absf(t - n.time) <= tuning.last_s():
		var tier: = tuning.tier_for_delta(absf(t - n.time))
		_slider_catch(n, tier == "PERFECT", src, tier == "MEH")
		return
	n.caught = true
	n.hold_src = src
	n.grace = 0.0
	n.next_tick = maxf(n.next_tick, t + tuning.slider_tick)
	_flash_line(neon(Skins.col("fx_gold") if n.type == "sliderg"
		else Skins.col("fx_perfect"), 1.1), 0.4)
	sfx.play_sfx("parry_good")


func _slider_catch(n: Node2D, perfect: bool, src: String, meh: = false) -> void :
	var t: = conductor.get_song_time()
	n.caught = true
	n.hold_src = src
	n.next_tick = n.time + tuning.slider_tick
	n.catch_late = maxf(t - n.time, 0.0)
	_skin_fx("slider_hit", n.pos_at(0.0) if n.type == "sliderg" else _slider_contact(n, t))
	_record_delta((t - n.time) * 1000.0)
	if perfect:
		perfect_chain += 1
		_register_hit(SCORE_PERFECT, 1.0)
		_show_judgement("PERFECT", Skins.col("judge_perfect"), (t - n.time) * 1000.0)
	elif meh:
		perfect_chain = 0
		_register_hit(SCORE_GOOD, ScoreLib.MEH_WEIGHT)
		_show_judgement("MEH", Skins.col("judge_meh"), (t - n.time) * 1000.0)
	else:
		perfect_chain = 0
		_register_hit(SCORE_GOOD, 0.5)
		_show_judgement("GOOD", Skins.col("judge_good"), (t - n.time) * 1000.0)
	if n.type == "sliderg":
		sfx.play_sfx("click_perfect" if perfect else "click_good")
	else:
		sfx.play_sfx("parry_perfect" if perfect else "parry_good")
	if perfect:
		lane_mascots.react_perfect(n.lane)
	else:
		lane_mascots.react_hit(n.lane)
	player.flash()






func _update_sliders(t: float) -> void :
	for n in live_notes:
		if not is_instance_valid(n) or n.judged\
		or n.type not in ["sliderg", "sliderm"]:
			continue
		var end: float = n.time + n.duration
		if t >= end:



			if n.caught and (auto_mode or _source_pressed(n.hold_src)):
				n.held_time += clampf(end - (t - get_process_delta_time()), 
					0.0, get_process_delta_time())




			_slider_finish(n)
			continue
		if not n.caught:
			if not n.head_missed and n.held_time == 0.0\
			and t > n.time + tuning.last_s():
				_slider_head_miss(n)



			elif t >= n.time and (n.head_missed or n.held_time > 0.0):
				var held_src: = _held_source()
				if held_src != "" or auto_mode:
					var aim_r: = (auto_cursor if auto_mode else aim_position())
					var ok_r: bool = player.lane == n.lane if n.type == "sliderm"\
					else aim_r.distance_to(n.pos_at_time(t))\
					<= tuning.slider_rail_tolerance
					if ok_r:
						_slider_take(n, t, held_src)
			continue
		var held: = auto_mode or _source_pressed(n.hold_src)
		var ok: = held
		if ok:
			if n.type == "sliderg":
				var aim: = (auto_cursor if auto_mode else aim_position())
				ok = aim.distance_to(n.pos_at_time(t)) <= tuning.slider_rail_tolerance
				if not ok:
					n.off_time += get_process_delta_time()
			else:
				ok = player.lane == n.lane
		if ok:
			n.grace = 0.0
			n.held_time += get_process_delta_time()
			if t >= n.next_tick and t < end - 0.05:
				n.next_tick += tuning.slider_tick
				_slider_tick(n, t)
		else:
			n.grace += get_process_delta_time()
			if n.grace > tuning.slider_grace:
				_slider_drop(n, t)




func _slider_head_miss(n: Node2D) -> void :
	n.head_missed = true




	Telemetry.note_judged("miss")
	judged_count += 1
	_recompute_score()
	combo = 0
	perfect_chain = 0
	fever = 0.0
	player.fever = 0.0
	_float_text("MISS", n.pos_at(0.0) + Vector2(0, -60) if n.type == "sliderg"
		else Vector2(lane_x(n.lane), tuning.hit_y - 60.0), Skins.col("judge_miss"), 26)
	_flash_line(Color(1.0, 0.45, 0.45), 0.5)
	lane_mascots.react_miss(n.lane)
	sfx.play_sfx("miss")






func _slider_drop(n: Node2D, t: float) -> void :
	n.caught = false
	n.grace = 0.0
	n.drops += 1
	combo = 0
	perfect_chain = 0
	fever = 0.0
	player.fever = 0.0
	_float_text("break", _slider_contact(n, t) + Vector2(0, -50), Skins.col("judge_dodge"), 22)
	_flash_line(Color(1.0, 0.55, 0.35), 0.5)
	lane_mascots.react_break(n.lane)
	_skin_fx("slider_break", _slider_contact(n, t))
	sfx.play_ui("back")
	sfx.play_skin("slider_break")


	if Mods.has("sudden"):
		_do_game_over()



func _slider_contact(n: Node2D, t: float) -> Vector2:
	if n.type == "sliderg":
		return n.pos_at_time(t)
	return Vector2(lane_x(n.lane), tuning.hit_y)



func _slider_tick(n: Node2D, t: float) -> void :


	_hp_regen(tuning.hp_regen_tick)
	if "tick_pulse" in n:
		n.tick_pulse = 1.0
	_skin_fx("slider_tick", _slider_contact(n, t))
	sfx.play_skin("slider_tick")
	var col: = Skins.col("fx_gold") if n.type == "sliderg" else Skins.col("fx_perfect")
	_spawn_burst(_slider_contact(n, t), col, 4, 180.0)
	_flash_line(neon(col, 1.1), 0.25)










func _slider_finish(n: Node2D) -> void :





	var lenience: float = minf(tuning.slider_end_lenience, n.duration * 0.5)
	var avail: float = maxf(n.duration - n.catch_late - lenience, 0.001)
	var ratio: float = n.held_time / avail
	var t: = conductor.get_song_time()
	var c: = _slider_contact(n, t)
	var col: = Skins.col("fx_gold") if n.type == "sliderg" else Skins.col("fx_perfect")
	var held_ok: bool = ratio >= tuning.slider_perfect_ratio and n.drops == 0\
	and (n.type != "sliderg" or n.off_time <= tuning.slider_off_rail_max)
	if auto_mode and not held_ok:


		print("SLIDER auto non parfait : t=%.3f type=%s held=%.3f avail=%.3f ratio=%.3f drops=%d off=%.3f catch_late=%.3f head_missed=%s fps=%d"
			%[n.time, n.type, n.held_time, avail, ratio, n.drops, 
			(n.off_time if n.type == "sliderg" else 0.0), n.catch_late, 
			str(n.head_missed), Engine.get_frames_per_second()])
	if held_ok:
		n.resolve("PERFECT")
		perfect_chain += 1
		_register_hit(SCORE_PERFECT, 1.0)
		_show_judgement("HELD!", Skins.col("judge_perfect"), 0.0)
		_spawn_shockwave(c, tuning.shockwave_radius_perfect, neon(col))
		_spawn_burst(c, col, 16, 380.0)
		_skin_fx("slider_end", c)
		lane_mascots.react_perfect(n.lane)
		sfx.play_sfx("parry_perfect")
		_flash_line(neon(col, 1.3), 1.0)
	elif ratio >= tuning.slider_good_ratio:
		n.resolve("GOOD")
		_register_hit(SCORE_GOOD, 0.5)
		_show_judgement("GOOD", Skins.col("judge_good"), 0.0)
		lane_mascots.react_hit(n.lane)
		sfx.play_sfx("parry_good")
		_flash_line(neon(col, 1.2), 0.7)
	else:
		n.broken = true
		n.resolve("MISS")
		Telemetry.note_judged("miss")
		combo = 0
		perfect_chain = 0
		fever = 0.0
		player.fever = 0.0
		if not invincible:
			hp -= tuning.hp_miss_hold
		judged_count += 1
		_recompute_score()
		_float_text("MISS", c + Vector2(0, -60), Skins.col("judge_miss"), 32, true)
		_flash_line(neon(Skins.col("fx_miss"), 1.2), 1.0)
		_shake("miss", tuning.shake_miss_intensity)
		_flash_hp_red()
		lane_mascots.react_miss(n.lane)
		sfx.play_sfx("miss")
		if hp <= 0:
			_do_game_over()
	_tut("slider", ratio >= tuning.slider_good_ratio)



func _beam_contact(n: Node2D, t: float) -> Vector2:
	return Vector2(lane_x(n.lane_at(t)), tuning.hit_y)


func _beam_catch(n: Node2D, perfect: bool, meh: = false) -> void :
	var t: = conductor.get_song_time()
	var delta_ms: float = (t - n.time) * 1000.0
	n.caught = true
	n.next_tick = n.time + BEAM_TICK
	_record_delta(delta_ms)
	var c: = _beam_contact(n, t)
	if perfect:
		perfect_chain += 1
		_register_hit(SCORE_PERFECT, 1.0)
		_show_judgement("PERFECT", Skins.col("judge_perfect"), delta_ms)
		_spawn_shockwave(c, tuning.shockwave_radius_good, neon(Skins.col("beam_idle")))
		sfx.play_sfx("parry_perfect")
	elif meh:
		perfect_chain = 0
		_register_hit(SCORE_GOOD, ScoreLib.MEH_WEIGHT)
		_show_judgement("MEH", Skins.col("judge_meh"), delta_ms)
		sfx.play_sfx("parry_good")
	else:
		perfect_chain = 0
		_register_hit(SCORE_GOOD, 0.5)
		_show_judgement("GOOD", Skins.col("judge_good"), delta_ms)
		sfx.play_sfx("parry_good")
	_flash_line(neon(Skins.col("beam_idle"), 1.2), 0.8)
	player.flash()
	if perfect:
		lane_mascots.react_perfect(n.lane_at(t))
	else:
		lane_mascots.react_hit(n.lane_at(t))



func _beam_tick(n: Node2D, t: float) -> void :
	_hp_regen(tuning.hp_regen_tick)
	_spawn_burst(_beam_contact(n, t), Skins.col("fx_perfect"), 4, 180.0)
	_flash_line(neon(Skins.col("beam_idle"), 1.1), 0.25)



func _beam_release(n: Node2D, complete: = true) -> void :
	var t: = conductor.get_song_time()
	var c: = _beam_contact(n, t)
	n.resolve("PERFECT" if complete else "GOOD")
	if complete:
		perfect_chain += 1
		_register_hit(SCORE_PERFECT, 1.0)
		_show_judgement("HELD!", Skins.col("judge_perfect"), 0.0)
		_spawn_shockwave(c, tuning.shockwave_radius_perfect, neon(Skins.col("beam_idle")))
		_spawn_burst(c, Skins.col("fx_perfect"), 16, 380.0)
		sfx.play_sfx("parry_perfect")
	else:
		_register_hit(SCORE_GOOD, 0.5)
		_show_judgement("GOOD", Skins.col("judge_good"), 0.0)
		sfx.play_sfx("parry_good")
	_flash_line(neon(Skins.col("beam_idle"), 1.3), 1.0)



func _beam_break(n: Node2D, t: float) -> void :
	n.broken = true
	n.resolve("MISS")
	Telemetry.note_judged("miss")
	combo = 0
	perfect_chain = 0
	fever = 0.0
	player.fever = 0.0
	if not invincible:
		hp -= tuning.hp_miss_hold
	judged_count += 1
	_recompute_score()
	_float_text("MISS", _beam_contact(n, t) + Vector2(0, -60), Skins.col("judge_miss"), 32, true)
	_flash_line(neon(Skins.col("fx_miss"), 1.2), 1.0)
	_shake("miss", tuning.shake_miss_intensity)
	_flash_hp_red()
	lane_mascots.react_miss(n.lane_at(t))
	sfx.play_sfx("miss")
	if hp <= 0 or Mods.has("sudden"):
		_do_game_over()



func _hp_damage(note_type: String) -> float:
	match note_type:
		"dodge":
			return tuning.hp_miss_dodge
		"click", "clickx":
			return tuning.hp_miss_click
		"sliderg", "sliderm", "beam":
			return tuning.hp_miss_hold
	return tuning.hp_miss_parry



func _hp_regen(amount: float) -> void :
	if game_over or track_done:
		return
	var streak: = 1.0 + minf(combo, 40.0) / 40.0 * tuning.hp_streak_bonus
	hp = minf(hp + amount * streak, tuning.hp_max)



func _register_hit(base_points: int, accuracy: float, regen: = -1.0) -> void :
	Telemetry.note_judged("perfect" if accuracy >= 1.0
		else ("good" if accuracy >= 0.5 else "meh"))
	_hp_regen(regen if regen >= 0.0 else
		(tuning.hp_regen_perfect if accuracy >= 1.0 else tuning.hp_regen_good))
	var mult_before: = multiplier()


	_combo_portion += clampf(accuracy, 0.0, 1.0) * ScoreLib.combo_weight(combo)
	combo += 1
	max_combo = maxi(max_combo, combo)
	judged_count += 1
	accuracy_sum += accuracy
	var before: = score
	_recompute_score()
	var points: = score - before


	run_samples.append([conductor.get_song_time(), score])
	_pop_combo()
	if points > 0:
		_pop_score_delta(points)
	if multiplier() > mult_before:
		_milestone_burst(multiplier())




func _recompute_score(final: = false) -> void :
	var acc: = accuracy_sum / float(maxi(judged_count, 1))
	var cp: = _combo_portion / maxf(_combo_portion_max, 1.0)
	var ap: = 1.0 if final else float(judged_count) / float(maxi(_expected_judgements, 1))
	score = ScoreLib.standardized(acc, cp, ap, mods_mult)



func multiplier() -> int:
	if combo >= 50:
		return 8
	if combo >= 25:
		return 4
	if combo >= 10:
		return 2
	return 1


func _do_game_over() -> void :

	if tutorial_active:
		hp = tuning.hp_max
		return
	game_over = true



	if gauntlet:
		_gauntlet_verdict(false)
		return


	if playtest_from < 0.0:
		Telemetry.map_failed(conductor.get_song_time())
	conductor.stop()



	_reset_lane_fx()
	lane_mascots.react_game_over_all()
	_show_game_over()


func _on_track_finished() -> void :


	if tutorial_active:
		tutorial_ui.on_track_end()
		return
	if screen != Screen.PLAYING:
		if not conductor.playing:
			_play_preview()
		return
	if game_over or track_done or conductor.playing:
		return
	_complete_map()










func _check_judgement_count() -> void :
	if tutorial_active or gauntlet:
		return
	var j: Dictionary = Telemetry.current_judgements()
	var counted: = 0
	for k in j:
		counted += int(j[k])
	if counted == _expected_judgements and counted == judged_count:
		return
	var by_type: = {}
	for n in chart_notes:
		var tp: = String(n.type)
		by_type[tp] = int(by_type.get(tp, 0)) + int(n.get("stack", 1))
	var detail: = {
		"track": tuning.current_track, "diff": tuning.current_diff, 
		"judgedCount": judged_count, "noteTypes": by_type, 
		"mods": Mods.active(), 
	}
	push_warning("JUGEMENTS : %d comptés (judged_count %d) pour %d attendus — %s / %s — %s — %s"
		%[counted, judged_count, _expected_judgements, tuning.current_track, 
		tuning.current_diff, JSON.stringify(j), JSON.stringify(detail)])



func _complete_map() -> void :
	track_done = true


	if gauntlet:
		_gauntlet_verdict(true)
		return
	_check_judgement_count()


	if playtest_from < 0.0:
		Telemetry.map_completed(
			(accuracy_sum / float(maxi(judged_count, 1))) * 100.0, max_combo)
	lane_mascots.react_map_complete_all()
	_show_end_panel("CLEARED!")
	if playtest_from < 0.0 and not run_assisted:
		_submit_online_score()




func _spawn_shockwave(pos: Vector2, radius: float, color: Color) -> void :
	var fx: = 1.0
	if not SettingsManager.vis_on("fx_shockwave"):
		return
	var now: = Time.get_ticks_msec()
	if now - _last_shock_ms < 90:
		return
	_last_shock_ms = now
	if not PerfFlags.hit_fx:
		return
	var wave: = Shockwave.new()
	wave.position = pos
	wave.max_radius = radius * (0.35 + 0.65 * fx)
	wave.duration = tuning.shockwave_duration
	wave.color = color
	fx_root.add_child(wave)





func _update_shake(delta: float) -> void :
	var shake: = fx_shake_off
	if _shake_amp > 0.05:
		shake += Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _shake_amp
		_shake_amp *= exp( - tuning.shake_decay * delta)
	else:
		_shake_amp = 0.0


	var rot: = deg_to_rad(fx_rot) if screen == Screen.PLAYING else 0.0
	if world.rotation != rot:
		world.rotation = rot
	var pivot_off: = Vector2.ZERO
	if rot != 0.0:
		var pivot: = Vector2(get_viewport_rect().size.x * 0.5, tuning.hit_y)
		pivot_off = pivot - pivot.rotated(rot)
	if _zoom_amp > 0.001:
		world.scale = Vector2.ONE * (1.0 + _zoom_amp)
		world.position = shake - _zoom_center * _zoom_amp + pivot_off
		_zoom_amp *= exp(-14.0 * delta)
	else:
		_zoom_amp = 0.0
		if world.scale != Vector2.ONE:
			world.scale = Vector2.ONE
		world.position = shake + pivot_off





func _shake(kind: String, amp: float) -> void :
	if not SettingsManager.vis_on("fx_shake_" + kind):
		return
	_shake_amp = maxf(_shake_amp, amp)







func _click_shake(amp: float) -> void :
	if _in_yellow_span(conductor.get_song_time()):
		return
	_shake("click", amp)


func _in_yellow_span(t: float) -> bool:
	for ys in yellow_spans:
		if t >= ys[0] - 0.12 and t <= ys[1]:
			return true
	return false





func _apply_hud_flags() -> void :
	if _hud_score_box == null:
		return
	var v: = func(key: String) -> bool: return SettingsManager.vis_on(key)
	_hud_score_box.visible = v.call("hud_score") or v.call("hud_combo")
	score_label.visible = v.call("hud_score")
	score_delta.visible = v.call("hud_score") and v.call("hud_score_delta")
	combo_label.visible = v.call("hud_combo")
	_hud_hp_box.visible = v.call("hud_hp") or v.call("hud_mods")
	hp_row.visible = v.call("hud_hp")
	for c in _hud_hp_box.get_children():
		if c is Label and c != hud_mods_label:
			(c as Label).visible = v.call("hud_hp")
	hud_mods_label.visible = v.call("hud_mods")
	if auto_button != null:
		auto_button.visible = v.call("hud_mods") and _dev_tools_allowed()
	if invincible_button != null:
		invincible_button.visible = v.call("hud_mods") and _dev_tools_allowed()
	_hud_acc_box.visible = v.call("hud_accuracy")
	_hud_time_box.visible = v.call("hud_time")
	timing_label.visible = v.call("hud_timing")



func _software_gpu_warning(switched: bool, next_api: = "vulkan") -> void :
	await get_tree().create_timer(2.5).timeout
	var label: = String(SettingsManager.GPU_API_LABELS.get(next_api, next_api.to_upper()))
	var msg: = "SOFTWARE RENDERING DETECTED (%s)" % SettingsManager.gpu_adapter_name().to_upper()
	msg += "  ·  %s WILL BE USED — PLEASE RESTART THE GAME" % label if switched\
	else "  ·  SETTINGS > VISUAL > GRAPHICS API: choose %s" % label
	if next_api == "opengl3":
		msg += "  (last resort: works everywhere, fewer effects)"
	_screen_toast(msg, COL_RED)





func _dev_tools_allowed() -> bool:
	return OS.has_feature("editor") or playtest_from >= 0.0



func _zoom_punch(center: Vector2, amp: float) -> void :
	if not SettingsManager.vis_on("fx_zoom"):
		return
	_zoom_center = center
	_zoom_amp = maxf(_zoom_amp, amp)




func _float_text(text: String, pos: Vector2, color: Color, font_size: int, 
		important: = false) -> void :
	if not SettingsManager.vis_on("fx_float_text"):
		return
	var now: = Time.get_ticks_msec()
	if not important and now - _last_float_ms < 90:
		return
	_last_float_ms = now
	var label: = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(240, 0)
	label.position = pos - Vector2(120, 20)
	if font_judge:
		label.add_theme_font_override("font", font_judge)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.35))
	label.add_theme_constant_override("outline_size", 5)
	label.pivot_offset = Vector2(120, 20)
	label.scale = Vector2(1.35, 1.35)
	fx_root.add_child(label)
	var tw: = label.create_tween()
	tw.tween_property(label, "scale", Vector2.ONE, 0.12).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(label, "position:y", label.position.y - 44.0, 0.5)\
	.set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(label, "modulate:a", 0.0, 0.5).set_delay(0.15)
	tw.tween_callback(label.queue_free)


func _flash_hp_red() -> void :
	hp_row.modulate = Color(3.0, 0.5, 0.5)
	var base: = Color(1.0, 0.85, 0.3) if invincible else Color.WHITE
	var tw: = hp_row.create_tween()
	tw.tween_property(hp_row, "modulate", base, 0.3)






var _lane_x: = PackedFloat32Array([0.0, 0.0, 0.0])
var _lane_x_center: = 640.0
var _lane_x_frame: = -1












func _lane_x_refresh() -> void :
	_lane_x_frame = Engine.get_process_frames()
	_lane_x_center = get_viewport_rect().size.x * 0.5
	var t: = conductor.get_song_time()
	for i in 3:


		var wob: float = fx_sway_amp[i] * sin(t * fx_sway_freq[i] * TAU + float(i) * 2.1)
		if fx_glitch > 0.1:
			wob += (floorf(fposmod(t * 27.0 + float(i) * 7.31, 3.0)) - 1.0) * fx_glitch

		if not is_nan(fx_pos[i]):
			_lane_x[i] = fx_pos[i] + wob
		else:
			_lane_x[i] = _lane_x_center + float(i - 1)\
			* (tuning.lane_width + tuning.lane_gap) * fx_spread + fx_dx[i] + wob


func lane_x(i: int) -> float:
	if not PerfFlags.lane_cache or _lane_x_frame != Engine.get_process_frames():
		_lane_x_refresh()
	return _lane_x[i]




func lane_x_at(i: int, y: float) -> float:
	if not PerfFlags.lane_cache or _lane_x_frame != Engine.get_process_frames():
		_lane_x_refresh()
	var k: = lerpf(LANE_PERSPECTIVE, 1.0, clampf(y / tuning.hit_y, 0.0, 1.0))
	return _lane_x_center + (_lane_x[i] - _lane_x_center) * k



func neon(c: Color, k: = 1.45) -> Color:
	return Color(c.r * k, c.g * k, c.b * k, c.a)







func lane_base(i: int) -> Color:
	return Skins.col_raw("lane_%d" % i, LANE_COLS_BASE[i])





func game_glow() -> Texture2D:
	var t: Texture2D = Skins.tex("glow")
	return t if t != null else glow_tex




func _chip(bg: Color, border: Color, radius: = 9, shadow: = 0) -> StyleBoxFlat:
	var sb: = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	if shadow > 0:
		sb.shadow_color = Color(0, 0, 0, 0.4)
		sb.shadow_size = shadow
		sb.shadow_offset = Vector2(0, shadow * 0.4)
	return sb




func _style_chip(b: Button, selected_is_disabled: bool, accent: Color) -> void :
	b.add_theme_stylebox_override("normal", _chip(COL_BG, Color(1, 1, 1, 0.1)))
	b.add_theme_stylebox_override("hover", _chip(COL_BG_HOVER, Color(1, 1, 1, 0.22)))
	b.add_theme_stylebox_override("pressed", 
		_chip(Color(accent.r, accent.g, accent.b, 0.92), Color(1, 1, 1, 0.15)))
	b.add_theme_color_override("font_color", Color(1, 1, 1, 0.78))
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", Color(0.05, 0.1, 0.08))
	b.add_theme_font_size_override("font_size", 15)
	if selected_is_disabled:
		b.add_theme_stylebox_override("disabled", 
			_chip(Color(accent.r, accent.g, accent.b, 0.92), Color(1, 1, 1, 0.15)))
		b.add_theme_color_override("font_disabled_color", Color(0.05, 0.1, 0.08))
	else:
		b.add_theme_stylebox_override("disabled", 
			_chip(Color(0.08, 0.09, 0.12, 0.55), Color(1, 1, 1, 0.04)))
		b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.22))


func _caption(text: String, pos: Vector2, parent: Control) -> Label:
	var l: = Label.new()
	l.text = text
	l.position = pos
	l.add_theme_font_size_override("font_size", 13)
	l.add_theme_color_override("font_color", Color(1, 1, 1, 0.4))
	parent.add_child(l)
	return l


func _build_ui() -> void :
	var vs: = get_viewport_rect().size
	var root: = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(root)
	hud_root = root




	var fps_layer: = CanvasLayer.new()
	fps_layer.layer = 30
	add_child(fps_layer)
	_fps_label = Label.new()
	_fps_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_fps_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_fps_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_fps_label.offset_left = -120
	_fps_label.offset_top = -30
	_fps_label.offset_right = -10
	_fps_label.offset_bottom = -8
	_fps_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_fps_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_fps_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fps_label.add_theme_font_size_override("font_size", 13)
	_fps_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.62))
	_fps_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	_fps_label.add_theme_constant_override("outline_size", 3)
	if font_bold != null:
		_fps_label.add_theme_font_override("font", font_bold)
	_fps_label.visible = SettingsManager.vis_on("hud_fps")
	fps_layer.add_child(_fps_label)


	_hud_score_box = _hud_corner(root, Vector2(24, 16))
	_hud_caption("SCORE", Vector2(2, 0), _hud_score_box)
	score_label = _hud_value(Vector2(0, 18), Vector2(320, 48), HORIZONTAL_ALIGNMENT_LEFT, 
		_hud_score_box)
	score_label.text = "0000000"

	score_delta = Label.new()
	score_delta.position = Vector2(232, 30)
	score_delta.pivot_offset = Vector2(0, 12)
	score_delta.add_theme_font_size_override("font_size", 20)
	score_delta.add_theme_color_override("font_color", Color(COL_ACCENT, 0.0))
	if font_bold:
		score_delta.add_theme_font_override("font", font_bold)
	_hud_score_box.add_child(score_delta)

	combo_label = Label.new()
	combo_label.position = Vector2(2, 68)
	combo_label.pivot_offset = Vector2(0, 14)
	if font_bold:
		combo_label.add_theme_font_override("font", font_bold)
	combo_label.add_theme_font_size_override("font_size", 22)
	combo_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.5))
	combo_label.add_theme_constant_override("outline_size", 4)
	combo_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_score_box.add_child(combo_label)


	judge_label = Label.new()
	judge_label.custom_minimum_size = Vector2(520, 64)
	judge_label.position = Vector2(vs.x * 0.5 - 260, 616)
	judge_label.pivot_offset = Vector2(260, 32)
	judge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if font_judge:
		judge_label.add_theme_font_override("font", font_judge)
	judge_label.add_theme_font_size_override("font_size", 52)

	judge_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.35))
	judge_label.add_theme_constant_override("outline_size", 5)
	judge_label.modulate.a = 0.0
	root.add_child(judge_label)
	timing_label = Label.new()
	timing_label.custom_minimum_size = Vector2(520, 20)
	timing_label.position = Vector2(vs.x * 0.5 - 260, 696)
	timing_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timing_label.add_theme_font_size_override("font_size", 14)
	timing_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
	root.add_child(timing_label)




	_hud_hp_box = _hud_corner(root, Vector2(vs.x - 24 - HP_BAR_W, 16))
	_hud_caption("HP", Vector2(2, 0), _hud_hp_box)
	hp_row = HBoxContainer.new()
	hp_row.position = Vector2(0, 22)
	hp_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_hp_box.add_child(hp_row)
	var hp_track: = Panel.new()
	hp_track.custom_minimum_size = Vector2(HP_BAR_W, 12)
	hp_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_track_style = StyleBoxFlat.new()
	hp_track_style.set_corner_radius_all(6)
	hp_track_style.bg_color = Skins.col("hp_track")
	hp_track.add_theme_stylebox_override("panel", hp_track_style)
	hp_row.add_child(hp_track)
	hp_bar_fill = Panel.new()
	hp_bar_fill.size = Vector2(HP_BAR_W, 12)
	hp_bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_bar_style = StyleBoxFlat.new()
	hp_bar_style.set_corner_radius_all(6)
	hp_bar_style.bg_color = LANE_COLS[0]
	hp_bar_style.shadow_size = 7
	hp_bar_style.shadow_color = Color(LANE_COLS[0], 0.35)
	hp_bar_fill.add_theme_stylebox_override("panel", hp_bar_style)
	hp_track.add_child(hp_bar_fill)



	hud_mods_label = Label.new()
	hud_mods_label.position = Vector2(HP_BAR_W - 320, 40)
	hud_mods_label.size = Vector2(320, 18)
	hud_mods_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hud_mods_label.add_theme_font_size_override("font_size", 12)
	hud_mods_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if font_bold:
		hud_mods_label.add_theme_font_override("font", font_bold)
	_hud_hp_box.add_child(hud_mods_label)





	auto_button = Button.new()
	auto_button.text = "AUTO"
	auto_button.toggle_mode = true
	auto_button.focus_mode = Control.FOCUS_NONE
	auto_button.disabled = false
	auto_button.position = Vector2(HP_BAR_W - 190, 64)
	auto_button.toggled.connect(_toggle_auto)
	_style_chip(auto_button, false, Color(1.0, 0.55, 0.85))
	auto_button.modulate = Color(1, 1, 1, 0.45)
	_hud_hp_box.add_child(auto_button)

	invincible_button = Button.new()
	invincible_button.text = "INVINCIBLE"
	invincible_button.toggle_mode = true
	invincible_button.focus_mode = Control.FOCUS_NONE
	invincible_button.position = Vector2(HP_BAR_W - 106, 64)
	invincible_button.toggled.connect(_toggle_invincible)
	_style_chip(invincible_button, false, COL_GOLD)
	invincible_button.modulate = Color(1, 1, 1, 0.45)
	_hud_hp_box.add_child(invincible_button)


	_hud_acc_box = _hud_corner(root, Vector2(24, vs.y - 96))
	_hud_caption("ACCURACY", Vector2(2, 0), _hud_acc_box)
	acc_value = _hud_value(Vector2(0, 18), Vector2(320, 48), HORIZONTAL_ALIGNMENT_LEFT, 
		_hud_acc_box)
	acc_value.text = "100.00%"



	_hud_time_box = _hud_corner(root, Vector2(vs.x - 24 - TIME_BAR_W, vs.y - 96))
	_hud_caption("TIME LEFT", Vector2(0, 0), _hud_time_box, HORIZONTAL_ALIGNMENT_RIGHT, 
		TIME_BAR_W - 2)
	time_value = _hud_value(Vector2(0, 18), Vector2(TIME_BAR_W, 48), 
		HORIZONTAL_ALIGNMENT_RIGHT, _hud_time_box)
	time_value.text = "00:00"
	var time_track: = Panel.new()
	time_track.position = Vector2(0, 72)
	time_track.size = Vector2(TIME_BAR_W, 3)
	time_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tts: = StyleBoxFlat.new()
	tts.set_corner_radius_all(2)
	tts.bg_color = Color(1, 1, 1, 0.1)
	time_track.add_theme_stylebox_override("panel", tts)
	_hud_time_box.add_child(time_track)
	time_bar_fill = Panel.new()
	time_bar_fill.size = Vector2(TIME_BAR_W, 3)
	time_bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	time_bar_style = StyleBoxFlat.new()
	time_bar_style.set_corner_radius_all(2)
	time_bar_style.bg_color = Color(COL_ACCENT, 0.9)
	time_bar_style.shadow_size = 5
	time_bar_style.shadow_color = Color(COL_ACCENT, 0.35)
	time_bar_fill.add_theme_stylebox_override("panel", time_bar_style)
	time_track.add_child(time_bar_fill)









	end_panel = _build_end_screen(root)



	pause_root = _build_pause_screen(root)
	gameover_root = _build_game_over_screen(root)

	_build_menu()



	settings_ui = preload("res://scenes/Settings.tscn").instantiate()
	settings_ui.main = self
	ui_layer.add_child(settings_ui)


	onboarding_ui = load("res://scripts/onboarding.gd").new()
	onboarding_ui.main = self
	ui_layer.add_child(onboarding_ui)
	onboarding_ui.finished.connect( func(play_tut: bool) -> void :
		if play_tut:
			start_tutorial()
		else:
			_start_deferred_gate.call_deferred())
	tutorial_ui = load("res://scripts/tutorial.gd").new()
	tutorial_ui.main = self
	ui_layer.add_child(tutorial_ui)




	crosshair_node = Crosshair.new()
	crosshair_node.main = self




	crosshair_node.z_index = 4096
	ui_layer.add_child(crosshair_node)


	_wire_ui_sounds(ui_layer)
	_apply_hud_flags()




func _hud_corner(root: Control, pos: Vector2) -> Control:
	var box: = Control.new()
	box.position = pos
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(box)
	return box




func _hud_caption(text: String, pos: Vector2, parent: Control, 
		align: = HORIZONTAL_ALIGNMENT_LEFT, width: = 0.0) -> Label:
	var l: = Label.new()
	l.text = text
	l.position = pos
	if width > 0.0:
		l.size = Vector2(width, 18)
	l.horizontal_alignment = align
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if font_bold:
		l.add_theme_font_override("font", font_bold)
	l.add_theme_font_size_override("font_size", 13)
	l.add_theme_color_override("font_color", Color(1, 1, 1, 0.58))
	parent.add_child(l)
	return l





func _hud_value(pos: Vector2, size_px: Vector2, align: int, parent: Control) -> GlowLabel:
	var g: = GlowLabel.new()
	g.position = pos
	g.size = size_px
	g.align = align
	g.valign = VERTICAL_ALIGNMENT_TOP
	g.font = font_bold if font_bold != null else ThemeDB.fallback_font
	g.font_size = 40
	g.color = Color(0.94, 1.0, 0.98)
	g.glow_color = Color(0, 0, 0, 0)
	g.glow_strength = 0.0
	parent.add_child(g)
	return g






func _build_end_screen(root: Control) -> Control:
	results_screen = ResultsScreen.new()
	results_screen.visible = false
	results_screen.play_sound = sfx.play_ui
	results_screen.set_glow_texture(glow_tex)
	results_screen.retry_requested.connect( func() -> void :
		if game_over or track_done:
			Telemetry.map_retried()
			_restart_game(0.0))
	results_screen.continue_requested.connect( func() -> void :
		if playtest_from >= 0.0:
			_return_to_editor()
		else:
			_exit_to_select())
	results_screen.leaderboard_requested.connect(_open_leaderboard)
	results_screen.visibility_changed.connect(_on_results_visibility)
	root.add_child(results_screen)
	return results_screen






var _results_hud_hidden: Array = []
var _results_hud_state: = false

func _on_results_visibility() -> void :
	if results_screen == null:
		return
	var on: bool = results_screen.visible






	if on == _results_hud_state:
		return
	_results_hud_state = on
	if background != null:
		background.results_mode = on
	if on:
		world.visible = false
		_results_hud_hidden.clear()
		for c in results_screen.get_parent().get_children():
			if c != results_screen and c is CanvasItem and (c as CanvasItem).visible:
				(c as CanvasItem).visible = false
				_results_hud_hidden.append(c)
	else:
		world.visible = true
		for c in _results_hud_hidden:
			if is_instance_valid(c):
				(c as CanvasItem).visible = true
		_results_hud_hidden.clear()














func _build_game_over_screen(root: Control) -> Control:
	var vs: = get_viewport_rect().size
	var sr: = Control.new()
	sr.set_anchors_preset(Control.PRESET_FULL_RECT)
	sr.visible = false
	root.add_child(sr)



	_go_dim = Panel.new()
	_go_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	var ds: = StyleBoxFlat.new()
	ds.bg_color = Color(0.05, 0.008, 0.02, 0.0)
	_go_dim.add_theme_stylebox_override("panel", ds)
	_go_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sr.add_child(_go_dim)

	_go_title = Label.new()
	_go_title.text = "GAME OVER"
	_go_title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_go_title.position.y = vs.y * 0.26
	_go_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_go_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if font_display:
		_go_title.add_theme_font_override("font", font_display)
	_go_title.add_theme_font_size_override("font_size", 78)
	_go_title.add_theme_color_override("font_color", neon(COL_RED, 1.25))
	_go_title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	_go_title.add_theme_constant_override("outline_size", 8)
	_go_title.pivot_offset = Vector2(vs.x * 0.5, 46.0)
	sr.add_child(_go_title)



	_go_rule = Panel.new()
	var rs: = StyleBoxFlat.new()
	rs.bg_color = neon(COL_RED, 1.1)
	_go_rule.add_theme_stylebox_override("panel", rs)
	_go_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_go_rule.position = Vector2(vs.x * 0.5, vs.y * 0.26 + 96.0)
	_go_rule.size = Vector2(0, 2)
	sr.add_child(_go_rule)

	_go_sub = Label.new()
	_go_sub.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_go_sub.position.y = vs.y * 0.26 + 108.0
	_go_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_go_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if font_bold:
		_go_sub.add_theme_font_override("font", font_bold)
	_go_sub.add_theme_font_size_override("font_size", 17)
	_go_sub.add_theme_color_override("font_color", Color(1, 1, 1, 0.62))
	sr.add_child(_go_sub)

	_go_stats = Label.new()
	_go_stats.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_go_stats.position.y = vs.y * 0.26 + 138.0
	_go_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_go_stats.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_go_stats.add_theme_font_size_override("font_size", 15)
	_go_stats.add_theme_color_override("font_color", Color(1, 1, 1, 0.4))
	sr.add_child(_go_stats)

	_go_box = VBoxContainer.new()
	_go_box.position = Vector2(vs.x * 0.5 - 130.0, vs.y * 0.26 + 186.0)
	_go_box.custom_minimum_size = Vector2(260, 0)
	_go_box.add_theme_constant_override("separation", 12)
	sr.add_child(_go_box)

	for a in [["RETRY  (%s)" % SettingsManager.key_label(SettingsManager.bind_of("retry")), "_game_over_retry", COL_ACCENT], 
			["QUIT TO MENU  (ESC)", "_game_over_quit", COL_RED]]:
		var b: = Button.new()
		b.text = String(a[0])
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(260, 46)
		_style_chip(b, false, a[2])
		b.pressed.connect(Callable(self, String(a[1])))
		_go_box.add_child(b)
	return sr




func _game_over_retry() -> void :
	if playtest_from < 0.0:
		Telemetry.map_retried()
	_hide_game_over()
	if playtest_from < 0.0:
		_restart_game(0.0)
	else:
		start_game(playtest_from)


func _game_over_quit() -> void :
	_hide_game_over()
	_exit_to_select()


func _hide_game_over() -> void :
	if _go_tw != null and _go_tw.is_valid():
		_go_tw.kill()
	if gameover_root != null:
		gameover_root.visible = false





func _show_game_over() -> void :
	if gameover_root == null:
		return
	var vs: = get_viewport_rect().size
	end_panel.visible = false
	pause_root.visible = false
	gameover_root.visible = true


	_go_sub.text = track_title(tuning.current_track)
	var reached: = maxf(conductor.get_song_time(), 0.0)
	var total: float = map_end() if map_end() > 0.0 else\
	(conductor.stream.get_length() if conductor.stream != null else 0.0)
	var pct: = clampf(reached / maxf(total, 0.001), 0.0, 1.0) * 100.0
	var acc: = (accuracy_sum / float(maxi(judged_count, 1))) * 100.0
	_go_stats.text = "%.0f%% OF THE MAP   ·   %d MAX COMBO   ·   %.1f%% ACCURACY"\
	%[pct, max_combo, acc]


	var ds: StyleBoxFlat = _go_dim.get_theme_stylebox("panel")
	ds.bg_color = Color(0.05, 0.008, 0.02, 0.0)
	_go_title.scale = Vector2(2.4, 2.4)
	_go_title.modulate = Color(1, 1, 1, 0)
	_go_rule.position = Vector2(vs.x * 0.5, vs.y * 0.26 + 96.0)
	_go_rule.size = Vector2(0, 2)
	_go_sub.modulate = Color(1, 1, 1, 0)
	_go_stats.modulate = Color(1, 1, 1, 0)
	_go_box.modulate = Color(1, 1, 1, 0)
	_go_box.position.y = vs.y * 0.26 + 206.0

	if _go_tw != null and _go_tw.is_valid():
		_go_tw.kill()
	_go_tw = create_tween()
	_go_tw.set_parallel(true)

	_go_tw.tween_method( func(v: float): ds.bg_color = Color(0.05, 0.008, 0.02, v), 
		0.0, 0.86, 0.55).set_ease(Tween.EASE_OUT)

	_go_tw.tween_property(_go_title, "modulate:a", 1.0, 0.12)
	_go_tw.tween_property(_go_title, "scale", Vector2.ONE, 0.32)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	_go_tw.tween_property(_go_rule, "size:x", 360.0, 0.3).set_delay(0.16)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_go_tw.tween_property(_go_rule, "position:x", vs.x * 0.5 - 180.0, 0.3)\
	.set_delay(0.16).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	_go_tw.tween_property(_go_sub, "modulate:a", 1.0, 0.28).set_delay(0.3)
	_go_tw.tween_property(_go_stats, "modulate:a", 1.0, 0.28).set_delay(0.4)
	_go_tw.tween_property(_go_box, "modulate:a", 1.0, 0.26).set_delay(0.5)
	_go_tw.tween_property(_go_box, "position:y", vs.y * 0.26 + 186.0, 0.34)\
	.set_delay(0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


	_shake("events", 9.0)
	_flash_line(neon(COL_RED, 1.3), 1.0)
	sfx.play_ui("back")


func _build_pause_screen(root: Control) -> Control:
	var vs: = get_viewport_rect().size
	var sr: = Control.new()
	sr.set_anchors_preset(Control.PRESET_FULL_RECT)
	sr.visible = false
	root.add_child(sr)
	var dim: = Panel.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	var ds: = StyleBoxFlat.new()
	ds.bg_color = Color(0.008, 0.012, 0.028, 0.78)
	dim.add_theme_stylebox_override("panel", ds)
	sr.add_child(dim)
	var title: = Label.new()
	title.text = "PAUSE"
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.position.y = vs.y * 0.3
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if font_display:
		title.add_theme_font_override("font", font_display)
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", Color(1, 1, 1, 0.92))
	sr.add_child(title)
	var box: = VBoxContainer.new()
	box.position = Vector2(vs.x * 0.5 - 130.0, vs.y * 0.3 + 110.0)
	box.custom_minimum_size = Vector2(260, 0)
	box.add_theme_constant_override("separation", 12)
	sr.add_child(box)



	var actions: = [
		["RESUME", "_pause_resume", COL_ACCENT], 
		["SETTINGS", "_open_settings", COL_GOLD], 
		["RESTART", "_pause_restart", COL_PERFECT], 
		["MENU", "_pause_menu", Color(0.72, 0.45, 1.0)], 
	]
	for a in actions:
		var b: = Button.new()
		b.text = a[0]
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(260, 44)
		_style_chip(b, false, a[2])
		b.pressed.connect(Callable(self, a[1]))
		box.add_child(b)
	var hint: = Label.new()
	hint.text = "Esc — resume    ·    S — settings    ·    R — restart    ·    M — menu"
	hint.set_anchors_preset(Control.PRESET_TOP_WIDE)


	hint.position.y = vs.y * 0.3 + 128.0 + actions.size() * 56.0
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.35))
	sr.add_child(hint)
	return sr














func _notification(what: int) -> void :
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT\
	or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		pause_on_focus_lost()




func pause_on_focus_lost() -> void :
	if screen != Screen.PLAYING or _pre_roll or _transitioning:
		return
	if game_paused or _resuming or game_over or track_done:
		return
	if tutorial_active or gauntlet:
		return
	_toggle_pause(true)


func _toggle_pause(on: bool) -> void :
	if game_paused == on or _resuming:
		return
	if on:


		_pause_aim = aim_position()
		game_paused = true
		conductor.stream_paused = true
		pause_root.visible = true
		sfx.play_ui("back")
	else:
		_resume_countdown()




func _resume_countdown(restore_aim: = true) -> void :
	_resuming = true
	pause_root.visible = false




	if restore_aim and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_mouse_aim = _pause_aim


	for i in ["3", "2", "1"]:
		_countdown_pop(i, COL_PERFECT, false)
		await get_tree().create_timer(0.3).timeout
	_countdown_pop("GO", COL_ACCENT, true)
	game_paused = false
	conductor.stream_paused = false
	_resuming = false






func _restart_game(from: = 0.0) -> void :
	if _resuming:
		return
	start_game(from)
	game_paused = true
	conductor.stream_paused = true
	_resume_countdown(false)




func _unpause_now() -> void :
	game_paused = false
	conductor.stream_paused = false
	pause_root.visible = false


func _pause_resume() -> void :
	_toggle_pause(false)


func _pause_restart() -> void :
	_unpause_now()
	if playtest_from < 0.0:
		Telemetry.map_retried()
		_restart_game(0.0)
	else:
		start_game(playtest_from)


func _pause_menu() -> void :
	_unpause_now()
	_exit_to_select()






func _wire_ui_sounds(node: Node) -> void :
	if node is Button:
		node.pressed.connect(_ui_click.bind(node))
	for child in node.get_children():
		_wire_ui_sounds(child)





func _poll_hover_sfx() -> void :


	if screen == Screen.PLAYING and not game_paused and not game_over and not track_done:
		return
	var c: Control = get_viewport().gui_get_hovered_control()
	while c != null and not (c is Button):
		c = c.get_parent() as Control
	if c == _hover_last:
		return
	_hover_last = c
	if c != null and not (c as Button).disabled and not _transitioning:
		sfx.play_ui("hover")


func _ui_click(b: Button) -> void :
	sfx.play_ui(String(b.get_meta("ui_sound", "click")))


	if screen != Screen.PLAYING and crosshair_node != null:
		crosshair_node.ping()




func _tween_lowpass(cutoff: float, dur: float) -> void :
	if _lp_tw:
		_lp_tw.kill()
	_lp_tw = create_tween()
	_lp_tw.tween_method( func(v: float): music_lp.cutoff_hz = v, 
		music_lp.cutoff_hz, cutoff, dur)








func _auto_quality_notice(level: String) -> void :
	_menu_toast("GRAPHICS SET TO %s for your hardware  ·  Settings > Visual > Quality"
		%String(SettingsManager.QUALITY_LABELS.get(level, level)), COL_GOLD)


func _scan_charts() -> void :
	var catalog: Dictionary = MapLibrary.tracks()



	track_covers.clear()
	track_bgs.clear()
	track_videos.clear()


	_chart_meta.clear()
	_chart_meta_diff.clear()
	_scan_cache_load()
	_scan_seen.clear()
	var scan_dirty: = false
	for track in catalog:
		var diffs: Dictionary = catalog[track]
		for diff in diffs:
			var cpath: String = diffs[diff]




			var ckey: = "%s|%d|%d" % [cpath, FileAccess.get_modified_time(cpath), 
				ChartRatingLib.VERSION]
			_scan_seen[ckey] = true
			if _scan_cache.has(ckey):
				var cached: Dictionary = _scan_cache[ckey]
				_chart_meta_diff[track + "|" + diff] = cached
				_chart_meta[track] = cached
				continue
			var f: = FileAccess.open(cpath, FileAccess.READ)
			if f == null:
				continue
			var parsed = JSON.parse_string(f.get_as_text())
			f.close()
			if not (parsed is Dictionary):
				continue
			var d: Dictionary = parsed






			var notes: Array = d.get("notes", []) if d.get("notes", []) is Array else []



			var taps: = notes.size()
			var last_t: = 0.0
			for n in notes:
				if not (n is Dictionary):
					continue
				last_t = maxf(last_t, float(n.get("time", 0.0)))
				if String(n.get("type", "")) == "clickx":
					taps += (n.get("extra", []) as Array).size()
			var meta: = {
				"bpm": float(d.get("bpm", 0.0)), 
				"notes": taps, 

				"dur": last_t, 




				"rate": _rate_cached(cpath, d), 
			}
			_scan_cache[ckey] = meta
			scan_dirty = true
			_chart_meta_diff[track + "|" + diff] = meta


			_chart_meta[track] = meta
		if diffs.is_empty():
			continue




		if MapLibrary.is_user_map(track):



			for pair in [[MapLibrary.IMG_COVER, track_covers], 
					[MapLibrary.IMG_BACKGROUND, track_bgs]]:
				var path: = MapLibrary.image_path(track, String(pair[0]))
				if path != "":
					(pair[1] as MapImages).register(track, path)


			var uvid: = MapLibrary.video_path(track)
			if uvid != "":
				track_videos[track] = uvid
			continue


		var chart_path: String = diffs[diffs.keys()[diffs.size() - 1]]
		var slug: String = chart_path.get_file().split("_normal")[0].split("_hard")[0]\
		.split("_impossible")[0].split("_easy")[0].split("_corrupt")[0]


		for ext in ["jpg", "png", "jpeg", "webp"]:
			var bg_path: = "res://tracks/bg/%s.%s" % [slug, ext]
			if ResourceLoader.exists(bg_path):
				track_bgs.register(track, bg_path)
				track_covers.register(track, bg_path)
				break




		for ext in ["jpg", "png", "jpeg", "webp"]:
			var cover_path: = "res://tracks/cover/%s.%s" % [slug, ext]
			if ResourceLoader.exists(cover_path):
				track_covers.register(track, cover_path)
				break



		var base_slug: = RegEx.create_from_string("_v\\d+$").sub(slug, "")
		for cand in [slug, base_slug]:
			var vid_path: = "res://tracks/bg/%s.ogv" % cand
			if ResourceLoader.exists(vid_path):
				track_videos[track] = vid_path
				break
	if scan_dirty:
		_scan_cache_save()










const SCAN_CACHE_PATH: = "user://cache/chart_scan.json"
var _scan_cache: = {}
var _scan_seen: = {}


func _scan_cache_load() -> void :
	if not _scan_cache.is_empty():
		return
	var f: = FileAccess.open(SCAN_CACHE_PATH, FileAccess.READ)
	if f == null:
		return


	var parsed = str_to_var(f.get_as_text())
	f.close()
	if parsed is Dictionary:
		_scan_cache = parsed


func _scan_cache_save() -> void :


	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path("user://cache"))



	var keep: = {}
	for k in _scan_seen:
		if _scan_cache.has(k):
			keep[k] = _scan_cache[k]
	_scan_cache = keep
	var f: = FileAccess.open(SCAN_CACHE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(var_to_str(_scan_cache))
	f.close()



func _meta_current() -> Dictionary:
	return _chart_meta_diff.get(tuning.current_track + "|" + tuning.current_diff, 
		_chart_meta.get(tuning.current_track, {}))








func _rec_key(track: String, diff: String, mode: = "") -> String:
	var base: = track if diff == "impossible" else track + "|" + diff
	var m: = mode if mode != "" else Mods.mode_key()
	return base if m == "STANDARD" else base + "@" + m


func _build_menu() -> void :
	var vs: = get_viewport_rect().size
	menu_root = Control.new()
	menu_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(menu_root)









	home_screen = Control.new()
	home_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	home_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_root.add_child(home_screen)



	menu_intro = MenuIntro.new()
	menu_intro.main = self
	home_screen.add_child(menu_intro)








	orbit_menu = OrbitMenu.new()
	orbit_menu.glow_tex = glow_tex
	home_screen.add_child(orbit_menu)
	orbit_menu.set_font(font_display)
	orbit_menu.activated.connect(_menu_activated)
	orbit_menu.button_hovered.connect(_on_orbit_hover)
	play_button = orbit_menu.buttons[1]
	play_button.set_meta("ui_sound", "menu_play")
	orbit_menu.buttons[0].set_meta("ui_sound", "click")
	orbit_menu.buttons[2].set_meta("ui_sound", "click")





	for sd in [AME_DATA, KOHA_DATA]:
		var side: Node2D = MASCOT_SCENE.instantiate()
		side.data = sd
		side.display_scale = 1.5
		side.hover_glow_enabled = true
		side.playful = true
		side.spin_enabled = false
		home_screen.add_child(side)
		menu_side_mascots.append(side)


	menu_side_mascots[0].hover_stages = [
		[0.5, [&"joueuse"]], 
		[3.5, [&"disgust"]], 
		[6.5, [&"annoyed"]], 
	]

	menu_side_mascots[1].hover_stages = [
		[0.5, [&"intrigued"]], 
		[3.5, [&"annoyed"]], 
		[6.5, [&"angry"]], 
	]
	orb_menu = MASCOT_SCENE.instantiate()
	orb_menu.data = LARI_DATA
	orb_menu.display_scale = 2.2
	orb_menu.playful = true
	orb_menu.hover_glow_enabled = true
	home_screen.add_child(orb_menu)


	orb_menu.spin_stage_changed.connect(_on_center_spin_stage)


	var mascot_hit: = Button.new()
	mascot_hit.focus_mode = Control.FOCUS_NONE
	mascot_hit.custom_minimum_size = Vector2(102, 102)
	mascot_hit.size = Vector2(102, 102)



	var mh_empty: = StyleBoxEmpty.new()
	for st_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		mascot_hit.add_theme_stylebox_override(st_name, mh_empty)
	mascot_hit.pressed.connect(_toggle_orbit)
	mascot_hit.set_meta("ui_sound", "menu_open")
	mascot_hit.name = "MascotHit"
	home_screen.add_child(mascot_hit)
	mascot_button = mascot_hit


	home_title = Control.new()
	home_title.position = Vector2(52, 42)
	home_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	home_screen.add_child(home_title)
	var title: = Label.new()
	title.text = "M E L O A"
	title.add_theme_font_size_override("font_size", 34)
	if font_logo:
		title.add_theme_font_override("font", font_logo)
	home_title.add_child(title)
	_gradient_text(title, Color(1.04, 1.04, 1.07), Color(0.84, 0.97, 1.07), 
		Color(1.02, 0.82, 1.06), 1.18)
	var subtitle: = Label.new()
	subtitle.text = "O P E N   P L A Y T E S T"
	subtitle.position = Vector2(3, 48)
	subtitle.add_theme_font_size_override("font_size", 10)
	subtitle.add_theme_color_override("font_color", Color(0.8, 0.7, 1.0, 0.42))
	if font_bold:
		subtitle.add_theme_font_override("font", font_bold)
	home_title.add_child(subtitle)




	home_secondary = Control.new()
	home_secondary.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	home_secondary.mouse_filter = Control.MOUSE_FILTER_IGNORE
	home_screen.add_child(home_secondary)
	var secondary: Array = [
		["help", "TUTORIAL", Callable(self, "start_tutorial"), COL_PERFECT], 
		["account", "ACCOUNT", Callable(self, "_toggle_account_panel"), COL_ACCENT], 


		["settings", "SETTINGS", Callable(self, "_open_settings"), Color(0.72, 0.45, 1.0)], 
		["quit", "QUIT", Callable(self, "_quit_game"), COL_GOLD], 
	]
	for i in secondary.size():
		var e: Array = secondary[i]
		var b: = _secondary_icon(home_secondary, e[0], e[1], e[2], e[3])
		b.position = Vector2( - (secondary.size() - i) * 52.0 - 14.0, 34.0)
		if e[0] == "account":


			account_name_label = b.get_node("Reveal")

			var dot: = Panel.new()
			dot.position = Vector2(29, 3)
			dot.custom_minimum_size = Vector2(7, 7)
			dot.size = Vector2(7, 7)
			var dst: = StyleBoxFlat.new()
			dst.bg_color = Color(0.72, 0.45, 1.0)
			dst.set_corner_radius_all(4)
			dot.add_theme_stylebox_override("panel", dst)
			dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			dot.visible = Backend.is_logged_in()
			b.add_child(dot)
			account_dot = dot




	now_bar = NowPlayingBar.new()
	now_bar.main = self
	now_bar.beat_bus = beat_bus
	home_screen.add_child(now_bar)
	now_bar.set_fonts(font_bold, font_bold)


	_build_mod_presence()

	_build_account_panel()


	menu_intro.orb = orb_menu
	menu_intro.sides = menu_side_mascots




	var idle_react: = Timer.new()
	idle_react.name = "MascotIdleReact"
	idle_react.one_shot = true
	idle_react.wait_time = randf_range(14.0, 28.0)
	idle_react.autostart = true
	add_child(idle_react)
	idle_react.timeout.connect( func() -> void :
		if screen == Screen.HOME\
		and (menu_intro == null or not menu_intro.is_running()):
			var trio: Array = [orb_menu] + menu_side_mascots
			(trio.pick_random() as Node2D).idle_flourish()
		idle_react.wait_time = randf_range(14.0, 28.0)
		idle_react.start())
	menu_intro.background = background
	menu_intro.late_bits = [home_title, home_secondary, now_bar]
	if mod_presence != null:
		menu_intro.late_bits.append(mod_presence)

	_layout_home()
	get_viewport().size_changed.connect(_layout_home)



	stats_panel = PanelContainer.new()
	stats_panel.visible = false
	stats_panel.position = Vector2(vs.x * 0.5 - 280.0, 150)
	stats_panel.custom_minimum_size = Vector2(560, 0)
	var stp: = _chip(Color(0.045, 0.055, 0.11, 0.96), Color(0.72, 0.45, 1.0, 0.55), 14, 16)
	stp.set_border_width_all(2)
	stp.shadow_color = Color(0.72, 0.45, 1.0, 0.18)
	stats_panel.add_theme_stylebox_override("panel", stp)
	home_screen.add_child(stats_panel)
	var svb: = VBoxContainer.new()
	svb.add_theme_constant_override("separation", 8)
	stats_panel.add_child(svb)
	var sthead: = Label.new()
	sthead.text = "STATS  ·  LOCAL RECORDS"
	sthead.add_theme_font_size_override("font_size", 17)
	if font_display:
		sthead.add_theme_font_override("font", font_display)
	sthead.add_theme_color_override("font_color", Color(0.85, 0.7, 1.05))
	svb.add_child(sthead)
	stats_body = Label.new()
	stats_body.add_theme_font_size_override("font_size", 14)
	stats_body.add_theme_color_override("font_color", Color(1, 1, 1, 0.75))
	svb.add_child(stats_body)




	credits_panel = PanelContainer.new()
	credits_panel.visible = false
	credits_panel.position = Vector2(vs.x * 0.5 - 280.0, 140)
	credits_panel.custom_minimum_size = Vector2(560, 0)
	var crp: = _chip(Color(0.045, 0.055, 0.11, 1.0), Color(0.45, 0.82, 1.0, 0.5), 14, 16)
	crp.set_border_width_all(2)
	crp.shadow_color = Color(0.45, 0.82, 1.0, 0.16)
	credits_panel.add_theme_stylebox_override("panel", crp)
	home_screen.add_child(credits_panel)
	var cvb: = VBoxContainer.new()
	cvb.add_theme_constant_override("separation", 8)
	credits_panel.add_child(cvb)
	var crhead: = Label.new()
	crhead.text = "CREDITS"
	crhead.add_theme_font_size_override("font_size", 17)
	if font_display:
		crhead.add_theme_font_override("font", font_display)
	crhead.add_theme_color_override("font_color", Color(0.55, 0.9, 1.05))
	cvb.add_child(crhead)
	var crbody: = Label.new()
	var credits: = "A rhythm game by Benson.\n\nMusic"
	for track in TRACK_INFO:
		credits += "\n·  %s — %s" % [track, TRACK_INFO[track]]
	credits += "\n\nFonts   Fredoka · Nunito Sans (SIL OFL)"
	credits += "\nEngine   Godot 4.7"
	crbody.text = credits
	crbody.add_theme_font_size_override("font_size", 14)
	crbody.add_theme_color_override("font_color", Color(1, 1, 1, 0.75))
	cvb.add_child(crbody)






	select_screen = MapSelect.new()
	select_screen.main = self
	menu_root.add_child(select_screen)
	map_select = select_screen


	select_center = map_select.center_zone
	select_cover = map_select.cover_ring.cover_rect()




	player_badge = PlayerBadge.new()
	player_badge.set_fonts(font_display, font_body)
	select_screen.add_child(player_badge)
	player_badge.pressed.connect(_open_global_leaderboard)
	map_select.badge_root = player_badge
	_refresh_rank_badges()






func _layout_home() -> void :
	if orbit_menu == null:
		return
	var vs: = get_viewport_rect().size


	var c: = Vector2(vs.x * 0.5, vs.y * 0.44)
	orb_menu.position = c

	if menu_side_mascots.size() == 2:
		menu_side_mascots[0].position = c + Vector2(-165.0, 30.0)
		menu_side_mascots[1].position = c + Vector2(165.0, 30.0)
	var hit: Control = home_screen.get_node_or_null("MascotHit")
	if hit != null:
		hit.position = c - hit.size * 0.5



	orbit_menu.center = c
	orbit_menu.ry = vs.y * 0.365
	var wide: = clampf((vs.x / maxf(vs.y, 1.0)) / (16.0 / 9.0), 0.9, 1.26)
	orbit_menu.rx = orbit_menu.ry * 1.45 * wide
	orbit_menu.layout()
	if now_bar != null:
		now_bar.position = Vector2(52.0, vs.y - now_bar.size.y - 26.0)


	if mod_presence != null and is_instance_valid(mod_presence):
		mod_presence.position = Vector2(vs.x - mod_presence.size.x - 40.0, 
			vs.y - mod_presence.size.y - 30.0)




func _secondary_icon(parent: Control, kind: String, text: String, 
		action: Callable, accent: Color) -> Button:
	var b: = Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(38, 38)
	b.size = Vector2(38, 38)
	b.pivot_offset = Vector2(19, 19)
	b.tooltip_text = text.capitalize()

	b.add_theme_stylebox_override("normal", 
		_chip(Color(0, 0, 0, 0.0), Color(1, 1, 1, 0.1), 19, 0))
	var hov: = _chip(Color(accent.r, accent.g, accent.b, 0.1), 
		Color(accent.r, accent.g, accent.b, 0.55), 19, 0)
	b.add_theme_stylebox_override("hover", hov)
	b.add_theme_stylebox_override("pressed", hov)
	b.pressed.connect(action)
	parent.add_child(b)
	var ic: = UiIcon.new()
	ic.kind = kind
	ic.tint = Color(1, 1, 1, 0.66)
	ic.position = Vector2(10, 10)
	ic.size = Vector2(18, 18)
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(ic)

	var lb: = Label.new()
	lb.text = text
	lb.size = Vector2(140, 14)
	lb.position = Vector2(19 - 70, 42)
	lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lb.add_theme_font_size_override("font_size", 9)
	lb.add_theme_color_override("font_color", Color(accent.r, accent.g, accent.b, 0.9))
	if font_bold:
		lb.add_theme_font_override("font", font_bold)
	lb.modulate.a = 0.0
	lb.name = "Reveal"
	b.add_child(lb)
	b.mouse_entered.connect( func() -> void :
		ic.tint = Color(1, 1, 1, 1.0)
		ic.queue_redraw()
		_icon_reveal(b, lb, true))
	b.mouse_exited.connect( func() -> void :
		ic.tint = Color(1, 1, 1, 0.66)
		ic.queue_redraw()
		_icon_reveal(b, lb, false))
	return b

















const MOD_PRESENCE_REFRESH: = 20.0

func _build_mod_presence() -> void :


	if not Backend.auth_changed.is_connected(_sync_mod_presence):
		Backend.auth_changed.connect(_sync_mod_presence)
	_sync_mod_presence(Backend.is_logged_in(), Backend.username)


func _sync_mod_presence(_logged: bool, _name: String) -> void :
	if home_screen == null or not is_inside_tree():
		return
	var old_beat: = get_node_or_null("ModPresenceBeat")
	if not Backend.is_mod():
		if mod_presence != null and is_instance_valid(mod_presence):
			mod_presence.queue_free()
		if old_beat != null:
			old_beat.queue_free()
		mod_presence = null
		return
	if mod_presence != null and is_instance_valid(mod_presence):
		return
	var b: = Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(196, 26)
	b.size = Vector2(196, 26)
	b.text = "MOD  ·  · · ·"
	b.tooltip_text = "Players online right now (moderator view).\nClick to refresh."
	b.add_theme_font_size_override("font_size", 11)
	if font_bold:
		b.add_theme_font_override("font", font_bold)
	b.add_theme_color_override("font_color", Color(0.72, 0.45, 1.0, 0.62))
	b.add_theme_color_override("font_hover_color", Color(0.85, 0.65, 1.0, 0.95))
	b.add_theme_color_override("font_pressed_color", Color(0.85, 0.65, 1.0, 0.95))
	b.add_theme_stylebox_override("normal", 
		_chip(Color(0.72, 0.45, 1.0, 0.05), Color(0.72, 0.45, 1.0, 0.16), 13, 0))
	var hov: = _chip(Color(0.72, 0.45, 1.0, 0.12), Color(0.72, 0.45, 1.0, 0.45), 13, 0)
	b.add_theme_stylebox_override("hover", hov)
	b.add_theme_stylebox_override("pressed", hov)
	b.pressed.connect(_refresh_mod_presence)
	home_screen.add_child(b)
	mod_presence = b
	var beat: = Timer.new()
	beat.name = "ModPresenceBeat"
	beat.wait_time = MOD_PRESENCE_REFRESH
	beat.autostart = true
	beat.timeout.connect(_refresh_mod_presence)
	add_child(beat)
	_refresh_mod_presence()







func _refresh_mod_presence() -> void :
	if mod_presence == null or _mod_presence_busy:
		return


	if screen != Screen.HOME or not is_instance_valid(mod_presence):
		return
	_mod_presence_busy = true
	var r: Dictionary = await Backend.api_admin_presence()
	_mod_presence_busy = false
	if not is_instance_valid(mod_presence):
		return
	if r.code == 404:
		mod_presence.text = "MOD  ·  PRESENCE NOT DEPLOYED"
		mod_presence.tooltip_text = "The /presence module is not live on the server yet."
		mod_presence.add_theme_color_override("font_color", Color(1.0, 0.65, 0.35, 0.55))
		return
	if not r.ok or not (r.data is Dictionary):
		mod_presence.text = "MOD  ·  OFFLINE"
		mod_presence.tooltip_text = "Server unreachable (code %d)." % int(r.code)
		mod_presence.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45, 0.55))
		return
	var d: Dictionary = r.data
	var in_game: = int(d.get("inGame", 0))
	var online: = int(d.get("online", 0))
	var in_editor: = int(d.get("inEditor", 0))
	mod_presence.text = "%s  %d IN GAME  ·  %d ONLINE" % [
		"●" if in_game > 0 else "○", in_game, online]


	mod_presence.add_theme_color_override("font_color", 
		Color(0.45, 1.0, 0.75, 0.85) if in_game > 0
		else Color(0.72, 0.45, 1.0, 0.62))
	mod_presence.tooltip_text = _mod_presence_detail(d, in_editor)



func _mod_presence_detail(d: Dictionary, in_editor: int) -> String:
	var lines: Array = ["PRESENCE  ·  moderator view"]
	lines.append("%d online — %d in game, %d in menu, %d in editor" % [
		int(d.get("online", 0)), int(d.get("inGame", 0)), 
		int(d.get("inMenu", 0)), in_editor])
	var maps: Array = d.get("playingMaps", []) if d.get("playingMaps", []) is Array else []
	if not maps.is_empty():
		lines.append("")
		lines.append("Being played:")
		for m in maps.slice(0, 6):
			if not (m is Dictionary):
				continue
			lines.append("  %d ×  %s  [%s]" % [int(m.get("count", 0)), 
				String(m.get("mapId", "?")), String(m.get("difficulty", "-"))])
	var vers: Array = d.get("byVersion", []) if d.get("byVersion", []) is Array else []
	if not vers.is_empty():
		lines.append("")
		lines.append("Client versions:")
		for v in vers.slice(0, 5):
			if not (v is Dictionary):
				continue
			lines.append("  %s  ×%d" % [String(v.get("version", "?")), 
				int(v.get("count", 0))])


	lines.append("")
	lines.append("A player drops off after %ds without a heartbeat."
		%int(d.get("windowSec", 75)))
	lines.append("Server up since %s" % String(d.get("serverStartedAt", "?")))
	return "\n".join(lines)


func _icon_reveal(b: Button, lb: Label, on: bool) -> void :
	var tw: = b.create_tween()
	tw.tween_property(b, "scale", Vector2.ONE * (1.1 if on else 1.0), 0.14)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.parallel().tween_property(lb, "modulate:a", 1.0 if on else 0.0, 0.14)
	tw.parallel().tween_property(lb, "position:y", 42.0 if on else 38.0, 0.16)\
	.set_ease(Tween.EASE_OUT)




func _load_menu_background() -> void :
	for ext in ["png", "jpg", "jpeg", "webp"]:
		var path: String = MENU_BG_DIR + "background." + ext
		if ResourceLoader.exists(path):
			menu_bg_tex = load(path)
			return



func _quit_game() -> void :
	Telemetry.quit_game()







func _toggle_orbit() -> void :
	if _transitioning:
		return


	if menu_intro != null and menu_intro.is_running():
		menu_intro.skip()
		return
	if crosshair_node != null:
		crosshair_node.ping()


	if orbit_menu.is_open:
		orbit_menu.close()
		orb_menu.play_reaction(&"happy", 0.45)
		if mascot_button != null:
			mascot_button.set_meta("ui_sound", "back")
	else:
		orbit_menu.open()
		orb_menu.play_reaction(&"excited", 0.55)
		if mascot_button != null:
			mascot_button.set_meta("ui_sound", "menu_open")


	orb_menu.beat_kick(1.0)
	var tw: = orb_menu.create_tween()
	tw.tween_property(orb_menu, "scale", Vector2(1.1, 1.1), 0.08)\
	.set_ease(Tween.EASE_OUT)
	tw.tween_property(orb_menu, "scale", Vector2.ONE, 0.22)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)



func _menu_activated(id: String) -> void :
	if _transitioning:
		return
	if crosshair_node != null:
		crosshair_node.ping()
	match id:
		"play":
			_go_select_animated()
		"multiplayer":
			_go_multiplayer()
		"editor":
			_go_editor()





func _on_orbit_hover(index: int) -> void :
	_menu_hover_idx = index
	if index >= 0:
		orb_menu.set_look_target(orbit_menu.button_global(index))





func _on_menu_beat(_index: int) -> void :
	if screen == Screen.PLAYING:
		return
	var s: = SettingsManager.menu_fx_intensity
	if s <= 0.001:
		return
	if background != null:
		background.on_beat(0.25 * s)
	if screen != Screen.HOME:
		return
	if orbit_menu != null:
		orbit_menu.on_beat(0.25 * s)
	if orb_menu != null:
		orb_menu.beat_kick(0.15 * s)
	for sm in menu_side_mascots:
		sm.beat_kick(0.12 * s)
	if now_bar != null:
		now_bar.on_beat(0.6 * s)




func _on_menu_strong_beat(_index: int) -> void :
	if screen == Screen.PLAYING:
		return
	var s: = SettingsManager.menu_fx_intensity
	if s <= 0.001:
		return
	if background != null:
		background.on_beat(0.5 * s)
	if screen != Screen.HOME:
		return
	if orbit_menu != null:
		orbit_menu.on_strong_beat(0.5 * s)
	if orb_menu != null:
		orb_menu.beat_kick(0.3 * s)
	for sm in menu_side_mascots:
		sm.beat_kick(0.24 * s)




func _go_multiplayer() -> void :
	orb_menu.play_reaction(&"sad", 0.9)
	_menu_toast("MULTIPLAYER  ·  COMING SOON !", COL_PERFECT)










func _go_editor() -> void :
	orbit_menu.converge_to(2)
	await get_tree().create_timer(0.2).timeout
	_open_new_map()



var _new_map_ui: Control = null

var _pending_drop_audio: = ""


func _open_new_map() -> void :
	var screen_node = load("res://scripts/editor_ui/ed_new_map.gd").new()
	screen_node.main = self
	screen_node.done.connect(_on_new_map_done)
	ui_layer.add_child(screen_node)
	ui_layer.move_child(screen_node, ui_layer.get_child_count() - 2)
	_new_map_ui = screen_node
	if _pending_drop_audio != "":
		screen_node.pick_audio(_pending_drop_audio)
		_pending_drop_audio = ""







func _on_files_dropped(files: PackedStringArray) -> void :
	if files.is_empty():
		return
	var path: = String(files[0])
	var ext: = path.get_extension().to_lower()
	if ext in MapLibrary.AUDIO_EXT:
		if _new_map_ui != null and is_instance_valid(_new_map_ui):
			_new_map_ui.pick_audio(path)
			return
		if screen == Screen.HOME and editor == null and not _transitioning:
			_pending_drop_audio = path
			_go_editor()
			return
		_screen_toast("DROP THE AUDIO ON THE HOME SCREEN OR THE NEW MAP FORM", COL_ACCENT)
		return
	if ext == "zip" or DirAccess.dir_exists_absolute(path):
		if screen == Screen.PLAYING or screen == Screen.EDITOR:
			_screen_toast("DROP SKINS FROM THE MENUS, NOT DURING A MAP", COL_ACCENT)
			return
		var skin: = String(Skins.import_dropped(path))
		if skin == "":
			_screen_toast("NOT A SKIN: NO skin.json INSIDE " + path.get_file().to_upper(), COL_RED)
			return
		if settings_ui != null:
			settings_ui.refresh_skins()
		_ask_apply_skin(skin)
		return
	_screen_toast("UNSUPPORTED FILE: " + path.get_file().to_upper(), COL_RED)




func _ask_apply_skin(skin: String) -> void :
	var host: = Control.new()
	host.set_anchors_preset(Control.PRESET_FULL_RECT)
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(host)
	ui_layer.move_child(host, ui_layer.get_child_count() - 2)
	var label: = String(Skins.label_of(skin))


	var fb: Font = font_bold if font_bold != null else ThemeDB.fallback_font
	var dlg = load("res://scripts/editor_ui/ed_dialog.gd").choices(host, 
		{"font": fb, "font_display": font_display if font_display != null else fb, 
			"main": self}, 
		"SKIN INSTALLED", "\"%s\" was added to your skins.\nApply it now?" % label, 
		[{"text": "NO", "id": ""}, {"text": "YES", "id": "ok", 
			"accent": Color(0.3, 1.0, 0.85)}], 
		func(id: String) -> void :
			if id == "ok":
				Skins.apply(skin)
				if settings_ui != null:
					settings_ui.refresh_skins()
				_screen_toast("SKIN APPLIED: " + label.to_upper(), COL_PERFECT)
			else:
				_screen_toast("SKIN INSTALLED — SETTINGS > VISUAL > SKIN TO USE IT", COL_ACCENT)
			host.queue_free())
	_update_mouse_mode()
	if dlg == null:
		host.queue_free()


func _on_new_map_done(draft: Dictionary) -> void :
	_new_map_ui = null
	if draft.is_empty():


		sfx.play_ui("back")
		orbit_menu.reset()
		orbit_menu.open()
		return
	_open_editor(draft)






func _on_center_spin_stage(stage: int) -> void :
	_center_spin_stage = stage
	if menu_side_mascots.size() < 2:
		return
	var ame: Node2D = menu_side_mascots[0]
	var koha: Node2D = menu_side_mascots[1]
	for sm in [ame, koha]:
		sm.set_look_target(orb_menu if stage > 0 else null)
	match stage:
		0:
			ame.set_mood([&"neutral"])
			koha.set_mood([&"neutral"])
		1:
			ame.set_mood([&"stunned", &"surprised", &"blank"])
			koha.set_mood([&"intrigued"])
		2:
			ame.set_mood([&"laugh", &"lmfao", &"happy"])
			koha.set_mood([&"smile"])
		3:
			ame.set_mood([&"scared", &"surprised"])
			koha.set_mood([&"scared", &"panic"])









func _screen_toast(text: String, col: Color) -> void :
	if ui_layer == null:
		push_warning(text)
		return
	var vs: = get_viewport_rect().size
	var l: = Label.new()
	l.text = text
	l.size = Vector2(vs.x, 26)
	l.position = Vector2(0.0, vs.y * 0.16)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", 17)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.65))
	l.add_theme_constant_override("outline_size", 6)
	if font_bold:
		l.add_theme_font_override("font", font_bold)
	l.modulate.a = 0.0
	ui_layer.add_child(l)
	var tw: = l.create_tween()
	tw.tween_property(l, "modulate:a", 1.0, 0.14)
	tw.tween_interval(2.4)
	tw.tween_property(l, "modulate:a", 0.0, 0.35)
	tw.tween_callback(l.queue_free)


func _menu_toast(text: String, col: Color) -> void :
	var vs: = get_viewport_rect().size
	var l: = Label.new()
	l.text = text
	l.size = Vector2(vs.x, 24)
	l.position = Vector2(0.0, vs.y * 0.44 + 96.0)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", 15)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.5))
	l.add_theme_constant_override("outline_size", 5)
	if font_bold:
		l.add_theme_font_override("font", font_bold)
	l.modulate.a = 0.0
	home_screen.add_child(l)
	var tw: = l.create_tween()
	tw.tween_property(l, "modulate:a", 1.0, 0.14)
	tw.parallel().tween_property(l, "position:y", l.position.y - 12.0, 0.3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_interval(1.15)
	tw.tween_property(l, "modulate:a", 0.0, 0.35)
	tw.tween_callback(l.queue_free)




func _gradient_text(label: Label, ca: Color, cb: Color, cc: Color, boost: = 1.0) -> void :
	if _grad_shader == null:
		_grad_shader = Shader.new()
		_grad_shader.code = GRADIENT_TEXT_SHADER
	var mat: = ShaderMaterial.new()
	mat.shader = _grad_shader
	mat.set_shader_parameter("col_a", ca)
	mat.set_shader_parameter("col_b", cb)
	mat.set_shader_parameter("col_c", cc)
	mat.set_shader_parameter("width", label.get_minimum_size().x)
	mat.set_shader_parameter("boost", boost)
	label.material = mat





func _refresh_rank_badges(force: = false) -> void :
	if force and Backend.is_logged_in():
		var r: Dictionary = await Backend.global_me()
		_global_rank = r.data if r.ok and r.data is Dictionary else {}
	if player_badge != null and is_instance_valid(player_badge):
		player_badge.set_state(Backend.is_logged_in(), Backend.username, _global_rank)



func _toggle_stats() -> void :
	credits_panel.visible = false
	stats_panel.visible = not stats_panel.visible
	if not stats_panel.visible:
		return


	var txt: = """Global best score  %d    ·    max combo  %d
""" %[best_score, best_combo]
	var any: = false
	for track in MapLibrary.tracks():
		var rec: Dictionary = map_records.get(str(track), {})
		if rec.has("score"):
			any = true
			txt += """
%s      %d    (grade %s, combo x%d)""" %[track_title(track), int(rec.score), rec.grade, 
				int(rec.combo)]
	if not any:
		txt += "\nNo map records yet — go play one!"
	stats_body.text = txt


func _toggle_credits() -> void :

	home_screen.move_child(credits_panel, home_screen.get_child_count() - 1)
	stats_panel.visible = false
	credits_panel.visible = not credits_panel.visible






func _select_track(track: String) -> void :
	if _transitioning or map_select == null:
		return
	map_select.select_map(track)




func _random_track() -> void :
	if _transitioning or map_select == null:
		return
	map_select.random_map()




var _rate_cache: = {}

func _rate_cached(path: String, data: Dictionary) -> Dictionary:
	var key: = "%s|%d" % [path, FileAccess.get_modified_time(path)]
	if not _rate_cache.has(key):
		_rate_cache[key] = ChartRatingLib.rate(data)
	return _rate_cache[key]





func _density_level(meta: Dictionary) -> float:
	return float((meta.get("rate", {}) as Dictionary).get("level", 0.0))



func _tier_for(charge: float) -> Array:
	return ChartRatingLib.tier_for(charge)



func _density_pips(meta: Dictionary) -> int:
	return clampi(roundi(_density_level(meta) / 4.0) + 1, 1, 6)





func _refresh_select_panel() -> void :
	if map_select != null:
		map_select.refresh_all()










func _launch(track: String, chart_override: = "") -> void :



	if map_select != null:
		map_select.flush_chart()
	if _transitioning or _is_locked(track):
		return
	_transitioning = true
	tuning.apply_track(track)
	if chart_override != "":
		tuning.chart_path = chart_override
	_load_chart()





	if chart_error != "":
		_transitioning = false
		_screen_toast("MAP UNAVAILABLE — " + chart_error, COL_RED)
		return

	if not gauntlet:
		Telemetry.map_started(track, tuning.current_diff)
	if chart_warning != "":
		_screen_toast(chart_warning.to_upper(), COL_GOLD)
	_update_now_playing()
	var vs: = get_viewport_rect().size

	var ctw: = select_center.create_tween()
	ctw.tween_property(select_center, "scale", Vector2(1.04, 1.04), 0.1)\
	.set_ease(Tween.EASE_OUT)
	ctw.parallel().tween_property(select_center, "modulate", Color(1.25, 1.25, 1.3), 0.1)
	await get_tree().create_timer(0.08).timeout


	sfx.play_ui("riser")
	sfx.play_ui("whoosh")
	_tween_lowpass(500.0, 0.35)
	var vol_tw: = create_tween()
	vol_tw.tween_property(conductor, "volume_db", music_db() - 26.0, 0.55)
	var mtw: = menu_root.create_tween()
	mtw.tween_property(menu_root, "modulate:a", 0.0, 0.3)

	var ob: Array = _make_cover_bands(select_cover)
	var overlay: Control = ob[0]
	var bands: Array = ob[1]
	for i in 3:
		var b: Control = bands[i]
		var tw: = b.create_tween()
		tw.tween_property(b, "position", Vector2(vs.x * i / 3.0, 0.0), 0.34)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tw.parallel().tween_property(b, "size", Vector2(vs.x / 3.0, vs.y), 0.34)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await get_tree().create_timer(0.36).timeout

	screen = Screen.PLAYING
	_pre_roll = true
	menu_root.visible = false
	menu_root.modulate = Color.WHITE
	select_center.scale = Vector2.ONE
	select_center.modulate = Color.WHITE
	world.visible = true
	world.modulate.a = 0.0
	var rev_tw: = world.create_tween()
	rev_tw.tween_property(world, "modulate:a", 1.0, 0.3)
	hud_root.visible = true
	end_panel.visible = false
	_hud_fly_in()


	var half: = tuning.lane_width * 0.5
	for i in 3:
		var b: Control = bands[i]
		var lc: Color = LANE_COLS[i]
		var tw2: = b.create_tween()
		tw2.tween_interval(0.05 * i)
		tw2.tween_property(b, "position", Vector2(lane_x(i) - half, 0.0), 0.3)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tw2.parallel().tween_property(b, "size", Vector2(tuning.lane_width, vs.y), 0.3)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tw2.parallel().tween_property(b, "modulate", Color(lc.r, lc.g, lc.b, 0.9), 0.3)
		tw2.tween_property(b, "modulate:a", 0.0, 0.24)
	await get_tree().create_timer(0.44).timeout

	sfx.play_ui("impact")
	_flash_line(neon(Color(0.9, 0.95, 1.0), 1.3), 1.0)
	_shake("events", 3.0)
	await get_tree().create_timer(0.2).timeout
	overlay.queue_free()

	var step: = clampf(60.0 / chart_bpm, 0.18, 0.35)
	for txt in ["3", "2", "1"]:
		_countdown_pop(txt, COL_PERFECT, false)
		await get_tree().create_timer(step).timeout
	_countdown_pop("GO", COL_ACCENT, true)
	_pre_roll = false
	_transitioning = false
	_tween_lowpass(LP_OPEN, 0.1)
	conductor.volume_db = music_db()
	start_game()






func _make_cover_bands(card: Control) -> Array:
	var vs: = get_viewport_rect().size
	var overlay: = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(overlay)
	var cover: Texture2D = track_covers.tex(tuning.current_track)
	var start: = Rect2(vs.x * 0.5 - 300.0, vs.y * 0.5 - 39.0, 600.0, 78.0)
	if card != null:
		start = card.get_global_rect()
	var bands: Array = []
	for i in 3:
		var band: Control
		if cover != null:
			var tr: = TextureRect.new()
			var at: = AtlasTexture.new()
			at.atlas = cover
			var cs: Vector2 = cover.get_size()
			at.region = Rect2(cs.x * i / 3.0, 0.0, cs.x / 3.0, cs.y)
			tr.texture = at
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			band = tr
		else:
			var p: = Panel.new()
			var c: Color = LANE_COLS[i]
			var sb: = StyleBoxFlat.new()
			sb.bg_color = Color(c.r * 0.22, c.g * 0.22, c.b * 0.22, 0.96)
			sb.border_color = c
			sb.set_border_width_all(2)
			p.add_theme_stylebox_override("panel", sb)
			band = p
		band.mouse_filter = Control.MOUSE_FILTER_IGNORE
		band.position = Vector2(start.position.x + start.size.x * i / 3.0, 
			start.position.y)
		band.size = Vector2(start.size.x / 3.0, start.size.y)
		overlay.add_child(band)
		bands.append(band)
	return [overlay, bands]




func _hud_fly_in() -> void :
	hud_root.modulate.a = 1.0
	_fly_in(_hud_score_box, Vector2(-60, 0), 0.0)
	_fly_in(_hud_hp_box, Vector2(60, 0), 0.05)
	_fly_in(_hud_acc_box, Vector2(-60, 0), 0.12)
	_fly_in(_hud_time_box, Vector2(60, 0), 0.16)


func _fly_in(node: Control, offset: Vector2, delay: float) -> void :
	var base: = node.position
	node.position = base + offset
	node.modulate.a = 0.0
	var tw: = node.create_tween()
	tw.tween_interval(delay)
	tw.tween_property(node, "modulate:a", 1.0, 0.18)
	tw.parallel().tween_property(node, "position", base, 0.26)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)



func _countdown_pop(text: String, color: Color, go: bool) -> void :
	sfx.play_ui("count_go" if go else "count_tick")
	judge_label.text = text
	timing_label.text = ""
	judge_label.add_theme_color_override("font_color", neon(color, 1.2))
	judge_label.modulate = Color(1.5, 1.5, 1.5)
	judge_label.scale = Vector2(1.6, 1.6)
	judge_label.rotation = 0.0
	if _judge_tw:
		_judge_tw.kill()
	_judge_tw = judge_label.create_tween()
	_judge_tw.tween_property(judge_label, "scale", Vector2.ONE, 0.16)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_judge_tw.parallel().tween_property(judge_label, "modulate", Color.WHITE, 0.14)
	_judge_tw.tween_interval(0.1)
	_judge_tw.tween_property(judge_label, "modulate:a", 0.0, 0.18)
	if go:
		_spawn_shockwave(Vector2(get_viewport_rect().size.x * 0.5, tuning.hit_y), 
			220.0, Color(color.r, color.g, color.b, 0.6))










func _extinguish() -> void :
	on_fire = false
	fever = 0.0
	if player != null:
		player.fever = 0.0


func _exit_to_select() -> void :
	if _transitioning:
		return
	_transitioning = true
	_pre_roll = false
	_extinguish()
	_reset_lane_fx()
	_hide_game_over()



	if screen == Screen.PLAYING and not track_done and playtest_from < 0.0:
		Telemetry.map_abandoned(conductor.get_song_time())
	Telemetry.map_closed()
	sfx.play_ui("back")
	sfx.play_ui("whoosh")
	conductor.stop()
	for n in live_notes:
		if is_instance_valid(n):
			var col: Color = COL_GOLD if n.type == "click" or n.type == "clickx"\
			else LANE_COLS[n.lane]
			_spawn_burst(n.position, col, 8, 260.0)
			_release_note(n, false)
	live_notes.clear()
	var vs: = get_viewport_rect().size
	var half: = tuning.lane_width * 0.5

	var target: = select_cover.get_global_rect()
	var overlay: = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(overlay)
	for i in 3:
		var c: Color = LANE_COLS[i]
		var p: = ColorRect.new()
		p.color = Color(c.r, c.g, c.b, 0.3)
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		p.position = Vector2(lane_x(i) - half, 0.0)
		p.size = Vector2(tuning.lane_width, vs.y)
		overlay.add_child(p)
		var tw: = p.create_tween()
		tw.tween_property(p, "position", 
			Vector2(target.position.x + target.size.x * i / 3.0, target.position.y), 
			0.32).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tw.parallel().tween_property(p, "size", 
			Vector2(target.size.x / 3.0, target.size.y), 0.32)\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tw.parallel().tween_property(p, "color:a", 0.0, 0.36)
	var htw: = hud_root.create_tween()
	htw.tween_property(hud_root, "modulate:a", 0.0, 0.2)
	await get_tree().create_timer(0.26).timeout
	hud_root.modulate.a = 1.0
	_open_menu(Screen.SELECT)
	await get_tree().create_timer(0.3).timeout
	overlay.queue_free()
	_transitioning = false




func _play_preview() -> void :
	conductor.volume_db = music_db() - 6.0
	conductor.stream_paused = false



	conductor.play(maxf(0.0, 
		float(MapLibrary.meta_of(tuning.current_track).get("preview_time", 0.0))))


func _open_menu(s: int) -> void :
	var was_playing: = screen == Screen.PLAYING


	gauntlet = false
	if tutorial_ui != null and tutorial_ui.visible and not tutorial_active:
		tutorial_ui.visible = false
	screen = s
	world.visible = false
	hud_root.visible = false
	menu_root.visible = true



	if _gate_deferred:
		_start_deferred_gate.call_deferred()

	_restore_editor_mods()
	menu_root.modulate = Color.WHITE
	home_screen.visible = s == Screen.HOME
	select_screen.visible = s == Screen.SELECT
	if s == Screen.HOME:


		_restore_home_visuals()
		_reset_screen(home_screen)
		_slide_in(home_screen)



		_refresh_mod_presence()
	else:
		_reset_screen(select_screen)
		map_select.on_enter()
		_cascade_select()



	if now_bar != null:
		now_bar.visible = s == Screen.HOME
		now_bar.set_track(track_title(tuning.current_track), 
			track_artist(tuning.current_track))
	if s == Screen.HOME and orbit_menu != null:
		orbit_menu.reset()
		_menu_hover_idx = -1
	if s == Screen.SELECT:
		_refresh_select_panel()
	_refresh_rank_badges()


	if was_playing or not conductor.playing:
		conductor.stop()
		_play_preview()



func _reset_screen(node: Control) -> void :
	node.position = Vector2.ZERO
	node.modulate = Color.WHITE



func _slide_in(node: Control) -> void :
	node.modulate.a = 0.0
	node.position.y = 16.0
	var tw: = node.create_tween()
	tw.tween_property(node, "modulate:a", 1.0, 0.18)
	tw.parallel().tween_property(node, "position:y", 0.0, 0.22)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)



func _cascade_select() -> void :
	if map_select != null:
		map_select.play_intro()






func _go_select_animated() -> void :
	if _transitioning:
		return
	_transitioning = true
	sfx.play_ui("whoosh")
	_tween_lowpass(650.0, 0.25)




	_menu_hover_idx = -1
	if orbit_menu != null:
		orb_menu.set_look_target(orbit_menu.button_global(1))
		orbit_menu.converge_to(1)
	orb_menu.play_reaction(&"excited", 0.5)
	orb_menu.beat_kick(1.0)







	_home_exit_tw = orb_menu.create_tween()
	_home_exit_tw.tween_property(orb_menu, "scale", Vector2(2.4, 2.4), 0.3)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	_home_exit_tw.parallel().tween_property(orb_menu, "modulate:a", 0.0, 0.26)\
	.set_delay(0.06)

	for sm in menu_side_mascots:
		_home_exit_tw.parallel().tween_property(sm, "modulate:a", 0.0, 0.18)
	_home_fade_tw = create_tween()
	_home_fade_tw.tween_property(home_title, "modulate:a", 0.0, 0.18)
	_home_fade_tw.parallel().tween_property(home_secondary, "modulate:a", 0.0, 0.18)
	_home_fade_tw.parallel().tween_property(now_bar, "modulate:a", 0.0, 0.18)
	_home_fade_tw.parallel().tween_property(background, "home_reveal", 0.25, 0.28)\
	.set_ease(Tween.EASE_IN)
	await get_tree().create_timer(0.28).timeout
	_open_menu(Screen.SELECT)
	_restore_home_visuals()

	var rtw: = create_tween()
	rtw.tween_property(background, "home_reveal", 1.0, 0.45)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await get_tree().create_timer(0.24).timeout
	_tween_lowpass(LP_OPEN, 0.15)
	sfx.play_ui("impact")
	_transitioning = false






func _restore_home_visuals() -> void :
	if _home_exit_tw != null and _home_exit_tw.is_valid():
		_home_exit_tw.kill()
	if _home_fade_tw != null and _home_fade_tw.is_valid():
		_home_fade_tw.kill()
	if orb_menu != null:
		orb_menu.scale = Vector2.ONE
		orb_menu.modulate = Color.WHITE
	for sm in menu_side_mascots:
		sm.modulate = Color.WHITE
	for n in [home_title, home_secondary, now_bar]:
		if n != null:
			n.modulate.a = 1.0


func _go_home_animated() -> void :
	if _transitioning:
		return
	_open_menu(Screen.HOME)





func _update_now_playing() -> void :
	_load_chart()
	start_game()














func _apply_offset() -> void :
	var global_ms: float = 0.0 if MapLibrary.is_user_map(tuning.current_track)\
	else tuning.global_offset_ms
	conductor.song_offset = _chart_offset + (global_ms
		+ float(SettingsManager.audio_offset_ms)) / 1000.0


func _nudge_offset(delta_ms: float) -> void :
	tuning.global_offset_ms += delta_ms
	_apply_offset()
	var vs: = get_viewport_rect().size
	_float_text("sync %+d ms" % int(tuning.global_offset_ms), 
		Vector2(vs.x * 0.5, vs.y - 120.0), Color(0.7, 0.9, 1.0), 26, true)






func _open_settings() -> void :
	if screen == Screen.PLAYING and not game_paused\
	and not game_over and not track_done:
		_toggle_pause(true)
	settings_ui.open()





func _on_setting_changed(key: String) -> void :
	match key:
		"audio_offset_ms":
			_apply_offset()
		"sfx_pack":
			sfx.set_pack(SettingsManager.sfx_pack)
		"mods":
			_refresh_mode_hud()
		"game_mode":
			_refresh_mode_hud()


			_global_rank = {}
			_refresh_rank_badges(true)
		_:


			if key.begins_with("vis_"):
				_apply_hud_flags()




func _refresh_mode_hud() -> void :
	if hud_mods_label != null:
		hud_mods_label.text = Mods.summary()
		hud_mods_label.add_theme_color_override("font_color", 
			Color(COL_GOLD, 0.75) if Mods.ranked() else Color(COL_RED, 0.75))




func _load_records() -> void :
	best_score = SettingsManager.best_score
	best_combo = SettingsManager.best_combo
	map_records = SettingsManager.map_records.duplicate()






	for key in map_records.keys():
		var up: String = String(key).to_upper()
		if not up.ends_with("|IMPOSSIBLE") or up.contains("@"):
			continue
		var rec: Dictionary = map_records[key]
		var t: String = String(key).split("|")[0]
		var cur: Dictionary = map_records.get(t, {})
		if int(rec.get("score", 0)) > int(cur.get("score", 0)):
			map_records[t] = rec
		map_records.erase(key)
	_migrate_records_to_standardized()









func _migrate_records_to_standardized() -> void :
	var dirty: = false
	for key in map_records.keys():
		var rec: Dictionary = map_records[key]
		if int(rec.get("v", 1)) >= 2:
			continue
		var judged: = int(rec.get("judged", 0))
		var new_score: = 0
		if rec.has("acc") and judged > 0:
			new_score = ScoreLib.reconstruct(float(rec.get("acc", 0.0)) / 100.0, 
				int(rec.get("combo", 0)), judged)
		rec["score"] = new_score
		if new_score > 0:
			rec["grade"] = ScoreLib.grade(float(rec.get("acc", 0.0)))
		rec["pp"] = 0.0
		rec["v"] = 2
		map_records[key] = rec
		dirty = true
	if dirty:
		best_score = 0
		for key in map_records:
			best_score = maxi(best_score, int(map_records[key].get("score", 0)))
		SettingsManager.save_records(best_score, best_combo, map_records)





func music_db() -> float:
	return tuning.music_volume_db


func sfx_db() -> float:
	return tuning.sfx_volume_db



func _toggle_invincible(on: bool) -> void :
	invincible = on
	if invincible_button != null:
		invincible_button.set_pressed_no_signal(on)
	Mods.set_on("invincible", on)
	Telemetry.note_flags(auto_mode, invincible)
	if on:
		run_assisted = true

	hp_row.modulate = Color(1.0, 0.85, 0.3) if on else Color.WHITE



func _combo_color() -> Color:
	if combo >= 50:
		return Skins.col("combo_50")
	if combo >= 25:
		return Skins.col("combo_25")
	if combo >= 10:
		return Skins.col("combo_10")
	return Color.WHITE



var _hud_score: = -1
var _hud_combo: = -1
var _hud_combo_col: = Color(0, 0, 0, 0)
var _hud_acc: = -1
var _hud_time_s: = -1


func _refresh_hud() -> void :

	_display_score += (float(score) - _display_score)\
	* (1.0 - exp(-10.0 * get_process_delta_time()))
	if absf(float(score) - _display_score) < 1.0:
		_display_score = float(score)






	var sc: = roundi(_display_score)
	if sc != _hud_score:
		_hud_score = sc
		score_label.text = "%07d" % sc


	if combo > 0:
		combo_label.text = "%dx" % combo if combo < 10\
		else "%dx   ×%d" % [combo, multiplier()]
	else:
		combo_label.text = ""
	var ccol: = _combo_color()
	if combo >= 25:
		ccol = neon(ccol, 1.3)
	combo_label.add_theme_color_override("font_color", ccol)
	if _combo_tw == null or not _combo_tw.is_running():
		combo_label.scale = Vector2.ONE * (1.0 + 0.05 * beat_pulse())



	var hfrac: = clampf(hp / tuning.hp_max, 0.0, 1.0)
	hp_bar_fill.size.x = HP_BAR_W * hfrac
	var hp_tx: Texture2D = Skins.tex("hp_fill")
	if hp_tx != null:
		var sb: = hp_bar_fill.get_theme_stylebox("panel")
		if not (sb is StyleBoxTexture) or (sb as StyleBoxTexture).texture != hp_tx:
			var sbt: = StyleBoxTexture.new()
			sbt.texture = hp_tx
			hp_bar_fill.add_theme_stylebox_override("panel", sbt)
		hp_bar_fill.modulate = Color(1.35, 0.55, 0.55) if hfrac < 0.3 else Color.WHITE
	else:
		if hp_bar_fill.get_theme_stylebox("panel") != hp_bar_style:
			hp_bar_fill.add_theme_stylebox_override("panel", hp_bar_style)
			hp_bar_fill.modulate = Color.WHITE
		hp_bar_style.bg_color = Skins.col("hp_low") if hfrac < 0.3\
		else (Skins.col("hp_mid") if hfrac < 0.6
			else Skins.col_over("hp_full", LANE_COLS[0]))
		hp_bar_style.shadow_color = Color(hp_bar_style.bg_color, 0.35)
	hp_track_style.bg_color = Skins.col("hp_track")

	var acc_pct: = 100.0 if judged_count <= 0\
	else (accuracy_sum / float(judged_count)) * 100.0


	var acc_cent: = roundi(acc_pct * 100.0)
	if acc_cent != _hud_acc:
		_hud_acc = acc_cent
		acc_value.text = "%.2f%%" % acc_pct



	var song_t: = maxf(conductor.get_song_time(), 0.0)
	var end_t: = map_end()
	if end_t <= 0.0 and conductor.stream != null:
		end_t = conductor.stream.get_length()
	var left: = maxf(end_t - song_t, 0.0)
	var left_s: = int(left)
	if left_s != _hud_time_s:
		_hud_time_s = left_s
		time_value.text = "%02d:%02d" % [left_s / 60, left_s % 60]
	var span: = maxf(end_t - map_start(), 0.001)
	time_bar_fill.size.x = TIME_BAR_W * clampf(left / span, 0.0, 1.0)













func _grade_for(acc_pct: float, misses: = -1) -> Array:
	var g: = ScoreLib.grade(acc_pct, misses)
	match g:
		"SS":
			return ["SS", GRADE_COLS["SS"]]
		"S":
			return ["S", COL_GOLD]
		"A":
			return ["A", COL_ACCENT]
		"B":
			return ["B", COL_PERFECT]
		"C":
			return ["C", Color(1.0, 0.68, 0.25)]
	return ["D", COL_RED]







func _show_end_panel(title: String) -> void :
	var acc: = (accuracy_sum / float(maxi(judged_count, 1))) * 100.0


	var key: = _rec_key(tuning.current_track, tuning.current_diff)
	var prev_best: = int(map_records.get(key, {}).get("score", 0))


	var j: Dictionary = Telemetry.current_judgements()
	var run_misses: = int(j.get("miss", 0))
	if track_done:
		_recompute_score(true)
	var grade: Array = _grade_for(acc, run_misses)
	var run_pp: = PerfLib.pp(_density_level(_meta_current()), score) if track_done else 0.0
	var new_record: = false
	if track_done and not run_assisted:
		var dirty: = false
		if score > best_score or max_combo > best_combo:
			best_score = maxi(best_score, score)
			best_combo = maxi(best_combo, max_combo)
			dirty = true
		var rec: Dictionary = map_records.get(key, {})


		if score > int(rec.get("score", 0)):



			map_records[key] = {"score": score, "combo": max_combo, 
				"grade": grade[0], "acc": acc, "judged": judged_count, 
				"pp": run_pp, "v": 2}
			dirty = true
			new_record = true
		if dirty:
			SettingsManager.save_records(best_score, best_combo, map_records)


	_results_token += 1
	var track: String = tuning.current_track
	var lvl: = _density_level(_meta_current())
	var tier: Array = _tier_for(lvl)
	var r: = RunResult.new()
	r.map_id = track
	r.map_title = track_title(track)
	r.map_artist = track_artist(track)
	r.cover = track_covers.tex(track)
	r.difficulty_id = tuning.current_diff




	var shared: bool = MapLibrary.is_user_map(track) and MapLibrary.is_shared(track)
	if shared:
		r.map_id = String(MapLibrary.meta_of(track).get("online_id", ""))
	r.local_map = MapLibrary.is_user_map(track) and not shared
	r.difficulty_name = MapLibrary.diff_name(track, tuning.current_diff)\
	if MapLibrary.is_user_map(track) else String(tier[0])
	r.difficulty_level = lvl
	r.difficulty_color = tier[1]
	r.mode_key = Mods.mode_key()
	r.mode_name = Mods.mode_name()
	r.mods = Mods.active()
	r.mods_summary = Mods.summary()
	r.mods_ranked = Mods.ranked()
	r.assisted = run_assisted
	r.cleared = track_done
	r.status_text = title
	r.score = score
	r.accuracy = acc
	r.grade = String(grade[0])
	r.grade_color = ResultsTheme.grade_color(r.grade)
	r.perfect = int(j.get("perfect", 0))
	r.good = int(j.get("good", 0))
	r.meh = int(j.get("meh", 0))
	r.miss = run_misses
	r.max_combo = max_combo
	r.judged = judged_count
	r.full_combo = track_done and run_misses == 0 and judged_count > 0
	r.previous_best = prev_best
	r.new_record = new_record
	r.ranked = track_done and not run_assisted and Mods.ranked()\
	and not r.local_map and playtest_from < 0.0
	r.signed_in = Backend.is_logged_in()
	r.player_name = Backend.username
	r.ranking_status = RunResult.RankingStatus.LOCAL_MAP if r.local_map\
	else RunResult.RankingStatus.LOADING


	if not r.signed_in:
		r.account_state = "signed_out"
	elif not _global_rank.is_empty():
		r.account_state = "signed_in"
		r.global_rank = int(_global_rank.get("rank", 0))
		r.global_players = int(_global_rank.get("players", 0))
	else:
		r.account_state = "loading"
		_refresh_results_account(r)
	results_screen.set_glow_texture(glow_tex)
	results_screen.show_results(r)
	end_panel.visible = true


	_load_results_ranking()







func _build_account_panel() -> void :
	account_panel = Control.new()
	account_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	account_panel.visible = false
	menu_root.add_child(account_panel)
	var dim: = ColorRect.new()
	dim.color = Color(0.008, 0.012, 0.028, 0.72)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	account_panel.add_child(dim)
	var center: = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	account_panel.add_child(center)
	var box: = PanelContainer.new()
	box.custom_minimum_size = Vector2(400, 0)
	box.add_theme_stylebox_override("panel", 
		_chip(Color(0.07, 0.08, 0.13, 0.97), Color(0.72, 0.45, 1.0, 0.5), 16, 14))
	center.add_child(box)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	box.add_child(v)

	var title: = Label.new()
	title.text = "ACCOUNT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if font_display:
		title.add_theme_font_override("font", font_display)
	title.add_theme_font_size_override("font_size", 24)
	v.add_child(title)
	account_status = Label.new()
	account_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	account_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	account_status.add_theme_font_size_override("font_size", 13)
	account_status.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
	v.add_child(account_status)

	acc_user = _account_field(v, "username or email")
	acc_pass = _account_field(v, "password", true)
	acc_email = _account_field(v, "email (sign-up only)")

	var row1: = HBoxContainer.new()
	row1.add_theme_constant_override("separation", 10)
	row1.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(row1)
	var login_b: = Button.new()
	login_b.text = "SIGN IN"
	_style_chip(login_b, false, COL_ACCENT)
	login_b.set_meta("ui_sound", "impact")
	login_b.pressed.connect(_account_login)
	row1.add_child(login_b)
	var reg_b: = Button.new()
	reg_b.text = "CREATE ACCOUNT"
	_style_chip(reg_b, false, Color(0.72, 0.45, 1.0))
	reg_b.pressed.connect(_account_register)
	row1.add_child(reg_b)

	var row2: = HBoxContainer.new()
	row2.add_theme_constant_override("separation", 10)
	row2.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(row2)
	var out_b: = Button.new()
	out_b.text = "SIGN OUT"
	_style_chip(out_b, false, COL_RED)
	out_b.pressed.connect(_account_logout)
	row2.add_child(out_b)
	_account_buttons = [login_b, reg_b, out_b]
	var close_b: = Button.new()
	close_b.text = "CLOSE  (ESC)"
	_style_chip(close_b, false, Color(1, 1, 1, 0.5))
	close_b.set_meta("ui_sound", "back")
	close_b.pressed.connect( func(): account_panel.visible = false)
	row2.add_child(close_b)


	Backend.auth_changed.connect(_on_auth_changed)
	_on_auth_changed(Backend.is_logged_in(), Backend.username)


func _account_field(parent: Control, placeholder: String, secret: = false) -> LineEdit:
	var le: = LineEdit.new()
	le.placeholder_text = placeholder
	le.secret = secret
	le.custom_minimum_size = Vector2(0, 36)
	le.add_theme_font_size_override("font_size", 14)
	parent.add_child(le)
	return le


func _toggle_account_panel() -> void :
	account_panel.visible = not account_panel.visible
	if account_panel.visible:
		account_status.text = ("Signed in as %s" % Backend.username)\
		if Backend.is_logged_in() else "Not signed in."
		acc_pass.text = ""


func _on_auth_changed(logged: bool, uname: String) -> void :
	if account_item != null:
		account_item.text = uname.to_upper() if logged else "ACCOUNT"


	if account_name_label != null:
		account_name_label.text = uname.to_upper() if logged else "ACCOUNT"
	if account_dot != null:
		account_dot.visible = logged
	if account_status != null:
		account_status.text = ("Signed in as %s" % uname) if logged else "Not signed in."


	_global_rank = {}
	_refresh_rank_badges(logged)




func _api_error(r: Dictionary) -> String:
	if r.code == 0:
		return "server unreachable"
	if r.data is Dictionary and r.data.has("message"):
		var m: Variant = r.data.message
		return ", ".join(m) if m is Array else str(m)
	return "error %d" % r.code







var _account_busy: = false
var _account_buttons: Array = []


func _account_set_busy(on: bool) -> void :
	_account_busy = on
	for b in _account_buttons:
		if is_instance_valid(b):
			b.disabled = on


func _account_login() -> void :
	if _account_busy:
		return
	var ident: = acc_user.text.strip_edges()
	if ident == "" or acc_pass.text == "":
		account_status.text = "Username/email and password required."
		return
	account_status.text = "Signing in…"
	_account_set_busy(true)
	var r: Dictionary = await Backend.api_login(ident, acc_pass.text)
	_account_set_busy(false)
	if r.ok:
		acc_pass.text = ""
		account_panel.visible = false
		sfx.play_ui("impact")
	else:
		account_status.text = _api_error(r)


func _account_register() -> void :
	if _account_busy:
		return
	var email: = acc_email.text.strip_edges()
	var uname: = acc_user.text.strip_edges()
	if email == "" or uname == "" or acc_pass.text == "":
		account_status.text = "Sign-up needs email + username + password (8+ chars)."
		return
	account_status.text = "Creating account…"
	_account_set_busy(true)
	var r: Dictionary = await Backend.api_register(email, uname, acc_pass.text)
	_account_set_busy(false)
	if r.ok:
		acc_pass.text = ""
		account_panel.visible = false
		sfx.play_ui("impact")
	else:
		account_status.text = _api_error(r)


func _account_logout() -> void :
	if _account_busy:
		return
	if not Backend.is_logged_in():
		account_status.text = "Already signed out."
		return
	account_status.text = "Signing out…"
	_account_set_busy(true)
	await Backend.api_logout()
	_account_set_busy(false)
	account_status.text = "Not signed in."









func _snapshot_ranks() -> void :
	_rank_before_map = -1
	_rank_before_global = -1
	if not Backend.is_logged_in() or MapLibrary.is_user_map(tuning.current_track):
		return
	_rank_snap_token += 1
	var token: = _rank_snap_token
	var m: Dictionary = await Backend.map_me(tuning.current_track, tuning.current_diff)
	if token != _rank_snap_token:
		return
	if m.ok and m.data is Dictionary:
		_rank_before_map = int(m.data.get("rank", -1))
	var g: Dictionary = await Backend.global_me()
	if token != _rank_snap_token:
		return
	if g.ok and g.data is Dictionary:
		_rank_before_global = int(g.data.get("rank", -1))
		_global_rank = g.data


func _submit_online_score() -> void :
	var r: RunResult = results_screen.data
	if r == null:
		return


	if r.local_map:
		return
	if not Backend.is_logged_in():
		return
	r.ranking_status = RunResult.RankingStatus.SUBMITTING
	results_screen.apply_ranking(r)
	var map_id: String = r.map_id
	var diff: String = r.difficulty_id
	var payload: = {
		"mode": SettingsManager.input_device, 


		"gameMode": r.mode_key, 
		"score": r.score, 
		"accuracy": clampf(r.accuracy, 0.0, 100.0), 
		"maxCombo": r.max_combo, 
		"judgements": Telemetry.current_judgements(), 



		"mods": r.mods, 
		"chartHash": Backend.chart_hash(tuning.chart_path), 
	}
	var res: Dictionary = await Backend.submit_score(map_id, diff, payload)
	if results_screen.data != r:
		return
	if not res.ok:




		if res.data is Dictionary and str(res.data.get("reason", "")) in ["pending", "unranked"]\
		and MapLibrary.is_user_map(tuning.current_track):
			MapLibrary.set_online_ranking(tuning.current_track, str(res.data.get("reason", "")))
		_load_results_ranking(RunResult.RankingStatus.REJECTED, _api_error(res))
		return
	if MapLibrary.is_user_map(tuning.current_track):
		MapLibrary.set_online_ranking(tuning.current_track, "ranked")
	var rank: Dictionary = await Backend.map_me(map_id, diff)
	if results_screen.data != r:
		return
	if rank.ok and rank.data is Dictionary:
		var new_rank: = int(rank.data.get("rank", 0))
		var d: Array = _rank_delta(_rank_before_map, new_rank)
		r.rank_delta_text = String(d[0])
		r.rank_delta_color = d[1]

	var g: Dictionary = await Backend.global_me()
	if results_screen.data != r:
		return
	if g.ok and g.data is Dictionary:
		_global_rank = g.data
		r.account_state = "signed_in"
		r.global_rank = int(g.data.get("rank", 0))
		r.global_players = int(g.data.get("players", 0))
		results_screen.apply_account(r)
		_refresh_rank_badges()

	_load_results_ranking()





func _rank_delta(before: int, after: int) -> Array:
	if after <= 0:
		return ["", Color(1, 1, 1, 0.5)]
	if before <= 0:
		return ["NEW ENTRY", COL_GOLD]
	if after < before:
		var gained: = before - after
		return ["+%d PLACE%s" % [gained, "S" if gained > 1 else ""], COL_PERFECT]
	if after == before:
		return ["NO CHANGE", Color(1, 1, 1, 0.45)]
	return ["-%d" % (after - before), Color(COL_RED, 0.85)]







func _load_results_ranking(final_status: = RunResult.RankingStatus.READY, message: = "") -> void :
	var r: RunResult = results_screen.data
	if r == null or r.local_map:
		return
	_results_token += 1
	var token: = _results_token
	if r.ranking_status != RunResult.RankingStatus.SUBMITTING:
		r.ranking_status = RunResult.RankingStatus.LOADING
		results_screen.apply_ranking(r)
	var top: Dictionary = await Backend.map_top(r.map_id, r.difficulty_id, 50)
	var mine: = {}
	if Backend.is_logged_in():
		mine = await Backend.map_me(r.map_id, r.difficulty_id)
	if token != _results_token or results_screen.data != r or not is_inside_tree():
		return
	if not top.ok:
		r.ranking_status = RunResult.RankingStatus.OFFLINE if int(top.get("code", 0)) == 0\
		else RunResult.RankingStatus.ERROR
		r.ranking_message = _api_error(top) if int(top.get("code", 0)) != 0 else ""
		results_screen.apply_ranking(r)
		return
	r.entries = top.data if top.data is Array else []
	r.player_rank = -1
	r.player_entry = {}
	if mine is Dictionary and mine.get("ok", false) and mine.data is Dictionary:
		r.player_rank = int(mine.data.get("rank", -1))
		var best: Dictionary = mine.data.get("best", {}) if mine.data.get("best") is Dictionary else {}
		r.player_entry = RunResult.entry(r.player_rank, Backend.username, 
			float(best.get("accuracy", 0.0)), int(best.get("maxCombo", -1)), 
			int(best.get("score", 0)))
	r.ranking_message = message
	if r.entries.is_empty() and final_status == RunResult.RankingStatus.READY:
		r.ranking_status = RunResult.RankingStatus.EMPTY
	else:
		r.ranking_status = final_status
	results_screen.apply_ranking(r)




func _refresh_results_account(r: RunResult) -> void :
	var g: Dictionary = await Backend.global_me()
	if results_screen == null or results_screen.data != r:
		return
	if g.ok and g.data is Dictionary:
		_global_rank = g.data
		r.account_state = "signed_in"
		r.global_rank = int(g.data.get("rank", 0))
		r.global_players = int(g.data.get("players", 0))
	elif int(g.get("code", 0)) == 0:
		r.account_state = "error"
	else:
		r.account_state = "signed_in"
		r.global_rank = 0
	results_screen.apply_account(r)




func _open_leaderboard() -> void :
	lb_mode = "MAP"
	if lb_overlay == null:
		_build_lb_overlay()
	lb_overlay.visible = true
	_populate_leaderboard()






func _open_global_leaderboard() -> void :
	lb_mode = "GLOBAL"
	if lb_overlay == null:
		_build_lb_overlay()
	lb_overlay.visible = true
	_populate_leaderboard()






func _build_lb_overlay() -> void :
	lb_overlay = Control.new()
	lb_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	lb_overlay.visible = false
	ui_layer.add_child(lb_overlay)


	if crosshair_node != null:
		ui_layer.move_child(crosshair_node, ui_layer.get_child_count() - 1)
	var dim: = ColorRect.new()
	dim.color = Color(0.008, 0.012, 0.028, 0.8)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	lb_overlay.add_child(dim)
	var center: = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	lb_overlay.add_child(center)
	var box: = PanelContainer.new()
	box.custom_minimum_size = Vector2(940, 604)

	box.clip_contents = true
	var bst: = _chip(Color(0.045, 0.055, 0.1, 0.97), Color(1, 1, 1, 0.13), 16, 14)
	bst.content_margin_left = 24
	bst.content_margin_right = 24
	bst.content_margin_top = 18
	bst.content_margin_bottom = 16
	box.add_theme_stylebox_override("panel", bst)
	center.add_child(box)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	box.add_child(v)


	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	v.add_child(head)
	var thumb: = Panel.new()
	thumb.custom_minimum_size = Vector2(84, 56)
	thumb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var ths: = StyleBoxFlat.new()
	ths.bg_color = Color(0.07, 0.08, 0.14, 1.0)
	ths.set_corner_radius_all(8)
	ths.border_color = Color(1, 1, 1, 0.12)
	ths.set_border_width_all(1)
	thumb.add_theme_stylebox_override("panel", ths)
	thumb.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	head.add_child(thumb)
	var thumb_tex: = TextureRect.new()
	thumb_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
	thumb_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumb_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	thumb_tex.clip_contents = true
	thumb.add_child(thumb_tex)
	lb_overlay.set_meta("cover", thumb_tex)
	var hcol: = VBoxContainer.new()
	hcol.add_theme_constant_override("separation", 2)



	hcol.custom_minimum_size = Vector2(400, 0)
	hcol.size_flags_horizontal = Control.SIZE_FILL
	head.add_child(hcol)
	var title: = Label.new()
	if font_bold:
		title.add_theme_font_override("font", font_bold)
	title.add_theme_font_size_override("font_size", 22)
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.custom_minimum_size = Vector2(400, 0)
	title.size_flags_horizontal = Control.SIZE_FILL
	hcol.add_child(title)
	lb_overlay.set_meta("title", title)
	var artist: = Label.new()
	artist.add_theme_font_size_override("font_size", 12)
	artist.add_theme_color_override("font_color", Color(1, 1, 1, 0.48))
	artist.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	artist.custom_minimum_size = Vector2(400, 0)
	hcol.add_child(artist)
	lb_overlay.set_meta("artist", artist)
	var chip: = Label.new()
	chip.add_theme_font_size_override("font_size", 11)
	if font_bold:
		chip.add_theme_font_override("font", font_bold)
	chip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	hcol.add_child(chip)
	lb_overlay.set_meta("chip", chip)
	var hspace: = Control.new()
	hspace.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(hspace)

	var tabs: = HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	tabs.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(tabs)
	var tab_g: = Button.new()
	tab_g.text = "GLOBAL"
	tab_g.focus_mode = Control.FOCUS_NONE
	_style_chip(tab_g, true, Color(0.72, 0.45, 1.0))
	tabs.add_child(tab_g)
	var tab_f: = Button.new()
	tab_f.text = "FRIENDS"
	tab_f.focus_mode = Control.FOCUS_NONE
	tab_f.disabled = true
	tab_f.tooltip_text = "soon!"
	_style_chip(tab_f, false, Color(1, 1, 1, 0.4))
	tabs.add_child(tab_f)
	var refresh_b: = Button.new()
	refresh_b.text = "REFRESH"
	refresh_b.focus_mode = Control.FOCUS_NONE
	refresh_b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_style_chip(refresh_b, false, COL_ACCENT)
	refresh_b.pressed.connect(_populate_leaderboard)
	tabs.add_child(refresh_b)

	var yb: = PanelContainer.new()
	yb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	yb.add_theme_stylebox_override("panel", 
		_chip(Color(0.06, 0.07, 0.12, 0.92), Color(0.72, 0.45, 1.0, 0.4), 10, 0))
	head.add_child(yb)
	var ybh: = HBoxContainer.new()
	ybh.add_theme_constant_override("separation", 12)
	yb.add_child(ybh)
	var ybcol: = VBoxContainer.new()
	ybcol.add_theme_constant_override("separation", 1)
	ybh.add_child(ybcol)
	var ybcap: = Label.new()
	ybcap.text = "YOUR BEST"
	ybcap.add_theme_font_size_override("font_size", 10)
	ybcap.add_theme_color_override("font_color", Color(1, 1, 1, 0.4))
	if font_bold:
		ybcap.add_theme_font_override("font", font_bold)
	ybcol.add_child(ybcap)
	var yb_rank: = Label.new()
	yb_rank.add_theme_font_size_override("font_size", 18)
	if font_bold:
		yb_rank.add_theme_font_override("font", font_bold)
	yb_rank.add_theme_color_override("font_color", neon(Color(0.72, 0.45, 1.0), 1.2))
	ybcol.add_child(yb_rank)
	lb_overlay.set_meta("yb_rank", yb_rank)
	var yb_line: = Label.new()
	yb_line.add_theme_font_size_override("font_size", 11)
	yb_line.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
	ybcol.add_child(yb_line)
	lb_overlay.set_meta("yb_line", yb_line)
	var yb_grade: = Label.new()
	yb_grade.custom_minimum_size = Vector2(36, 0)
	yb_grade.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	yb_grade.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if font_bold:
		yb_grade.add_theme_font_override("font", font_bold)
	yb_grade.add_theme_font_size_override("font_size", 26)
	ybh.add_child(yb_grade)
	lb_overlay.set_meta("yb_grade", yb_grade)


	var hdr: = HBoxContainer.new()
	hdr.add_theme_constant_override("separation", 10)
	v.add_child(hdr)
	var hdr_labels: Array = []
	for cap in [["RANK", 70, HORIZONTAL_ALIGNMENT_CENTER, 0], 
			["PLAYER", 0, HORIZONTAL_ALIGNMENT_LEFT, 1], 
			["ACCURACY", 110, HORIZONTAL_ALIGNMENT_RIGHT, 0], 
			["SCORE", 150, HORIZONTAL_ALIGNMENT_RIGHT, 0], 
			["RANK", 64, HORIZONTAL_ALIGNMENT_CENTER, 0]]:
		var cl: = Label.new()
		cl.text = cap[0]
		hdr_labels.append(cl)
		cl.custom_minimum_size = Vector2(int(cap[1]), 0)
		cl.horizontal_alignment = cap[2]
		if int(cap[3]) == 1:
			cl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cl.add_theme_font_size_override("font_size", 10)
		if font_bold:
			cl.add_theme_font_override("font", font_bold)
		cl.add_theme_color_override("font_color", Color(1, 1, 1, 0.35))
		hdr.add_child(cl)


	lb_overlay.set_meta("hdr", hdr_labels)
	lb_overlay.set_meta("thumb", thumb)


	var scroll: = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(scroll)
	lb_rows = VBoxContainer.new()
	lb_rows.add_theme_constant_override("separation", 4)
	lb_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(lb_rows)
	var close_b: = Button.new()
	close_b.text = "CLOSE  (ESC)"
	close_b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_style_chip(close_b, false, Color(1, 1, 1, 0.5))
	close_b.set_meta("ui_sound", "back")
	close_b.pressed.connect( func(): lb_overlay.visible = false)
	v.add_child(close_b)
	_wire_ui_sounds(lb_overlay)










func _lb_row(rank: int, name_txt: String, score_v: int, acc: float, me: bool, 
		mid_text: = "", grade: = true, misses: = -1, unit: = "", mods: Array = []) -> Control:
	var rc: = _rank_color(rank, me)
	var row: = PanelContainer.new()
	row.custom_minimum_size = Vector2(0, 38)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var bg: = Color(0.08, 0.09, 0.15, 0.6)
	var border: = Color(1, 1, 1, 0.06)
	if me:
		bg = Color(0.72 * 0.22, 0.45 * 0.22, 1.0 * 0.22, 0.95)
		border = Color(0.72, 0.45, 1.0, 0.75)
	elif rank <= 3:
		bg = Color(rc.r * 0.1, rc.g * 0.1, rc.b * 0.1, 0.8)
		border = Color(rc, 0.25)
	var rst: = _chip(bg, border, 9, 6 if me else 0)
	if me:
		rst.shadow_color = Color(0.72, 0.45, 1.0, 0.22)
	row.add_theme_stylebox_override("panel", rst)
	var h: = HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	row.add_child(h)
	var rl: = Label.new()
	rl.text = "%d" % rank
	rl.custom_minimum_size = Vector2(70, 0)
	rl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if font_bold:
		rl.add_theme_font_override("font", font_bold)
	rl.add_theme_font_size_override("font_size", 18 if rank <= 3 else 14)
	rl.add_theme_color_override("font_color", neon(rc, 1.25) if rank <= 3 else rc)
	h.add_child(rl)
	var mid: = HBoxContainer.new()
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.add_theme_constant_override("separation", 8)
	h.add_child(mid)
	if rank <= 3 and not me:

		var medal: = Panel.new()
		medal.custom_minimum_size = Vector2(9, 9)
		medal.size = Vector2(9, 9)
		medal.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		medal.pivot_offset = Vector2(4.5, 4.5)
		medal.rotation = PI / 4.0
		var mst: = StyleBoxFlat.new()
		mst.bg_color = neon(rc, 1.2)
		mst.set_corner_radius_all(2)
		medal.add_theme_stylebox_override("panel", mst)
		mid.add_child(medal)
	var nl: = Label.new()
	nl.text = name_txt + ("   · YOU" if me else "")
	nl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	nl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	nl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if font_bold:
		nl.add_theme_font_override("font", font_bold)
	nl.add_theme_font_size_override("font_size", 14)
	nl.add_theme_color_override("font_color", 
		neon(Color(0.72, 0.45, 1.0), 1.15) if me else Color(1, 1, 1, 0.92))
	mid.add_child(nl)



	if not mods.is_empty():
		var ml: = Label.new()
		ml.text = Mods.letters(mods)
		ml.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		ml.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		ml.add_theme_font_size_override("font_size", 10)
		if font_bold:
			ml.add_theme_font_override("font", font_bold)
		ml.add_theme_color_override("font_color", COL_GOLD)
		ml.add_theme_stylebox_override("normal", _chip(Color(COL_GOLD, 0.1), Color(COL_GOLD, 0.45), 7))
		ml.tooltip_text = "Mods: " + ", ".join(mods)
		mid.add_child(ml)
	var al: = Label.new()
	al.text = mid_text if mid_text != "" else "%.2f %%" % acc
	al.custom_minimum_size = Vector2(110, 0)
	al.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	al.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	al.add_theme_font_size_override("font_size", 13)
	al.add_theme_color_override("font_color", 
		neon(Color(0.72, 0.45, 1.0), 1.1) if me else Color(1, 1, 1, 0.7))
	h.add_child(al)
	var sc: = Label.new()



	sc.text = "%d%s" % [score_v, unit]
	sc.custom_minimum_size = Vector2(150, 0)
	sc.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	sc.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if font_bold:
		sc.add_theme_font_override("font", font_bold)
	sc.add_theme_font_size_override("font_size", 14)
	sc.add_theme_color_override("font_color", 
		neon(rc, 1.15) if rank <= 3 or me else Color(1, 1, 1, 0.85))
	h.add_child(sc)
	var gr: Array = _grade_for(acc, misses)
	var gl: = Label.new()
	gl.text = gr[0] if grade else ""
	gl.custom_minimum_size = Vector2(64, 0)
	gl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if font_bold:
		gl.add_theme_font_override("font", font_bold)
	gl.add_theme_font_size_override("font_size", 17)
	gl.add_theme_color_override("font_color", neon(gr[1], 1.15))
	h.add_child(gl)
	return row



func _rank_color(rank: int, me: bool) -> Color:
	if me:
		return COL_ACCENT
	match rank:
		1: return COL_GOLD
		2: return Color(0.8, 0.86, 0.95)
		3: return Color(0.9, 0.62, 0.42)
	return Color(1, 1, 1, 0.55)





func _lb_card(parent: Container, rank: int, name_txt: String, score_v: int, 
		acc: float, combo: int, me: bool, compact: = false) -> void :
	var rc: = _rank_color(rank, me)
	var card: = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 42 if compact else 56)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var bg: = Color(0.1, 0.12, 0.18, 0.92) if not me else Color(0.1, 0.2, 0.17, 0.95)
	var border: = Color(1, 1, 1, 0.1) if not me else Color(COL_ACCENT, 0.65)
	card.add_theme_stylebox_override("panel", _chip(bg, border, 10, 4))
	parent.add_child(card)
	var h: = HBoxContainer.new()
	h.add_theme_constant_override("separation", 10 if compact else 14)
	card.add_child(h)

	var rl: = Label.new()
	rl.text = "#%d" % rank
	rl.custom_minimum_size = Vector2(40 if compact else 64, 0)
	rl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if font_bold:
		rl.add_theme_font_override("font", font_bold)
	rl.add_theme_font_size_override("font_size", 
		(17 if compact else 24) if rank <= 3 else (14 if compact else 19))
	rl.add_theme_color_override("font_color", neon(rc, 1.25) if rank <= 3 else rc)
	h.add_child(rl)

	var mid: = VBoxContainer.new()
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.alignment = BoxContainer.ALIGNMENT_CENTER
	mid.add_theme_constant_override("separation", 1)
	h.add_child(mid)
	var nl: = Label.new()
	nl.text = name_txt + ("   (you)" if me else "")
	if font_bold:
		nl.add_theme_font_override("font", font_bold)
	nl.add_theme_font_size_override("font_size", 13 if compact else 17)
	nl.add_theme_color_override("font_color", 
		COL_ACCENT if me else Color(1, 1, 1, 0.95))
	nl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	mid.add_child(nl)
	var sl: = Label.new()
	sl.text = "%.1f %%   ·   x%d" % [acc, combo]
	sl.add_theme_font_size_override("font_size", 10 if compact else 12)
	sl.add_theme_color_override("font_color", Color(1, 1, 1, 0.48))
	mid.add_child(sl)

	var sc: = Label.new()


	sc.text = "%d" % score_v
	sc.custom_minimum_size = Vector2(78 if compact else 130, 0)
	sc.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	sc.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if font_bold:
		sc.add_theme_font_override("font", font_bold)
	sc.add_theme_font_size_override("font_size", 14 if compact else 21)
	sc.add_theme_color_override("font_color", neon(rc, 1.15) if rank <= 3 or me
		else Color(1, 1, 1, 0.85))
	h.add_child(sc)


func _lb_note(parent: Container, text: String, col: = Color(1, 1, 1, 0.45)) -> void :
	var l: = Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 14)
	l.add_theme_color_override("font_color", col)
	parent.add_child(l)


func _populate_leaderboard() -> void :
	if lb_mode == "GLOBAL":
		await _populate_global_leaderboard()
		return
	var hdr: Array = lb_overlay.get_meta("hdr", [])
	if hdr.size() == 5:
		hdr[2].text = "ACCURACY"
		hdr[3].text = "SCORE"
		hdr[4].text = "RANK"
	(lb_overlay.get_meta("thumb") as Control).visible = true
	var map_id: String = tuning.current_track

	var title: Label = lb_overlay.get_meta("title")
	title.text = track_title(map_id)
	var artist: Label = lb_overlay.get_meta("artist")
	artist.text = track_artist(map_id)
	var cover: TextureRect = lb_overlay.get_meta("cover")
	cover.texture = track_covers.tex(map_id)
	var chip: Label = lb_overlay.get_meta("chip")
	var lvl: = _density_level(_meta_current())
	var tier: Array = _tier_for(lvl)
	var tcol: Color = tier[1]
	chip.text = "%s  %.1f" % [tier[0], lvl]
	chip.add_theme_color_override("font_color", neon(tcol, 1.15))
	var dcs: = StyleBoxFlat.new()
	dcs.bg_color = Color(tcol.r * 0.14, tcol.g * 0.14, tcol.b * 0.14, 0.95)
	dcs.border_color = Color(tcol, 0.65)
	dcs.set_border_width_all(1)
	dcs.set_corner_radius_all(6)
	dcs.content_margin_left = 8
	dcs.content_margin_right = 8
	dcs.content_margin_top = 1
	dcs.content_margin_bottom = 1
	chip.add_theme_stylebox_override("normal", dcs)
	var yb_rank: Label = lb_overlay.get_meta("yb_rank")
	var yb_line: Label = lb_overlay.get_meta("yb_line")
	var yb_grade: Label = lb_overlay.get_meta("yb_grade")
	yb_rank.text = "#--"
	yb_line.text = "no ranked score" if Backend.is_logged_in() else "sign in to rank"
	yb_grade.text = "-"
	yb_grade.add_theme_color_override("font_color", Color(1, 1, 1, 0.3))
	for c in lb_rows.get_children():
		c.queue_free()


	var server_id: = map_id
	if MapLibrary.is_user_map(map_id):
		if not MapLibrary.is_shared(map_id):
			_lb_note(lb_rows, "local map — publish it to get a ranking")
			return
		server_id = String(MapLibrary.meta_of(map_id).get("online_id", ""))
		var rk: = MapLibrary.online_ranking_of(map_id)
		if rk != "" and rk != "ranked":
			_lb_note(lb_rows, "%s map — no online ranking until it is validated" % rk)
			return
	_lb_note(lb_rows, "loading…")
	var top: Dictionary = await Backend.map_top(server_id, tuning.current_diff, 50)
	var mine: = {}
	if Backend.is_logged_in():
		mine = await Backend.map_me(server_id, tuning.current_diff)

	if not lb_overlay.visible or tuning.current_track != map_id:
		return
	for c in lb_rows.get_children():
		c.queue_free()

	if not top.ok:
		_lb_note(lb_rows, "server unreachable", Color(COL_RED, 0.8))
		return
	var rows: Array = top.data if top.data is Array else []
	if rows.is_empty():
		_lb_note(lb_rows, "no scores on this map — be the first!")
		return
	var my_rank: = -1
	if mine is Dictionary and mine.get("ok", false) and mine.data is Dictionary:
		my_rank = int(mine.data.get("rank", -1))

		var mbest: Dictionary = mine.data.get("best", {})
		if my_rank > 0:
			yb_rank.text = "#%d" % my_rank
			var macc: = float(mbest.get("accuracy", 0.0))
			yb_line.text = "%.2f %%   ·   %d" % [macc, int(mbest.get("score", 0))]
			var mg: Array = _grade_for(macc, int(mbest.get("misses", -1)))
			yb_grade.text = mg[0]
			yb_grade.add_theme_color_override("font_color", neon(mg[1], 1.15))
	for e in rows:
		var me: bool = Backend.is_logged_in()\
		and str(e.get("username")) == Backend.username
		lb_rows.add_child(_lb_row(int(e.get("rank", 0)), str(e.get("username", "?")), 
			int(e.get("score", 0)), float(e.get("accuracy", 0.0)), me, 
			"", true, int(e.get("misses", -1)), "", 
			Array(e.get("mods", [])) if e.get("mods") is Array else []))

	if my_rank > rows.size():
		_lb_note(lb_rows, "· · ·")
		lb_rows.add_child(_lb_row(my_rank, Backend.username, 
			int(mine.data.get("best", {}).get("score", 0)), 
			float(mine.data.get("best", {}).get("accuracy", 0.0)), true, 
			"", true, int(mine.data.get("best", {}).get("misses", -1))))
	elif Backend.is_logged_in() and my_rank <= 0:

		_lb_note(lb_rows, "UNRANKED  ·  no ranked score of yours on this map yet", 
			Color(COL_GOLD, 0.85))





func _populate_global_leaderboard() -> void :
	var hdr: Array = lb_overlay.get_meta("hdr", [])
	if hdr.size() == 5:
		hdr[2].text = "MAPS"
		hdr[3].text = "MP"
		hdr[4].text = ""
	(lb_overlay.get_meta("thumb") as Control).visible = false
	(lb_overlay.get_meta("title") as Label).text = "GLOBAL RANKING"


	(lb_overlay.get_meta("artist") as Label).text = \
	"every player, every map  ·  %s" % Mods.mode_name()
	var chip: Label = lb_overlay.get_meta("chip")
	chip.text = ""
	chip.remove_theme_stylebox_override("normal")
	var yb_rank: Label = lb_overlay.get_meta("yb_rank")
	var yb_line: Label = lb_overlay.get_meta("yb_line")
	var yb_grade: Label = lb_overlay.get_meta("yb_grade")
	yb_grade.text = ""
	yb_rank.text = "#--"
	yb_line.text = "sign in to get ranked" if not Backend.is_logged_in() else "…"
	for c in lb_rows.get_children():
		c.queue_free()
	_lb_note(lb_rows, "loading…")
	var top: Dictionary = await Backend.global_top(50)
	var mine: = {}
	if Backend.is_logged_in():
		mine = await Backend.global_me()
	if not lb_overlay.visible or lb_mode != "GLOBAL":
		return
	for c in lb_rows.get_children():
		c.queue_free()
	if not top.ok:
		_lb_note(lb_rows, "server unreachable", Color(COL_RED, 0.8))
		return
	var my_rank: = -1
	if mine is Dictionary and mine.get("ok", false) and mine.data is Dictionary:
		my_rank = int(mine.data.get("rank", -1))
		yb_rank.text = "#%d" % my_rank
		yb_line.text = "%d MP   ·   %d maps" % [int(round(float(mine.data.get("totalPp", 0.0)))), 
			int(mine.data.get("mapsPlayed", 0))]
	elif Backend.is_logged_in():
		yb_line.text = "no ranked score yet"
	var rows: Array = top.data if top.data is Array else []
	if rows.is_empty():
		_lb_note(lb_rows, "no ranked player yet — be the first!")
		return
	for e in rows:
		var me: bool = Backend.is_logged_in()\
		and str(e.get("username")) == Backend.username

		lb_rows.add_child(_lb_row(int(e.get("rank", 0)), str(e.get("username", "?")), 
			int(round(float(e.get("totalPp", 0.0)))), 0.0, me, 
			"%d" % int(e.get("mapsPlayed", 0)), false, -1, " MP"))

	if my_rank > rows.size():
		_lb_note(lb_rows, "· · ·")
		lb_rows.add_child(_lb_row(my_rank, Backend.username, 
			int(round(float(mine.data.get("totalPp", 0.0)))), 0.0, true, 
			"%d" % int(mine.data.get("mapsPlayed", 0)), false, -1, " MP"))








func _start_playtest_gate() -> void :















	var forced: = OS.get_cmdline_user_args().has("--force-gate")
	if not (OS.has_feature("playtest") or forced):
		return





	if not SettingsManager.onboarding_done:
		_gate_deferred = true
		return
	_arm_playtest_gate()




var _gate_deferred: = false

func _start_deferred_gate() -> void :
	if not _gate_deferred or gate_root != null:
		return
	if not SettingsManager.onboarding_done or tutorial_active or screen == Screen.PLAYING:
		return
	if onboarding_ui != null and onboarding_ui.visible:
		return
	_gate_deferred = false
	_arm_playtest_gate()


func _arm_playtest_gate() -> void :


	_hb_timer = Timer.new()
	_hb_timer.wait_time = HEARTBEAT_SEC
	_hb_timer.timeout.connect(_heartbeat)
	add_child(_hb_timer)
	_build_gate()
	_gate_refresh()


func _build_gate() -> void :
	gate_root = Control.new()
	gate_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(gate_root)
	var dim: = ColorRect.new()
	dim.color = Color(0.008, 0.012, 0.028, 0.97)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	gate_root.add_child(dim)
	var center: = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	gate_root.add_child(center)
	var box: = PanelContainer.new()
	box.custom_minimum_size = Vector2(460, 0)
	box.add_theme_stylebox_override("panel", 
		_chip(Color(0.07, 0.08, 0.13, 0.98), Color(0.45, 1.0, 0.75, 0.45), 16, 14))
	center.add_child(box)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	box.add_child(v)

	gate_title = Label.new()
	gate_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if font_display:
		gate_title.add_theme_font_override("font", font_display)
	gate_title.add_theme_font_size_override("font_size", 26)
	v.add_child(gate_title)
	gate_msg = Label.new()
	gate_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gate_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	gate_msg.custom_minimum_size = Vector2(420, 0)
	gate_msg.add_theme_font_size_override("font_size", 14)
	gate_msg.add_theme_color_override("font_color", Color(1, 1, 1, 0.62))
	v.add_child(gate_msg)
	gate_input = LineEdit.new()
	gate_input.placeholder_text = "pt_…"
	gate_input.custom_minimum_size = Vector2(0, 40)
	gate_input.add_theme_font_size_override("font_size", 15)
	gate_input.text_submitted.connect( func(_t: String): _gate_submit_pressed())
	v.add_child(gate_input)



	gate_user = _account_field(v, "username or email")
	gate_pass = _account_field(v, "password", true)
	gate_email = _account_field(v, "email (sign-up only)")
	gate_pass.text_submitted.connect( func(_t: String): _gate_login_pressed())

	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(row)
	gate_submit = Button.new()
	gate_submit.text = "SUBMIT"
	_style_chip(gate_submit, false, COL_ACCENT)
	gate_submit.pressed.connect(_gate_submit_pressed)
	row.add_child(gate_submit)
	gate_login_b = Button.new()
	gate_login_b.text = "SIGN IN"
	_style_chip(gate_login_b, false, COL_ACCENT)
	gate_login_b.pressed.connect(_gate_login_pressed)
	row.add_child(gate_login_b)
	gate_register_b = Button.new()
	gate_register_b.text = "CREATE ACCOUNT"
	_style_chip(gate_register_b, false, Color(0.72, 0.45, 1.0))
	gate_register_b.pressed.connect(_gate_register_pressed)
	row.add_child(gate_register_b)
	gate_retry = Button.new()
	gate_retry.text = "RETRY"
	_style_chip(gate_retry, false, COL_PERFECT)
	gate_retry.pressed.connect(_gate_refresh)
	row.add_child(gate_retry)
	gate_update_b = Button.new()
	gate_update_b.text = "GET UPDATE"
	_style_chip(gate_update_b, false, COL_ACCENT)
	gate_update_b.pressed.connect( func():
		if gate_update_url != "":
			OS.shell_open(gate_update_url))
	row.add_child(gate_update_b)
	var quit_b: = Button.new()
	quit_b.text = "QUIT"
	_style_chip(quit_b, false, Color(1, 1, 1, 0.5))
	quit_b.pressed.connect( func(): Telemetry.quit_game())
	row.add_child(quit_b)


func _gate_mode(mode: String, msg: = "") -> void :
	gate_input.visible = false
	gate_submit.visible = false
	gate_retry.visible = false
	gate_user.visible = false
	gate_email.visible = false
	gate_pass.visible = false
	gate_login_b.visible = false
	gate_register_b.visible = false
	gate_update_b.visible = false
	match mode:
		"check":
			gate_title.text = "PLAYTEST"
			gate_msg.text = "checking…"
		"entry":
			gate_title.text = "PLAYTEST ACCESS"
			gate_msg.text = msg if msg != ""\
			else "Enter your tester key to unlock the game."
			gate_input.visible = true
			gate_submit.visible = true
			gate_input.grab_focus()
		"login":
			gate_title.text = "SIGN IN"
			gate_msg.text = msg if msg != ""\
			else "Sign in or create an account to play —\nit carries your online scores."
			gate_user.visible = true
			gate_email.visible = true
			gate_pass.visible = true
			gate_login_b.visible = true
			gate_register_b.visible = true
			gate_user.grab_focus()
		"closed":
			gate_title.text = "PLAYTEST OVER"
			gate_msg.text = msg if msg != ""\
			else "The playtest has ended — thanks for playing!"
		"update":
			gate_title.text = "UPDATE REQUIRED"
			gate_msg.text = msg if msg != ""\
			else "A new version is required to keep playing."
			gate_update_b.visible = gate_update_url != ""
		"error":
			gate_title.text = "SERVER UNREACHABLE"
			gate_msg.text = "Couldn't verify playtest access.\nCheck your connection and try again."
			gate_retry.visible = true


func _gate_refresh() -> void :
	_gate_mode("check")


	var vc: Dictionary = await Telemetry.version_check()
	if gate_root == null:
		return
	if vc.code == 0:
		_gate_mode("error")
		return
	if not vc.ok or not (vc.data is Dictionary)\
	or not bool(vc.data.get("allowed", false)):
		_gate_show_update(vc.data)
		return
	var st: Dictionary = await Telemetry.playtest_status()
	if gate_root == null:
		return
	if not st.ok:
		if st.code == 426:
			_gate_show_update(st.data)
		else:
			_gate_mode("error")
		return
	if st.data is Dictionary and not bool(st.data.get("open", true)):
		_gate_mode("closed", str(st.data.get("message", "")
			if st.data.get("message") != null else ""))
		return




	_gate_after_key_ok()




func _gate_after_key_ok() -> void :
	_gate_mode("check")
	var logged: bool = await Backend.wait_session()
	if gate_root == null:
		return
	if logged:
		_gate_dismiss()
	else:
		_gate_mode("login")


func _gate_submit_pressed() -> void :
	var raw: = gate_input.text.strip_edges()
	if raw == "":
		gate_msg.text = "Enter your key (pt_…)."
		return
	_gate_mode("check")
	var r: Dictionary = await Telemetry.claim_new_key(raw)
	if gate_root == null:
		return
	if r.ok:
		_gate_after_key_ok()
	elif r.code == 426:
		_gate_show_update(r.data)
	elif r.data is Dictionary and str(r.data.get("reason", "")) == "closed":
		_gate_mode("closed", str(r.data.get("message", "")))
	else:
		_gate_mode("entry", _gate_error(r))


func _gate_login_pressed() -> void :
	var ident: = gate_user.text.strip_edges()
	if ident == "" or gate_pass.text == "":
		gate_msg.text = "Username/email and password required."
		return
	_gate_mode("check")
	var r: Dictionary = await Backend.api_login(ident, gate_pass.text)
	if gate_root == null:
		return
	if r.ok:
		_gate_dismiss()
	else:
		_gate_mode("login", _api_error(r))


func _gate_register_pressed() -> void :
	var email: = gate_email.text.strip_edges()
	var uname: = gate_user.text.strip_edges()
	if email == "" or uname == "" or gate_pass.text == "":
		gate_msg.text = "Sign-up needs email + username + password (8+ chars)."
		return
	_gate_mode("check")
	var r: Dictionary = await Backend.api_register(email, uname, gate_pass.text)
	if gate_root == null:
		return
	if r.ok:
		_gate_dismiss()
	else:
		_gate_mode("login", _api_error(r))


func _gate_error(r: Dictionary) -> String:
	if r.code == 0:
		return "Server unreachable — try again in a moment."
	if r.data is Dictionary and r.data.get("message") != null:
		return str(r.data.message)
	if r.code == 401:
		return "Invalid or revoked key."
	return "Error %d." % r.code




var _intro_pending: = false

func _gate_dismiss() -> void :
	sfx.play_ui("impact")
	var g: = gate_root
	gate_root = null
	var tw: = g.create_tween()
	tw.tween_property(g, "modulate:a", 0.0, 0.35)
	tw.tween_callback(g.queue_free)
	if _hb_timer != null:
		_hb_fails = 0
		_hb_timer.start()


	if _intro_pending and menu_intro != null and screen == Screen.HOME:
		_intro_pending = false
		menu_intro.play()
		if not SettingsManager.onboarding_done:
			menu_intro.finished.connect(_maybe_open_onboarding, CONNECT_ONE_SHOT)
		return
	_intro_pending = false
	if not SettingsManager.onboarding_done:
		_maybe_open_onboarding.call_deferred()




func _gate_show_update(data: Variant) -> void :
	var msg: = ""
	if data is Dictionary:
		gate_update_url = str(data.get("updateUrl", ""))
		if data.get("message") != null:
			msg = str(data.get("message"))
		var latest: = str(data.get("latestVersion", ""))
		if latest != "":
			msg += ("\n" if msg != "" else "") + "Latest version: v%s — you have v%s."\
			%[latest, Telemetry.game_version()]
	_gate_mode("update", msg)




func _gate_raise(mode: String, msg: = "", data: Variant = null) -> void :



	if _gate_busy():
		_pending_gate = {"mode": mode, "msg": msg, "data": data}
		return
	if gate_root == null or not is_instance_valid(gate_root):
		_build_gate()
	if screen == Screen.PLAYING:
		conductor.stop()
	if mode == "update":
		_gate_show_update(data)
	else:
		_gate_mode(mode, msg)
	_update_mouse_mode()



func _gate_busy() -> bool:
	return screen == Screen.PLAYING or screen == Screen.EDITOR







func _heartbeat() -> void :
	if gate_root != null and is_instance_valid(gate_root):
		return
	var vc: Dictionary = await Telemetry.version_check()
	if gate_root != null and is_instance_valid(gate_root):
		return
	if vc.code == 0:
		_hb_fails += 1
		if _hb_fails >= HEARTBEAT_MAX_FAILS:
			_gate_raise("error")
		return
	_hb_fails = 0
	if not vc.ok or not (vc.data is Dictionary)\
	or not bool(vc.data.get("allowed", false)):
		_gate_raise("update", "", vc.data)
		return
	var st: Dictionary = await Telemetry.playtest_status()
	if gate_root != null and is_instance_valid(gate_root):
		return
	if st.ok and st.data is Dictionary and not bool(st.data.get("open", true)):
		_gate_raise("closed", str(st.data.get("message", "")
			if st.data.get("message") != null else ""))

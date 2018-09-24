extends Control

#Positions
var screen_size     : Vector2
var touch_position  : Vector2
var start_position  : Vector2

#Nodes
var front         : Sprite
var mask1         : ColorRect
var mask2         : ColorRect
var dragged       : bool
var deg = 1
enum FOLD_POSITIONS { LEFT_TOP, RIGHT_TOP, LEFT_BOTTOM, RIGHT_BOTTOM }
export var PADDING : float = 80
export(FOLD_POSITIONS) var FOLD_POSITION = RIGHT_TOP

var accumulate = 0
func _ready():
	front  = $Front as Sprite
	mask1  = $Mask1 as ColorRect
	mask2  = $Mask2 as ColorRect
	
	screen_size         = get_viewport().size;
	configure()
	start_position      = get_start_position()
	front.position      = start_position
	touch_position      = start_position
	mask1.rect_position = get_mask_position()
	mask2.rect_position = get_mask_position()

func get_start_position() -> Vector2:
	var init_vector : Vector2;
	match FOLD_POSITION:
		LEFT_TOP:
			init_vector = Vector2(PADDING, PADDING)
		LEFT_BOTTOM:
			init_vector = Vector2(PADDING, screen_size.y - PADDING)
		RIGHT_TOP:
			init_vector = Vector2(screen_size.x - PADDING, PADDING)
		RIGHT_BOTTOM:
			init_vector = Vector2(screen_size.x - PADDING, screen_size.y - PADDING)
	return init_vector

func get_real_position() -> Vector2:
	var real_position : Vector2
	match FOLD_POSITION:
		LEFT_TOP:
			real_position = Vector2(touch_position.x, -touch_position.y)
		LEFT_BOTTOM:
			real_position = Vector2(touch_position.x, (screen_size.y-touch_position.y))
		RIGHT_TOP:
			real_position = Vector2(-(screen_size.x-touch_position.x), -touch_position.y)
		RIGHT_BOTTOM:
			real_position = Vector2(-(screen_size.x-touch_position.x), (screen_size.y-touch_position.y))
	return real_position;

func get_mask_position() -> Vector2:
	var init_vector : Vector2 = get_real_position()
	init_vector               = init_vector / 2
	match FOLD_POSITION:
		LEFT_TOP:
			init_vector = Vector2(-init_vector.x + touch_position.x, init_vector.y + touch_position.y)
		LEFT_BOTTOM:
			init_vector = Vector2(-init_vector.x + touch_position.x, init_vector.y + touch_position.y)
		RIGHT_TOP:
			init_vector = Vector2(abs(init_vector.x) + touch_position.x, init_vector.y + touch_position.y)
		RIGHT_BOTTOM:
			init_vector = Vector2(abs(init_vector.x) + touch_position.x, abs(init_vector.y) + touch_position.y)
	return init_vector

func fold():
	var rotation       : float
	var rotation_mask1 : float
	var rotation_mask2 : float
	var current_position = get_real_position()
	var theta            = atan2(current_position.x, current_position.y)
	rotation             = (-(90 - rad2deg(theta)) * 2)
	match FOLD_POSITION:
		LEFT_TOP:
			rotation_mask1 = deg2rad( (rotation * 0.5) - 180 )
			rotation_mask2 = deg2rad( (rotation * 0.5) - 90  )
		LEFT_BOTTOM:
			rotation_mask1 = deg2rad( (rotation * 0.5) - 180 )
			rotation_mask2 = deg2rad( (rotation * 0.5) - 90  )
		RIGHT_TOP:	
			rotation_mask1 = deg2rad( (rotation * 0.5) + 180 )
			rotation_mask2 = deg2rad( (rotation * 0.5) + 90  )
		RIGHT_BOTTOM:
			rotation_mask1 = deg2rad( (rotation * 0.5) + 180 )
			rotation_mask2 = deg2rad( (rotation * 0.5) + 90  )
	front.position      = touch_position
	mask1.rect_position = get_mask_position()
	mask2.rect_position = get_mask_position()
	front.rotation      = deg2rad(rotation) 
	mask1.set_rotation( rotation_mask1 )
	mask2.set_rotation( rotation_mask2 )

func configure():
	front.flip_h = true
	front.flip_v = false
	match FOLD_POSITION: #Change pivot position
		LEFT_TOP:
			front.offset = Vector2(-front.get_texture().get_size().x, 0)
			mask1.rect_scale = Vector2(1, -1)
			mask2.rect_scale = Vector2(1, -1)
		LEFT_BOTTOM:
			front.offset = Vector2(-front.get_texture().get_size().x, -front.get_texture().get_size().y)
			mask1.rect_scale = Vector2(1, 1)
			mask2.rect_scale = Vector2(-1, -1)
		RIGHT_TOP:
			front.offset = Vector2(0, 0)
		RIGHT_BOTTOM:
			front.offset = Vector2(0, -front.get_texture().get_size().y)
			mask1.rect_scale = Vector2(1, -1)
			mask2.rect_scale = Vector2(-1, 1)

func _process(delta):
	fold()

func _input(event):
	if (event is InputEventMouseButton) or (event is InputEventScreenTouch):
		if event.pressed:
			dragged = true
			front.position = touch_position
			mask1.rect_position = get_mask_position()
			mask2.rect_position = get_mask_position()
		else:
			dragged = false
			var tween = $Tween
			tween.interpolate_property(self, "touch_position", touch_position, 
						start_position, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT).start()
	
	if (event is InputEventMouseMotion) or (event is InputEventScreenDrag):
		if dragged:
			touch_position = event.position
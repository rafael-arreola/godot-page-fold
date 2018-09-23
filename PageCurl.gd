extends Control

var SCREEN         : Vector2
var _position      : Vector2
var TOUCH          : Vector2
var _front         : Sprite
var _mask          : ColorRect
var _mask2         : ColorRect
var _isDragged     : bool
export var _padding : float = 80

var accumulate = 0
func _ready():
	SCREEN          = get_viewport().size;
	_position       = Vector2(SCREEN.x - _padding, _padding)
	_front          = $FrontBackground as Sprite
	_mask           = $Mask  as ColorRect
	_mask2           = $Mask2  as ColorRect
	_front.position = _position
	TOUCH           = _position
	_mask.rect_position = mask_position()
	_mask2.rect_position = mask_position()

func virtual_position() -> Vector2:
	return Vector2(-(SCREEN.x-TOUCH.x), -TOUCH.y)

func mask_position() -> Vector2 :
	var mask_position = ((virtual_position() / 2) as Vector2)
	mask_position.x = abs(mask_position.x) + TOUCH.x
	mask_position.y = mask_position.y + TOUCH.y
	return mask_position;
	
func _process(delta):
	var localPosition : Vector2 = _front.position
	
	if _isDragged:
		localPosition = TOUCH
	var theta    : float = atan2(virtual_position().x, virtual_position().y)
	var rotation : float = -(90 - rad2deg(theta)) * 2
	_front.rotation = deg2rad(rotation)
	_mask.set_rotation( deg2rad( (rotation * 0.5) + 180  ) )
	_mask2.set_rotation( deg2rad( (rotation * 0.5) + 90 ) )
	
func _input(event):
	if (event is InputEventMouseButton) or (event is InputEventScreenTouch):
		if event.pressed:
			_isDragged = true
			_front.position = TOUCH
			_mask.rect_position = mask_position()
			_mask2.rect_position = mask_position()
		else:
			_isDragged = false

	if (event is InputEventMouseMotion) or (event is InputEventScreenDrag):
		if _isDragged:
			TOUCH = event.position
			_front.position = TOUCH
			_mask.rect_position = mask_position()
			_mask2.rect_position = mask_position()
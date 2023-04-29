extends Label


var animation = ["       ", "       ", " >     ", " > >   ", " > > > "]
var playing = false
var current_index = 0
var counter = 0


func _ready():
	text = animation[0]


func _process(delta):
	if playing:
		if counter < 0.10:
			counter += delta
		else:
			visible = true
			counter = 0
			current_index += 1
			if current_index > 4:
				current_index = 0
			text = animation[current_index]
	else:
		visible = false

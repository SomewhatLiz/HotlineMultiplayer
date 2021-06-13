extends Label

var numMsgs = 0

func test_addDeath() -> void:
	text = ""
	addDeath("boo", "ghost")
	assert(text == "boo -X> ghost\n", "Test failed for addDeath")
	addDeath("boo1", "ghost")
	addDeath("boo2", "ghost")
	addDeath("boo3", "ghost")
	addDeath("boo4", "ghost")
	addDeath("boo5", "ghost")
	assert(text == "boo1 -X> ghost\n" +\
		"boo2 -X> ghost\n" +\
		"boo3 -X> ghost\n" +\
		"boo4 -X> ghost\n" +\
		"boo5 -X> ghost\n", "Test failed for addDeath, had:\n" + text)
	var timer := Timer.new()
	timer.one_shot = true
	timer.autostart = true
	add_child(timer)
	timer.connect("timeout", self, "timeout")
	
	print("All test cases for test_addDeath passed")
func timeout():
	addDeath("boo", "ghost")
	print("add death")

func _ready():
	text = ""
	#test_addDeath()

func addDeath(killer : String, killed : String) -> void:
	text += killer + " -X> " + killed + "\n"
	numMsgs += 1
	if numMsgs > 5:
		text = text.right(text.find("\n") + 1)
		numMsgs -= 1
	



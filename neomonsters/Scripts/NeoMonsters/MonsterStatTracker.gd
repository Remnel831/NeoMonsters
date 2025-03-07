extends Node


const MAXHUNGER = 100
const MAXMOOD = 100
const MAXSLEEP = 100

const HUNGERRATE = 20
const MOODRATE = 15
const SLEEPRATE = 10


#starting these at one.  So it'll take about an hour for the pet to get hungry I think.  This can be tuned later
const HUNGERDECREASE = 1
const MOODDECREASE = 1
const SLEEPDECREASE = 1

#starting these all at 100 but they'll hopefully save when the game does
var currentHunger = 100
var currentMood = 100
var currentSleep = 100


func hunger_timer():
	var hungryTimer = Timer.new()
	hungryTimer.autostart = true
	hungryTimer.wait_time = HUNGERRATE
	hungryTimer.timeout.connect(decrease_vitals(currentHunger, HUNGERDECREASE))

func mood_timer():
	var grumpyTimer = Timer.new()
	grumpyTimer.autostart = true
	grumpyTimer.wait_time = MOODRATE
	grumpyTimer.timeout.connect(decrease_vitals(currentMood, MOODDECREASE))

func sleep_decrease_Timer():
	var tiredTimer = Timer.new()
	tiredTimer.autostart = true
	tiredTimer.wait_time = SLEEPRATE	
	tiredTimer.timeout.connect(decrease_vitals(currentSleep, SLEEPDECREASE))

func sleep_increase_timer(bedRate):
	if(currentSleep < MAXSLEEP):
		while(currentSleep < MAXSLEEP):
			currentSleep += bedRate
		if(currentSleep > MAXSLEEP):
			currentSleep = MAXSLEEP
	

#handles all 3 stats that are managed by their respective timers
func decrease_vitals(stat, decrease):
	stat -= decrease

func feed_monster(foodvalue):
	currentHunger += foodvalue

func increase_mood(playValue):
	currentMood += playValue



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hunger_timer()
	sleep_decrease_Timer()
	mood_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

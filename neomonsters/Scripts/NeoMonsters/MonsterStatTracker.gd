extends Node

const MAXHUNGER = 100
const MAXMOOD = 100
const MAXSLEEP = 100

const MINSTAT = 0

const HUNGERRATE = 20
const MOODRATE = 10
const SLEEPRATE = 10


#starting these at one.  So it'll take about an hour for the pet to get hungry I think.  This can be tuned later
const HUNGERDECREASE = 1
const MOODDECREASE = 1
const SLEEPDECREASE = 1

#starting these all at 100 but they'll hopefully save when the game does
var currentHunger = 100
var currentMood = 100
var currentSleep = 100


#signals
signal hungry_signal
signal grumpy_signal
signal sleepy_signal
signal idle_signal


func hunger_timer():
	var hungryTimer = Timer.new()
	hungryTimer.autostart = true
	hungryTimer.wait_time = HUNGERRATE
	add_child(hungryTimer)
	hungryTimer.timeout.connect(hunger_tick)

func mood_timer():
	var grumpyTimer = Timer.new()
	grumpyTimer.autostart = true
	grumpyTimer.wait_time = MOODRATE
	add_child(grumpyTimer)
	grumpyTimer.timeout.connect(mood_tick)

func sleep_decrease_Timer():
	var tiredTimer = Timer.new()
	tiredTimer.autostart = true
	tiredTimer.wait_time = SLEEPRATE	
	add_child(tiredTimer)
	tiredTimer.timeout.connect(sleep_tick)

func sleep_increase_timer(bedRate):
	if(currentSleep < MAXSLEEP):
		while(currentSleep < MAXSLEEP):
			currentSleep += bedRate
		if(currentSleep > MAXSLEEP):
			currentSleep = MAXSLEEP
			idle_signal.emit()

	
func hunger_tick():
	currentHunger -= HUNGERDECREASE
	if(currentHunger <= 0):
		currentHunger = 0
		hungry_signal.emit()


func mood_tick():
	currentMood -= MOODDECREASE
	if(currentMood <= 0):
		currentMood = 0
		grumpy_signal.emit()
	print(currentMood)
	
func sleep_tick():
	currentSleep -= SLEEPDECREASE
	if(currentSleep <= 0):
		currentSleep = 0
		sleepy_signal.emit()

func feed_monster(foodvalue):
	currentHunger += foodvalue

func increase_mood(playValue):
	currentMood += playValue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hunger_timer()
	sleep_decrease_Timer()
	mood_timer()

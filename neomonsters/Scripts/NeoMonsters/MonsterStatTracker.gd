extends Node
class_name MonsterStats

#Setting these as constants here.  Some monsters could have different max values to make differences more
#than just visuals.
const MAXHUNGER = 100
const MAXMOOD = 100
const MAXSLEEP = 100

#Stats can't go negative.
const MINSTAT = 0

#How quickly the timers tick down.
const HUNGERRATE = 10
const MOODRATE = 15
const SLEEPRATE = 20


#starting these at one.  So it'll take about an hour for the pet to get hungry I think.  
#This can be tuned later
var hungerdecrease = 1
var mooddecrease = 1
var sleepdecrease = 1

#starting these all at 100 but they'll hopefully save when the game does
var currentHunger = 100
var currentMood = 100
var currentSleep = 100


#signals when a stat hits 0
signal hungry_signal
signal grumpy_signal
signal sleepy_signal
signal idle_signal

#Signals whenever a stat ticks down.
signal hunger_changed
signal mood_changed
signal sleep_changed



func hunger_timer():
	#Starts the timer automatically and makes it restart when it hits 0
	var hungryTimer = Timer.new()
	hungryTimer.autostart = true
	hungryTimer.wait_time = HUNGERRATE
	add_child(hungryTimer)
	#When it hits 0 the timer calls its matching tick function.
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


#not currently implemented.  Sleeping in a bed will restore a monsters energy.
func sleep_increase_timer(bedRate):
	if(currentSleep < MAXSLEEP):
		while(currentSleep < MAXSLEEP):
			sleep_changed.emit()
			currentSleep += bedRate
		if(currentSleep > MAXSLEEP):
			currentSleep = MAXSLEEP
			idle_signal.emit()

	
func hunger_tick():
	#subtracts the decrease value from the current anytime the function is called.
	currentHunger -= hungerdecrease
	#calls the matching change signal to update the bars
	hunger_changed.emit()
	
	#if hunger is above 0 the sleep decrease remains the normal 1%
	if(currentHunger > 0):
		sleepdecrease = 1
		
	elif(currentHunger <= 0):
		currentHunger = 0
		#if the monster is starving it starts to get tired faster.
		sleepdecrease = 2
		#emits the hungry signal to tell the face animation to play the hungry emote.
		hungry_signal.emit()


func mood_tick():
	currentMood -= mooddecrease
	mood_changed.emit()
	if(currentMood > 0):
		hungerdecrease = 1
	elif(currentMood <= 0):
		currentMood = 0
		#Mood increases hunger loss just to complete the triangle.  I guess the monster likes to stress eat? 
		hungerdecrease = 2
		grumpy_signal.emit()
	
	#decreases sleep when the timer ticks.  If sleep = 0 the mood decrease doubles 
func sleep_tick():
	currentSleep -= sleepdecrease
	sleep_changed.emit()
	if(currentSleep > 0):
		mooddecrease = 1
	elif(currentSleep <= 0):
		currentSleep = 0
		mooddecrease = 2
		sleepy_signal.emit()

#Takes the food value and adds it back to the current hunger.
func feed_monster(foodvalue):
	currentHunger += foodvalue
	#prevents the monster from getting more food than its max.
	if(currentHunger > MAXHUNGER):
		currentHunger = MAXHUNGER

#increases the mood based on the input.  Toys will passively add mood but minigames will add a lot more.
func increase_mood(playValue):
	currentMood += playValue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hunger_timer()
	sleep_decrease_Timer()
	mood_timer()

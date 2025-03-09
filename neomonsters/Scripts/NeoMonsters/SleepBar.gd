extends ProgressBar

@export var monsterStats : MonsterStats



func _ready():
	monsterStats.sleep_changed.connect(update_sleep)
	update_sleep()
	

func update_sleep():
	value = monsterStats.currentSleep * 100 / monsterStats.MAXSLEEP

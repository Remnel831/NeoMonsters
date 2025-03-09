extends ProgressBar

@export var monsterStats : MonsterStats



func _ready():
	monsterStats.mood_changed.connect(update_mood)
	update_mood()
	

func update_mood():
	value = monsterStats.currentMood * 100 / monsterStats.MAXMOOD

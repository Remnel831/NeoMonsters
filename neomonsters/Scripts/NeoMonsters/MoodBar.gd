extends ProgressBar

@export var monsterStats : MonsterStats


#connects the monsterStats change signal to the update function for the bar.
func _ready():
	monsterStats.mood_changed.connect(update_mood)
	update_mood()
	

func update_mood():
	#sets the bars current value to match the % remaining of the monsters max mood value.
	value = monsterStats.currentMood * 100 / monsterStats.MAXMOOD

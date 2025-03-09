extends ProgressBar

@export var monsterStats : MonsterStats



func _ready():
	monsterStats.hunger_changed.connect(update_hunger)
	update_hunger()
	

func update_hunger():
	value = monsterStats.currentHunger * 100 / monsterStats.MAXHUNGER

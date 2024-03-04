
extends Node

# Steam variables
var IS_OWNED: bool = false
var IS_ONLINE: bool = false
var STEAM_APP_ID: int = 2636960
var STEAM_ID: int = 0

var ACHIEVEMENTS: Dictionary = {'Welcome':false, "achieve2":false, "achieve3":false}

func _init() -> void:
	# Set your game's Steam app ID here
	OS.set_environment("SteamAppId", str(STEAM_APP_ID))
	OS.set_environment("SteamGameId", str(STEAM_APP_ID))

func _initialize_Steam() -> void:
	var INIT: Dictionary = Steam.steamInit()
	# print("Did Steam initialize?: "+str(INIT))
	
	#if INIT['status'] > 0:
	#	print("Failed to initialize Steam. "+str(INIT['verbal'])+" Shutting down...")
	#	get_tree().quit()
		
	IS_ONLINE = Steam.loggedOn()
	STEAM_ID = Steam.getSteamID()
	IS_OWNED = Steam.isSubscribed()

	# Check if account owns the game
	#if IS_OWNED == false:
	#	# logging.error("User does not own this game")
	#	get_tree().quit()
		
func _get_Achievement(value: String) -> void:
	var ACHIEVEMENT: Dictionary = Steam.getAchievement(value)
	# Achievement exists
	if ACHIEVEMENT['ret']:
		# Achievement is unlocked
		if ACHIEVEMENT['achieved']:
			ACHIEVEMENTS[value] = true
		# Achievement is locked
		else:
			ACHIEVEMENTS[value] = false
	# Achievement does not exist
	else:
		ACHIEVEMENTS[value] = false

func _ready():
	_initialize_Steam()
	Steam.setAchievement('Welcome')
	Steam.storeStats()
	
	pass

func _physics_process(delta):
	Steam.run_callbacks()
	# print(Engine.get_frames_per_second())
	pass

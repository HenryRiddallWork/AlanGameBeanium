@tool
extends Node

@export var folder := "res://sounds/sfx"
@export var output_path := "res://data/sound_database.tres"


@export var run_generation := false : set = _run_pressed

func _ready() -> void:
	generate_database()

func _run_pressed(value):
	if value:
		generate_database()
		run_generation = false

func generate_database():
	DirAccess.make_dir_recursive_absolute(output_path)

	var dir := DirAccess.open(folder)
	if dir == null:
		push_error("Cannot open folder: " + folder)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if !dir.current_is_dir():
			var ext := file_name.get_extension().to_lower()

			if ext in ["wav", "ogg", "mp3"]:
				var audio_path := folder.path_join(file_name)
				var stream := load(audio_path) as AudioStream

				if stream:
					var taunt := Taunt.new()
					taunt.sound = stream					taunt.text = format_taunt_name(file_name.get_basename()) # or custom logic

					var save_path := output_path.path_join(file_name.get_basename() + ".tres")

					var err := ResourceSaver.save(taunt, save_path)
					if err != OK:
						push_error("Failed to save: " + save_path + " error: " + str(err))

		file_name = dir.get_next()

	dir.list_dir_end()

	print("Taunts generated.")

func format_taunt_name(file_name: String) -> String:
	# remove extension if accidentally included
	var base := file_name.get_basename()

	# replace underscores with spaces
	base = base.replace("_", " ")

	# optional: trim extra spaces
	base = base.strip_edges()

	# capitalize first letter of each word
	base = base.capitalize()

	# add exclamation mark
	return base + "!"

extends SceneTree

func _init():
	for kid_name in ["Kid1", "Kid2", "Kid3", "Kid4"]:
		var path = "res://scenes/" + kid_name + ".tscn"
		var packed = load(path)
		if packed:
			var scene = packed.instantiate()
			var script = load("res://scripts/kid.gd")
			scene.set_script(script)
			var new_packed = PackedScene.new()
			new_packed.pack(scene)
			ResourceSaver.save(new_packed, path)
			print("Updated ", kid_name)
	quit()

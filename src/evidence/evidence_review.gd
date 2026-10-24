extends Node2D
## Separate authoring inspection scene: no mutation of the playable investigation.
var dialogue := ""
var clue_found := false
var evidence: CanvasLayer
var ids: Array = []
var index := 0
var footer: Label

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("#081219"))
	evidence = preload("res://src/evidence/evidence_controller.gd").new()
	evidence.owner_room = self
	evidence.memory_enabled = false
	add_child(evidence)
	for id in evidence.state.catalog.definitions:
		for instance_id in evidence.state.catalog.instances:
			if evidence.state.item(instance_id).definition == id:
				ids.append(instance_id)
				break
	var hud := CanvasLayer.new()
	hud.layer = 31
	add_child(hud)
	var labels := ["< Previous", "Next >", "Variant", "Find lens"]
	var actions := [previous, next, variant, lens]
	for i in labels.size():
		var button := Button.new()
		button.text = labels[i]
		button.position = Vector2(16 + i * 114, 2)
		button.size = Vector2(106, 24)
		button.add_theme_font_size_override("font_size", 12)
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(actions[i])
		hud.add_child(button)
	footer = Label.new()
	footer.position = Vector2(16, 340)
	footer.add_theme_font_size_override("font_size", 10)
	hud.add_child(footer)
	show_current()

func show_current() -> void:
	var id: String = ids[index]
	evidence.open_object(id)
	footer.text = "ART REVIEW %d/%d | %s | %s | local sample, no save" % [index + 1, ids.size(), evidence.state.item(id).condition, evidence.state.item(id).forensic]

func previous() -> void:
	index = posmod(index - 1, ids.size())
	show_current()

func next() -> void:
	index = (index + 1) % ids.size()
	show_current()

func variant() -> void:
	var id: String = ids[index]
	var item: Dictionary = evidence.state.item(id)
	var definition: Dictionary = evidence.state.definition(id)
	var conditions: Array = definition.conditions.keys()
	item.condition = conditions[(conditions.find(item.condition) + 1) % conditions.size()]
	# Reconfigure only this review sample; production instances never change here.
	item.forensic = definition.allowed_forensics.back()
	if not evidence.state.valid_instance(item):
		item.forensic = "none"
	evidence.state.records.erase(id)
	show_current()

func lens() -> void:
	index = ids.find("foyer-lens")
	show_current()

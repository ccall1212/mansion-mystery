extends SceneTree
const State = preload("res://src/evidence/evidence_state.gd")
var failures: Array[String] = []
var checks := 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)

func _initialize() -> void:
	var state = State.new()
	check(state.validate_catalog(), "catalog validation")
	check(not state.has_lens(), "lens starts unavailable")
	var normal: String = state.visible_asset("foyer-knife", true)
	var first: Dictionary = state.inspect("foyer-knife")
	check(not first.text.contains("specks") and first.inset.is_empty(), "ordinary inspection hides evidence")
	check(not state.inspect("foyer-knife", "tool").ok, "tool gate before collection")
	check(not state.record("foyer-knife").magnified, "blocked tool does not mutate discovery")
	check(state.inspect("foyer-knife", "detailed").text.contains("straight"), "condition-specific detail")
	check(state.inspect("foyer-knife", "detailed").text.contains("remember"), "repeat detail stage")
	state.inspect("foyer-lens")
	check(not state.has_lens(), "seeing tool does not grant inventory")
	check(state.collect("foyer-lens").ok and state.has_lens(), "explicit collection grants tool")
	check(not state.record("foyer-knife").discovered, "ownership does not auto reveal")
	var innocent = State.new()
	innocent.catalog.instances["foyer-knife"].forensic = "none"
	innocent.collect("foyer-lens")
	check(innocent.visible_asset("foyer-knife", true) == normal and innocent.inspect("foyer-knife", "tool").inset.is_empty(), "same knife artwork supports clean configuration")
	var result: Dictionary = state.inspect("foyer-knife", "tool")
	check(result.ok and result.new_discovery and not result.inset.is_empty(), "configured forensic discovery")
	check(state.visible_asset("foyer-knife", true) == normal, "ordinary image remains independent of forensics")
	check(not state.inspect("foyer-knife", "tool").new_discovery, "repeated use does not duplicate discovery")
	check(state.journal_entry("foyer-knife").contains("specks"), "notebook remembers finding")
	for id in ["foyer-mirror", "review-bottle", "review-stool", "review-poker"]:
		result = state.inspect(id, "tool")
		check(result.ok and not result.new_discovery and result.inset.is_empty() and not state.record(id).discovered, "innocent control " + id)
	for id in ["review-bust", "review-hammer"]:
		result = state.inspect(id, "tool")
		check(result.new_discovery and not result.inset.is_empty(), "non-blood forensic " + id)
	check(not state.collect("review-bust").ok, "in-place statue cannot be pocketed")
	check(state.collect("foyer-knife").ok and state.record("foyer-knife").collected, "collectible knife")
	var clone = State.new()
	check(clone.restore(state.snapshot()) and clone.snapshot() == state.snapshot(), "round-trip persistence")
	var prior: Dictionary = clone.snapshot()
	var invalid: Dictionary = prior.duplicate(true)
	invalid.records["unknown"] = invalid.records["foyer-knife"].duplicate()
	check(not clone.restore(invalid) and clone.snapshot() == prior, "unknown instance rejected atomically")
	invalid = prior.duplicate(true)
	invalid.records["review-stool"].discovered = true
	check(not clone.restore(invalid), "fabricated innocent discovery rejected")
	invalid = prior.duplicate(true)
	invalid.records["foyer-lens"].collected = false
	check(not clone.restore(invalid), "tool-dependent history needs collected tool")
	check(not state.valid_instance({"definition":"bust", "condition":"intact", "forensic":"fiber"}), "incompatible condition/evidence rejected")
	check(not state.valid_instance({"definition":"knife", "condition":"broken", "forensic":"none"}), "unknown condition rejected")
	check(not state.valid_instance({"definition":"bottle", "condition":"sealed", "forensic":"red_trace"}), "unsupported evidence rejected")
	for id in state.catalog.definitions:
		var images: Array = []
		for condition in state.catalog.definitions[id].conditions.values():
			check(ResourceLoader.exists(condition.asset) and ResourceLoader.exists(condition.closeup), "imported art " + condition.asset)
			check(not images.has(condition.asset), "distinct condition asset " + condition.asset)
			images.append(condition.asset)
	DirAccess.make_dir_recursive_absolute("res://test-results")
	var report := FileAccess.open("res://test-results/evidence-engine-tests.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"ok":failures.is_empty(), "checks":checks, "failures":failures}, "  "))
	report.close()
	print("EVIDENCE_CHECKS ", checks, " ", failures)
	quit(0 if failures.is_empty() else 1)

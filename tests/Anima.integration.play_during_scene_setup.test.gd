extends "res://addons/gut/test.gd"

## Regression test for "Parent node is busy setting up children" — the very
## first Anima.play() call is often made from inside a node's own _ready(),
## e.g. a scene that starts a motion as soon as it loads. At that exact
## moment, Godot's scene tree root can still be mid-add_child() for the scene
## itself; AnimaRuntime.get_singleton() used to call add_child() on that same
## root directly, which the engine rejects as reentrant in that window.
##
## The engine's own busy/blocked window only occurs during real project
## startup (loading the configured main scene) — it can't be synthesized from
## a script already running inside an initialized SceneTree, so this verifies
## the actual fix mechanism instead: get_singleton() must defer adding itself
## to the tree (call_deferred), not call add_child() directly. A direct call
## succeeds immediately in a normal (non-busy) context, which is exactly the
## case this test would fail to catch if it just checked for zero errors here.
func test_get_singleton_defers_adding_itself_to_the_tree():
	AnimaRuntime._instance = null

	var runtime := AnimaRuntime.get_singleton()
	assert_false(runtime.is_inside_tree(), "add_child should be deferred, not called directly — a direct call would already be in the tree at this point")

	await get_tree().process_frame
	assert_true(runtime.is_inside_tree(), "the deferred add_child should still take effect by the next frame")

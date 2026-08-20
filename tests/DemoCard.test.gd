extends "res://addons/gut/test.gd"

func _make_card() -> DemoCard:
	var card: DemoCard = preload("res://examples/playground/shared/components/demo_card.tscn").instantiate()
	add_child_autofree(card)
	return card

func test_authored_content_reaches_its_labels():
	var card := _make_card()
	card.title = "Grid Motion"
	card.description = "Propagation formulas across a 5×5 card grid."
	card.icon_glyph = "▦"

	assert_eq(card.get_node("%Title").text, "Grid Motion")
	assert_eq(card.get_node("%Description").text, "Propagation formulas across a 5×5 card grid.")
	assert_eq(card.get_node("%IconLabel").text, "▦")

func test_defaults_to_unselected_border():
	var card := _make_card()
	var style: StyleBoxFlat = card.get_theme_stylebox("normal")

	assert_eq(style.border_color, DemoCard.BORDER)

func test_hover_brightens_the_border_and_exit_restores_it():
	var card := _make_card()

	card.mouse_entered.emit()
	assert_eq(card.get_theme_stylebox("normal").border_color, DemoCard.BORDER_ACTIVE)

	card.mouse_exited.emit()
	assert_eq(card.get_theme_stylebox("normal").border_color, DemoCard.BORDER)

func test_focus_brightens_the_border_and_losing_focus_restores_it():
	var card := _make_card()

	card.focus_entered.emit()
	assert_eq(card.get_theme_stylebox("normal").border_color, DemoCard.BORDER_ACTIVE)

	card.focus_exited.emit()
	assert_eq(card.get_theme_stylebox("normal").border_color, DemoCard.BORDER)

func test_pressing_the_card_emits_pressed():
	var card := _make_card()
	watch_signals(card)

	card.pressed.emit()

	assert_signal_emitted(card, "pressed")

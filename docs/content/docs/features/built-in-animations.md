---
title: "Built-in Animations"
description: "Every animation the addon ships, by category"
---

Anima ships 99 ready-made animations across 16 categories, ported from
Anima v1. Play any of them by name — no need to author your own motion for a
common effect like a fade, a bounce, or an entrance/exit slide.

```gdscript
Anima.play(Anima.animation("tada"), $Card)
```

`Anima.animation(name)` looks the preset up by its exact name below and
returns the same shared resource every time — see
[Reusable vs. Single-Shot](../../guides/reusable-vs-single-shot) if you need
an independent copy to modify.

## Catalog

### Attention Seeker
`bounce`, `flash`, `headshake`, `heartbeat`, `jello`, `pulse`, `rubber_band`,
`shake_x`, `shake_y`, `swing`, `tada`, `wobble`

### Back Entrances
`back_in_down`, `back_in_left`, `back_in_right`, `back_in_up`

### Back Exits
`back_out_down`, `back_out_left`, `back_out_right`, `back_out_up`

### Bouncing Entrances
`bouncing_in`, `bouncing_in_down`, `bouncing_in_left`, `bouncing_in_right`,
`bouncing_in_up`

### Bouncing Exits
`bounce_out`, `bounce_out_down`, `bounce_out_left`, `bounce_out_right`,
`bounce_out_up`

### Fading Entrances
`fade_in`, `fade_in_bottom_left`, `fade_in_bottom_right`, `fade_in_down`,
`fade_in_down_big`, `fade_in_left`, `fade_in_left_big`, `fade_in_right`,
`fade_in_right_big`, `fade_in_small`, `fade_in_top_left`, `fade_in_top_right`,
`fade_in_up`, `fade_in_up_big`

### Fading Exits
`fade_out`, `fade_out_bottom_left`, `fade_out_bottom_right`, `fade_out_down`,
`fade_out_down_big`, `fade_out_left`, `fade_out_left_big`, `fade_out_right`,
`fade_out_right_big`, `fade_out_top_left`, `fade_out_top_right`, `fade_out_up`,
`fade_out_up_big`

### Lightspeed
`light_speed_in_left`, `light_speed_in_right`, `light_speed_out_left`,
`light_speed_out_right`

### Rotating Entrances
`rotate_in`, `rotate_in_down_left`, `rotate_in_down_right`,
`rotate_in_up_left`, `rotate_in_up_right`

### Rotating Exits
`rotate_out`, `rotate_out_down_left`, `rotate_out_down_right`,
`rotate_out_up_left`, `rotate_out_up_right`

### Slide Exits
`slide_out_down`, `slide_out_left`, `slide_out_right`, `slide_out_up`

### Sliding Entrances
`slide_in_down`, `slide_in_left`, `slide_in_right`, `slide_in_up`

### Specials
`hinge`, `jack_in_the_box`, `roll_in`, `roll_out`

### Text
`typewrite` — see the [Keyframes](../../guides/keyframes)
guide for how its reveal and content-length-scaled duration work.

### Zooming Entrances
`zoom_in`, `zoom_in_down`, `zoom_in_down_big`, `zoom_in_left`,
`zoom_in_left_big`, `zoom_in_right`, `zoom_in_right_big`, `zoom_in_up`,
`zoom_in_up_big`

### Zooming Exits
`zoom_out`, `zoom_out_down`, `zoom_out_down_big`, `zoom_out_left`,
`zoom_out_right`, `zoom_out_up`

For the full `Anima.animation()` contract, see the generated
[Anima](../../anima/anima) reference page.

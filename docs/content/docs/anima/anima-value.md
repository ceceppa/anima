---
title: "AnimaValue"
description: "A motion property value resolved against live playback state instead of a"
---

# AnimaValue

## Overview

A motion property value resolved against live playback state instead of a
fixed literal — e.g. a target's own current size, or another node's
property — restoring Anima v1's dynamic-expression capability
(`"-.:size:x"`) in typed form. Accepted anywhere a fixed value is accepted
today: [member AnimaPropertyMotion.from_value]/[member
AnimaPropertyMotion.to_value] and [member AnimaKeyframeStop.value].

One polymorphic [Resource] with a [member kind] discriminator — the same
shape [AnimaEase] already uses for its own many kinds — rather than a
subtype per source (`tech-spec.md` §Dynamic values).

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Enumerations

### Kind

Which source [method resolve] reads from.

## Properties and constants

### kind

Which source [method resolve] reads from.

### constant_value

The wrapped literal, used only when [member kind] is [constant Kind.CONSTANT].

### property_path

The property to read, used by [constant Kind.TARGET], [constant Kind.NODE],
and [constant Kind.ROOT].

### node_path

The other node's path, relative to the resolving context's own root — used
only when [member kind] is [constant Kind.NODE].

### context_key

The key to read from the playback's context data — used only when [member
kind] is [constant Kind.CONTEXT].

### operands

Each entry is a literal [Variant] or a nested [AnimaValue], resolved in
order before the operation itself runs. Used by every arithmetic
[member kind]: index 0 is always the value the chain method was called
on; the rest depend on the operation (e.g. [constant Kind.CLAMP] is
`[value, min, max]`, [constant Kind.MAP] is
`[value, in_min, in_max, out_min, out_max]`).

### component_index

Which vector component to extract, used only when [member kind] is
[constant Kind.COMPONENT] (`0` = x, `1` = y, `2` = z).

### custom_callable

The author-supplied calculation, used only when [member kind] is
[constant Kind.CUSTOM]. Called with the same [AnimaValueContext]
[method resolve] itself receives.

## Methods

### constant

Wraps [param value] so it can serve as an operand in an arithmetic
combination, or as a value that happens to be typed [AnimaValue].

### target

Reads [param property] from the node this value is resolving for — Anima
v1's `.`/self reference.

### node

Reads [param property] from the node at [param path], resolved relative to
the resolving context's own root — Anima v1's arbitrary node-path
reference. A group/grid item's root is the group's own container, never
another item (`tech-spec.md` §Dynamic values).

### root

Reads [param property] directly from the resolving context's own root —
the group's own container for a group/grid item, or the animated target
itself for a plain motion.

### context

Reads [param key] from the data supplied to the playback before it started
(see [member AnimaPlayback.context_data]). Returns `null` if nothing was
stored under that key.

### group_index

Reads this item's position in start order among its group — `-1` outside
a group/grid item (see [member AnimaValueContext.group_index]).

### group_count

Reads the group's total item count — `-1` outside a group/grid item.

### group_normalised_index

Reads this item's [method group_index] normalised to `0.0`-`1.0` across
the group — `-1.0` outside a group/grid item.

### grid_row

Reads this item's row within an [AnimaGridMotion] — `-1` outside one.

### grid_column

Reads this item's column within an [AnimaGridMotion] — `-1` outside one.

### add

Combines this value with [param other] (a literal or another [AnimaValue])
by addition. Returns a new [AnimaValue] — this one is never mutated, so it
stays safe to reuse as the base of a different combination elsewhere.

### subtract

See [method add]. Subtracts [param other] from this value.

### multiply

See [method add]. Multiplies this value by [param other].

### divide

See [method add]. Divides this value by [param other].

### minimum

See [method add]. Resolves to whichever of this value and [param other] is smaller.

### maximum

See [method add]. Resolves to whichever of this value and [param other] is larger.

### negative

Negates this value. See [method add] for the "returns a new AnimaValue" contract.

### absolute

Resolves to the absolute value of this value.

### clamp

Clamps this value between [param min_value] and [param max_value] (each a
literal or another [AnimaValue]) — the resolved result never falls outside
those bounds, even when this value's own resolution would otherwise exceed
them.

### map

Linearly remaps this value from the range [param in_min]-[param in_max] to
[param out_min]-[param out_max] (each a literal or another [AnimaValue]).

### x

Extracts this value's x component. Fails validation at resolve time if
this value doesn't resolve to a vector.

### y

See [method x]. Extracts the y component.

### z

See [method x]. Extracts the z component.

### component

See [method x]. Extracts the component at [param index] (`0` = x, `1` = y, `2` = z).

### custom

Resolves through [param callable] instead of a structural operation above —
the escape hatch for a calculation those can't express (Anima v1's
formulas ran through Godot's full [Expression] parser, so arbitrary math
was implicitly available; this covers the same ground explicitly).
[param callable] receives the same [AnimaValueContext] [method resolve]
itself receives. Runtime-only: potentially non-serialisable,
non-compilable, and unavailable in editor preview, the same limitation
[constant AnimaEase.Kind.CALLABLE] already has.

### resolve

Resolves this value against [param context]. A [constant Kind.NODE]
reference that can't be found reports an error and returns `null` instead
of silently animating to an unresolved value.

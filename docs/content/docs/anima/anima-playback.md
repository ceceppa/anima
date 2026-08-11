---
title: "AnimaPlayback"
description: "Returned by [method Anima.play] — one call's live playback state and controls."
---

# AnimaPlayback

## Overview

Returned by [method Anima.play] — one call's live playback state and controls.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Enumerations

### State

Which lifecycle stage this playback is in.

## Signals

### finished

Emitted exactly once, on [constant State.FINISHED] or [constant State.CANCELLED].
[param success] is `true` only for a natural finish, `false` for a cancel.

## Properties and constants

### motion

The motion being played.

### target

The node it's playing against.

### state

Which lifecycle stage this playback is in.

### speed_scale

A multiplier applied to every frame this playback advances by, on top of
[member AnimaMotion.forward_speed]/[member AnimaMotion.reverse_speed] (see
[method _advance]). `1.0` is normal speed; `2.0` runs twice as fast; `0.5`
runs at half speed. When [member motion] is an [AnimaGroupMotion], every
active item shares this same scaled delta, so changing it affects the
whole group as one playback.

### context_data

Arbitrary data an [AnimaValue] built with [method AnimaValue.context] can
read during this playback (see [member AnimaValueContext.context_data]).
Mutate this dictionary in place before playback resolves any value that
reads it — reassigning the whole dictionary after construction leaves an
already-built context pointing at the old one.

## Methods

### pause

Freezes the animated value in place until [method resume].

### resume

Continues playback from wherever [method pause] froze it.

### cancel

Stops playback and resolves [signal finished] as not-successful. The value
left on [member target] follows [member AnimaMotion.cancellation_value_policy]:
[constant AnimaMotion.CancellationValuePolicy.KEEP_CURRENT] (default) leaves
whatever was showing at the moment of cancellation — today's actual
behaviour, unchanged. [constant AnimaMotion.CancellationValuePolicy.RESTORE_INITIAL]
re-applies the pre-animation snapshot. [constant AnimaMotion.CancellationValuePolicy.COMPLETE]
applies the motion's authored end value(s) — the same value [method complete]
would produce — but this is still reported as a cancellation: [signal finished]
still emits `false` and [member AnimaMotion.on_completed_callback] never fires.

### complete

Forces this playback to its valid final state immediately: applies every
active motion's authored end value(s), fires [member
AnimaMotion.on_completed_callback] and [signal finished] as a successful
finish exactly once — the same as a natural finish — then applies [member
AnimaMotion.completion_value_policy]. [constant AnimaMotion.CompletionValuePolicy.KEEP_FINAL]
(default) leaves that end value in place. [constant
AnimaMotion.CompletionValuePolicy.RESTORE_INITIAL] re-applies the
pre-animation snapshot immediately after [signal finished] reports success.
A no-op past [constant State.FINISHED]/[constant State.CANCELLED].

### revert

Unconditionally restores [member target] to the value captured before
playback started, and stops playback: [constant State.CANCELLED], [signal
finished] emits `false`. Unlike [method cancel], the value left behind is
never affected by [member AnimaMotion.cancellation_value_policy] — revert()
always restores. This is why revert and [method reverse] are not
equivalent: reverse() keeps playback running, now backward, from wherever
it was; revert() stops it and snaps to the start. A no-op past [constant
State.FINISHED]/[constant State.CANCELLED].

### retarget

Redirects a still-moving SPRING-eased AnimaPropertyMotion to a new
destination, preserving its current value/velocity instead of restarting
it from scratch. An error (not silently ignored) for any other motion
shape — composites and non-SPRING eases have no defined retarget behaviour.

### reverse

Reverses this playback, returning every target to what was actually
observed when the run began. For an [AnimaGroupMotion] (including
[AnimaGridMotion]), reuses its recorded target sequence instead of
resolving and scheduling it again — a [constant AnimaGroupOrder.Kind.RANDOM]
order does not reshuffle — replays each started item's own reversed motion
(see [method AnimaGroupPlayback.build_reversed_item_motions]) instead of
its original forward one, and restarts this same playback from the top,
respecting [member AnimaGroupMotion.reverse_order_policy] for item order.
For a leaf [AnimaPropertyMotion] or an [_AnimaSequence]/[_AnimaParallel]
composition of them (e.g. a target-bound motion authored through [method
Anima.on]), replaces [member motion] with a freshly built reversed motion
and restarts playback against it — see [method AnimaMotionInstance.build_reversed].
Returns `false` (and pushes an error, not silently ignored) when nothing
has been captured yet to reverse to, for every motion kind — the caller
can react (e.g. [method Anima.play_backwards] instead) rather than this
call being a silent no-op that leaves the original forward run untouched.

### step

Manually advances this playback by exactly [param delta] seconds, scaled
by the same effective speed (speed_scale × direction) [method _advance]
already applies for the automatic per-frame path — for tests, tools, or
frame-stepped debugging that want to drive playback themselves instead of
relying on [AnimaRuntime]'s own per-frame loop. No separate clock-mode
selection; this is a direct-drive entry point only.

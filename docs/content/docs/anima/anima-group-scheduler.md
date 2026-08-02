---
title: "AnimaGroupScheduler"
description: "Turns a resolved target list into a concrete, repeatable start schedule."
---

# AnimaGroupScheduler

## Overview

Turns a resolved target list into a concrete, repeatable start schedule.

[AnimaGroupOrder] describes an author's ordering choice in the abstract
("centred", "random with this seed", …). This helper turns that choice,
together with an [AnimaGroupDistribution] and playback mode, into the
actual per-target schedule group playback reads: which target starts
first, which targets start together as a wave, and — for a staggered
group — how many seconds after the group begins each one starts. It does
not run anything; see [AnimaGroupMotion] for playing a group.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Methods

### derive

Derives a [Schedule] for [param targets] using [param group]'s configured
[member AnimaGroupMotion.order], [member AnimaGroupMotion.distribution],
and [member AnimaGroupMotion.playback_mode].

[param targets] should already be resolved and filtered — this only
orders and schedules the list it's given; it does not resolve a target
collection itself. Calling this again with the same [param group]
configuration and the same [param targets] always produces the same
[Schedule], including for a [constant AnimaGroupOrder.Kind.RANDOM] order
with a fixed [member AnimaGroupOrder.seed].

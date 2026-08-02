---
title: "AnimaRace"
description: "Runs every enabled child in [member children] concurrently and completes"
---

# AnimaRace

## Overview

Runs every enabled child in [member children] concurrently and completes
as soon as the fastest one finishes.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### children

The motions racing against each other.

### cancel_remaining

Whether the runtime stops advancing the other children once one finishes.
Setting this to `false` has no defined effect this phase.

## Methods

### estimate_duration

The fastest enabled child's duration (worst-kind-wins across children first).

### create_runtime

Builds the runtime instance that races every enabled child.

### validate

Validates every child recursively.

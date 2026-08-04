---
title: "AnimaDuration"
description: "A motion's reported duration: a kind (how certain it is) plus, when known,"
---

# AnimaDuration

## Overview

A motion's reported duration: a kind (how certain it is) plus, when known,
its length in seconds. Returned by [method AnimaMotion.estimate_duration].

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Enumerations

### Kind

Order matters: higher enum value = "worse" (less certain), used by worst_kind().

## Properties and constants

### kind

How certain this duration is.

### seconds

The duration in seconds. Meaningful only for [constant Kind.FIXED] and
[constant Kind.ESTIMATED]; `0.0` and unused for [constant Kind.DYNAMIC] /
[constant Kind.INFINITE].

## Methods

### fixed

Builds a [constant Kind.FIXED] duration of [param p_seconds].

### estimated

Builds a [constant Kind.ESTIMATED] duration of [param p_seconds].

### dynamic

Builds a [constant Kind.DYNAMIC] duration (no known length).

### infinite

Builds a [constant Kind.INFINITE] duration (never finishes on its own).

### worst_kind

Worst-kind-wins: the least certain kind among a composite's children.

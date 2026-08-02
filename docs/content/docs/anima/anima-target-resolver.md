---
title: "AnimaTargetResolver"
description: "Resolves an [AnimaTargetCollection] into the nodes a group can animate."
---

# AnimaTargetResolver

## Overview

Resolves an [AnimaTargetCollection] into the nodes a group can animate.

This helper keeps collection choices predictable: it preserves each source's
visible order, removes duplicates, then applies an optional odd or even
filter. Ordering and animation timing are deliberately separate work.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Methods

### resolve

Resolves [param collection] from [param root] and optional runtime targets.

[param root] is the node whose children, descendants, and relative paths are
inspected. [param runtime_targets] is used only for `RUNTIME_CALLABLE`.
Invalid and empty policies come from the owning [AnimaGroupMotion].

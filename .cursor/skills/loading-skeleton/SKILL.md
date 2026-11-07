---
name: loading-skeleton
description: Pulse skeleton and AsyncValueBody loading on Bnood screens.
---

# Loading skeleton (Bnood)

Read `.cursor/rules/bnood-loading-skeleton.mdc`.

## Checklist

- Loaded layout traced; one scroll parent
- Placeholder in feature `widgets/*_loading_skeleton.dart` or similar
- Real chrome outside `Skeleton(child: …)`
- `AsyncValueBody` or explicit `Skeleton` only on first load (no data)
- Widget test: loading branch, `takeException()` null inside parent `ListView`
- Reduced motion: static bones, semantics `statusLoading`

Motion: `AppMotion.skeletonPulse` (1600ms).

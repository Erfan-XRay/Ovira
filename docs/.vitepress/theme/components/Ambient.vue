<template>
  <div class="ambient" aria-hidden="true">
    <i class="blob a" />
    <i class="blob b" />
    <i class="blob c" />
    <div class="dots" />
    <div class="dots lit" />
  </div>
</template>

<style scoped>
.ambient {
  position: fixed;
  inset: 0;
  z-index: -1;
  overflow: hidden;
  pointer-events: none;
}

.blob {
  position: absolute;
  width: 70vmax;
  height: 70vmax;
  border-radius: 50%;
  will-change: transform;
}

.a {
  top: -34vmax;
  inset-inline-start: -20vmax;
  background: radial-gradient(circle, var(--o-blob-a), transparent 66%);
  animation: drift-a 42s ease-in-out infinite alternate;
}

.b {
  bottom: -38vmax;
  inset-inline-end: -24vmax;
  background: radial-gradient(circle, var(--o-blob-b), transparent 66%);
  animation: drift-b 54s ease-in-out infinite alternate;
}

.c {
  top: 30%;
  inset-inline-start: 38%;
  width: 46vmax;
  height: 46vmax;
  background: radial-gradient(circle, var(--o-blob-c), transparent 66%);
  animation: drift-c 36s ease-in-out infinite alternate;
}

.dots {
  position: absolute;
  inset: 0;
  background-image: radial-gradient(var(--o-dot) 1px, transparent 1.3px);
  background-size: 26px 26px;
  mask-image: linear-gradient(to bottom, #000, transparent 85%);
}

/* the same grid, lit, only near the pointer */
.lit {
  background-image: radial-gradient(var(--o-dot-lit) 1.4px, transparent 1.8px);
  mask-image: radial-gradient(circle 190px at var(--cx, -400px) var(--cy, -400px), #000, transparent);
  opacity: 0;
  transition: opacity 0.5s;
}

:global(:root[data-pointer]) .lit {
  opacity: 1;
}

@keyframes drift-a {
  to {
    transform: translate3d(14vmax, 10vmax, 0) scale(1.15);
  }
}

@keyframes drift-b {
  to {
    transform: translate3d(-16vmax, -8vmax, 0) scale(1.1);
  }
}

@keyframes drift-c {
  to {
    transform: translate3d(-10vmax, 12vmax, 0) scale(0.85);
  }
}

@media (prefers-reduced-motion: reduce) {
  .blob {
    animation: none;
  }
}
</style>

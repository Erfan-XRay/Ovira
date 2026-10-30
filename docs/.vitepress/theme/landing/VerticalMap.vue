<script setup lang="ts">
import { computed, ref } from "vue";
import { useCopy, useLive } from "./use";

const { t } = useCopy();
const root = ref<HTMLElement>();
const { live, reduced } = useLive(root);

// The same deployment as the wide map, read top to bottom. Each stop lists the
// strips (0 OpenVPN, 1 WireGuard, 2 OpenConnect) it sits on; a strip runs from
// the first row down to the last stop on that line.
const rows = [
  { id: "panel", kind: "panel", on: [0, 1, 2] },
  { id: "here", kind: "cap", on: [0, 1, 2] },
  { id: "frankfurt-1", kind: "dot", on: [0] },
  { id: "amsterdam-1", kind: "dot", on: [1] },
  { id: "paris-1", kind: "dot", on: [2] },
  { id: "relay-1", kind: "cap", on: [0, 1] },
  { id: "helsinki-2", kind: "cap", on: [0, 1] },
  { id: "milan-1", kind: "dot", on: [2] },
] as const;
const LAST = [6, 6, 7];
const names = ["ovpn", "wg", "oc"] as const;

const label = (id: string) => (id === "panel" ? t.value.map.panel : id === "here" ? t.value.map.here : id);
const serves = (on: readonly number[]) => on.map((i) => t.value.map.lines[names[i]]).join(" · ");
const strips = computed(() => (r: number) => [0, 1, 2].filter((s) => r <= LAST[s]));
</script>

<template>
  <div ref="root" class="vmap" :class="{ live: live && !reduced }">
    <ol class="rows" :aria-label="t.map.label">
      <li v-for="(r, ri) in rows" :key="r.id" class="row" :style="{ '--r': ri }">
        <span class="rail" aria-hidden="true">
          <i
            v-for="s in strips(ri)"
            :key="s"
            class="seg"
            :class="['c-' + names[s], { first: ri === 0, end: ri === LAST[s] }]"
            :style="{ '--s': s }"
          />
          <i
            class="mark"
            :class="r.kind"
            :style="{ '--a': r.on[0], '--b': r.on[r.on.length - 1] }"
          />
        </span>
        <span class="txt">
          <b :class="{ mono: r.kind !== 'panel' && r.id !== 'here' }">{{ label(r.id) }}</b>
          <small>{{ r.kind === "panel" ? t.map.symbols.panel : serves(r.on) }}</small>
        </span>
      </li>
    </ol>
    <i v-for="s in 3" :key="'t' + s" class="train" :class="'c-' + names[s - 1]" :style="{ '--s': s - 1 }" aria-hidden="true" />
    <p class="caption">{{ t.map.caption }}</p>
  </div>
</template>

<style scoped>
.vmap {
  position: relative;
  --pitch: 74px;
  --lane: 22px;
}

.rows {
  position: relative;
  margin: 0;
  padding: 0;
  list-style: none;
}

.row {
  display: flex;
  align-items: center;
  min-height: var(--pitch);
  gap: 14px;
}

.rail {
  position: relative;
  align-self: stretch;
  flex: none;
  width: calc(var(--lane) * 3 + 8px);
}

.seg {
  position: absolute;
  top: 0;
  bottom: 0;
  inset-inline-start: calc(var(--s) * var(--lane) + 8px);
  width: 8px;
  margin-inline-start: 3px;
  border-radius: 4px;
  background: currentColor;
  transform-origin: top;
  animation: grow 0.7s cubic-bezier(0.6, 0, 0.2, 1) calc(var(--r, 0) * 0.12s + 0.2s) backwards;
}
.seg.first { top: 50%; }
.seg.end { bottom: 50%; }

/* a stop: a ring, a capsule across strips, or a dot */
.mark {
  position: absolute;
  top: 50%;
  inset-inline-start: calc(var(--a) * var(--lane) + 8px);
  width: calc((var(--b) - var(--a)) * var(--lane) + 14px);
  height: 14px;
  box-sizing: content-box;
  margin: -10px 0 0;
  border: 3.5px solid var(--o-station-ink);
  border-radius: 12px;
  background: var(--o-station);
  animation: pop 0.5s var(--o-spring) calc(var(--r, 0) * 0.12s + 0.5s) backwards;
}
.mark.panel {
  height: calc((var(--lane) * 2) + 14px);
  margin-top: -24px;
  border-color: var(--vp-c-brand-3);
  border-width: 5px;
  border-radius: 14px;
  box-shadow: 0 0 14px var(--o-glow);
}
.mark.panel::after {
  content: "";
  position: absolute;
  inset: 0;
  margin: auto;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: var(--vp-c-brand-3);
}
.mark.dot { height: 14px; width: 14px; border-radius: 50%; }
.mark.cap { height: 14px; }

.txt {
  display: grid;
  gap: 1px;
  min-width: 0;
}
.txt b {
  font-size: 16px;
  font-weight: 650;
  line-height: 1.3;
}
.txt b.mono {
  font-family: var(--vp-font-family-mono);
  font-weight: 500;
  font-size: 15px;
}
.txt small {
  color: var(--vp-c-text-2);
  font-size: 13px;
  line-height: 1.4;
}

.caption {
  margin: 14px 0 0;
  font-size: 13px;
  color: var(--vp-c-text-2);
}

/* a train per line slides down its strip */
.train {
  position: absolute;
  top: calc(var(--pitch) / 2);
  inset-inline-start: calc(var(--s) * var(--lane) + 8px + 7px - 3px);
  width: 6px;
  height: 6px;
  margin-top: -3px;
  border-radius: 50%;
  background: var(--vp-c-text-1);
  box-shadow: 0 0 0 4px color-mix(in srgb, currentColor 30%, transparent);
  opacity: 0;
}
.live .train {
  opacity: 1;
  animation: run 6s linear infinite;
  animation-delay: calc(var(--s) * -2s);
}
@keyframes run {
  from { transform: translateY(0); }
  to { transform: translateY(calc(var(--pitch) * 6)); }
}
@keyframes grow {
  from { transform: scaleY(0); }
}
@keyframes pop {
  from { opacity: 0; transform: scale(0.5); }
}

@media (prefers-reduced-motion: reduce) {
  .seg, .mark { animation: none; }
}
</style>

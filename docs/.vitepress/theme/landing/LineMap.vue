<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from "vue";
import { mx, roundedPath, useCopy, useLive } from "./use";

const W = 800;
const H = 340;
const { fa, t } = useCopy();
const flip = computed(() => fa.value);
const root = ref<HTMLElement>();
const { live, reduced } = useLive(root);

type Pt = [number, number];
type Key = "ovpn" | "wg" | "oc";

// Lines run at 90 and 45 degrees only. Coordinates are for left-to-right;
// the Persian page mirrors x so the map reads from the right.
const RAW: Record<Key, Pt[]> = {
  ovpn: [[80, 150], [230, 150], [320, 60], [700, 60]],
  wg: [[80, 170], [440, 170], [530, 80], [700, 80]],
  oc: [[80, 190], [230, 190], [340, 300], [640, 300]],
};
const KEYS: Key[] = ["ovpn", "wg", "oc"];
const paths = computed(() =>
  KEYS.map((k) => ({
    key: k,
    d: roundedPath(RAW[k].map(([x, y]) => [mx(x, W, flip.value), y] as Pt), 26),
  })),
);

const X = (x: number) => mx(x, W, flip.value);
const stations = computed(() => [
  { id: "frankfurt-1", x: 430, y: 60, ly: 36, line: "ovpn" },
  { id: "amsterdam-1", x: 330, y: 170, ly: 198, line: "wg" },
  { id: "paris-1", x: 450, y: 300, ly: 326, line: "oc" },
  { id: "milan-1", x: 640, y: 300, ly: 326, line: "oc" },
]);

const tags = computed(() => [
  { text: t.value.map.lines.ovpn, x: 718, y: 64, cls: "c-ovpn" },
  { text: t.value.map.lines.wg, x: 718, y: 84, cls: "c-wg" },
  { text: t.value.map.lines.oc, x: 660, y: 304, cls: "c-oc" },
]);

// customers' traffic: client name, line, direction, speed (share of the line per second), start
const TRAINS = [
  { name: "mina", key: "ovpn", dir: 1, v: 0.085, s: 0.05 },
  { name: "kian", key: "ovpn", dir: -1, v: 0.07, s: 0.55 },
  { name: "sara", key: "ovpn", dir: 1, v: 0.06, s: 0.78 },
  { name: "omid", key: "wg", dir: 1, v: 0.075, s: 0.3 },
  { name: "nika", key: "wg", dir: -1, v: 0.09, s: 0.7 },
  { name: "arman", key: "wg", dir: 1, v: 0.06, s: 0.95 },
  { name: "dara", key: "oc", dir: -1, v: 0.07, s: 0.4 },
  { name: "leila", key: "oc", dir: 1, v: 0.08, s: 0.85 },
] as const;

const pathEls = ref<SVGPathElement[]>([]);
const trainEls = ref<SVGGElement[]>([]);
const state = TRAINS.map((x) => ({ s: x.s, x: 0, y: 0 }));
const lens: number[] = [];
const paused = ref(false);
const hover = ref(-1);
const focused = ref(-1);
const shown = computed(() => (focused.value >= 0 ? focused.value : hover.value));
const tip = ref({ x: 0, y: 0, w: 0, text: "" });
const started = ref(false);

function place(i: number) {
  const tr = TRAINS[i];
  const idx = KEYS.indexOf(tr.key);
  const p = pathEls.value[idx];
  if (!p) return;
  if (!lens[idx]) lens[idx] = p.getTotalLength();
  const st = state[i];
  const pt = p.getPointAtLength(st.s * lens[idx]);
  st.x = pt.x;
  st.y = pt.y;
  const edge = Math.min(1, st.s / 0.05, (1 - st.s) / 0.05);
  const el = trainEls.value[i];
  if (el) {
    el.setAttribute("transform", `translate(${pt.x.toFixed(1)} ${pt.y.toFixed(1)})`);
    el.style.opacity = String(Math.max(0, edge));
  }
}

function updateTip() {
  const i = shown.value;
  if (i < 0) return;
  const st = state[i];
  const text = `${TRAINS[i].name} · ${t.value.map.lines[TRAINS[i].key]}`;
  const w = text.length * 7.4 + 22;
  tip.value = { x: Math.min(W - w / 2 - 4, Math.max(w / 2 + 4, st.x)), y: st.y < 50 ? st.y + 30 : st.y - 24, w, text };
}

let raf = 0;
let last = 0;
function frame(ts: number) {
  const dt = Math.min(0.05, (ts - last) / 1000 || 0);
  last = ts;
  for (let i = 0; i < TRAINS.length; i++) {
    const tr = TRAINS[i];
    let s = state[i].s + tr.dir * tr.v * dt;
    if (s > 1) s -= 1;
    if (s < 0) s += 1;
    state[i].s = s;
    place(i);
  }
  updateTip();
  raf = requestAnimationFrame(frame);
}
function stop() {
  if (raf) cancelAnimationFrame(raf);
  raf = 0;
}
function start() {
  if (raf) return;
  last = performance.now();
  raf = requestAnimationFrame(frame);
}

const running = computed(() => started.value && live.value && !paused.value);
watch(running, (r) => (r ? start() : stop()));
watch([shown, paused], () => {
  if (!raf) updateTip();
});

let t0: ReturnType<typeof setTimeout> | undefined;
onMounted(async () => {
  await nextTick();
  for (let i = 0; i < TRAINS.length; i++) place(i);
  // trains leave once the map has drawn itself
  t0 = setTimeout(() => (started.value = true), reduced.value ? 0 : 2200);
});
onUnmounted(() => {
  stop();
  if (t0) clearTimeout(t0);
});

const lineName = (k: Key) => t.value.map.lines[k];
const panelC = computed(() => ({ x: X(80), y: 170 }));
const hereX = computed(() => X(170));
const relayX = computed(() => X(582));
const heldX = computed(() => X(700));
</script>

<template>
  <div ref="root" class="linemap">
    <svg
      class="svg"
      :viewBox="`${fa ? -12 : 40} 0 772 ${H}`"
      role="img"
      :aria-label="t.map.label"
      preserveAspectRatio="xMidYMid meet"
      :class="{ rtl: fa }"
    >
      <!-- quiet grid, like the base of a printed map -->
      <g class="grid" aria-hidden="true">
        <path v-for="i in 7" :key="'v' + i" :d="`M${i * 100} 0V${H}`" />
        <path v-for="i in 3" :key="'h' + i" :d="`M0 ${i * 85}H${W}`" />
      </g>

      <g class="lines">
        <path
          v-for="(p, i) in paths"
          :key="p.key"
          ref="pathEls"
          :d="p.d"
          pathLength="1"
          class="line"
          :class="'c-' + p.key"
          :style="{ '--i': i }"
        />
      </g>

      <g class="stations">
        <!-- panel: a ring with the signal inside -->
        <g class="st" style="--k: 0">
          <circle :cx="panelC.x" :cy="panelC.y" r="30" class="ring" />
          <circle :cx="panelC.x" :cy="panelC.y" r="9" class="core" />
          <text :x="panelC.x" y="222" class="name">{{ t.map.panel }}</text>
        </g>

        <!-- this server: all three lines stop here -->
        <g class="st" style="--k: 1">
          <rect :x="hereX - 9" y="136" width="18" height="68" rx="9" class="cap" />
          <text :x="hereX" y="228" class="name">{{ t.map.here }}</text>
        </g>

        <g v-for="(s, i) in stations" :key="s.id" class="st" :style="{ '--k': 2 + i }">
          <circle :cx="X(s.x)" :cy="s.y" r="9" class="dot" />
          <text :x="X(s.x)" :y="s.ly" class="name mono">{{ s.id }}</text>
        </g>

        <!-- relay: an interchange where OpenVPN and WireGuard meet -->
        <g class="st" style="--k: 6">
          <rect :x="relayX - 9" y="46" width="18" height="48" rx="9" class="cap" />
          <text :x="relayX" y="32" class="name mono">relay-1</text>
        </g>
        <g class="st" style="--k: 7">
          <rect :x="heldX - 9" y="46" width="18" height="48" rx="9" class="cap" />
          <text :x="heldX" y="32" class="name mono">helsinki-2</text>
        </g>
      </g>

      <g class="tags" aria-hidden="true">
        <text
          v-for="g in tags"
          :key="g.text"
          :x="X(g.x)"
          :y="g.y"
          class="tag"
          :class="g.cls"
          :text-anchor="fa ? 'end' : 'start'"
        >{{ g.text }}</text>
      </g>

      <g v-if="!reduced" class="trains" :class="{ on: started }">
        <g
          v-for="(tr, i) in TRAINS"
          :key="tr.name"
          :ref="(el) => { if (el) trainEls[i] = el as SVGGElement }"
          class="train"
          :class="'c-' + tr.key"
          :tabindex="paused ? 0 : -1"
          role="img"
          :aria-label="`${t.map.trainWord} ${tr.name}, ${lineName(tr.key)}`"
          @pointerenter="hover = i"
          @pointerleave="hover = -1"
          @focus="focused = i"
          @blur="focused = -1"
        >
          <circle r="15" class="hit" />
          <circle r="10" class="halo" />
          <circle r="5.5" class="body" />
        </g>
        <g v-if="shown >= 0" class="tip" :transform="`translate(${tip.x} ${tip.y})`" aria-hidden="true">
          <rect :x="-tip.w / 2" y="-13" :width="tip.w" height="26" rx="8" />
          <text y="4.5">{{ tip.text }}</text>
        </g>
      </g>
    </svg>

    <p class="ov-sr">
      <span v-for="o in t.map.outline" :key="o">{{ o }} </span>
    </p>

    <div class="foot">
      <div class="legend" role="group" :aria-label="t.map.legend">
        <ul>
          <li><i class="bar c-ovpn" />{{ t.map.lines.ovpn }}</li>
          <li><i class="bar c-wg" />{{ t.map.lines.wg }}</li>
          <li><i class="bar c-oc" />{{ t.map.lines.oc }}</li>
        </ul>
        <ul>
          <li><i class="sym ring" />{{ t.map.symbols.panel }}</li>
          <li><i class="sym dot" />{{ t.map.symbols.node }}</li>
          <li><i class="sym cap" />{{ t.map.symbols.inter }}</li>
          <li v-if="!reduced"><i class="sym train" />{{ t.map.symbols.train }}</li>
        </ul>
      </div>
      <div class="side">
        <p class="caption">{{ t.map.caption }}</p>
        <button v-if="!reduced" type="button" class="pause" :aria-pressed="paused" @click="paused = !paused">
          <svg viewBox="0 0 24 24" aria-hidden="true">
            <path v-if="!paused" d="M8 5v14M16 5v14" />
            <path v-else d="M7 5l12 7-12 7z" />
          </svg>
          {{ paused ? t.map.play : t.map.pause }}
        </button>
        <span class="ov-sr" role="status">{{ paused ? t.map.trainsOff : "" }}</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.linemap {
  width: 100%;
}

.svg {
  display: block;
  width: 100%;
  height: auto;
  overflow: hidden;
}

.grid path {
  fill: none;
  stroke: var(--o-line);
  stroke-width: 1;
  stroke-dasharray: 2 7;
}

/* lines draw themselves: network forming */
.line {
  fill: none;
  stroke: currentColor;
  stroke-width: 9;
  stroke-linecap: round;
  stroke-linejoin: round;
  stroke-dasharray: 1;
  stroke-dashoffset: 1;
  animation: draw 1.5s cubic-bezier(0.6, 0, 0.2, 1) calc(0.25s + var(--i) * 0.2s) forwards;
}

.st {
  opacity: 0;
  transform-box: fill-box;
  transform-origin: center;
  animation: pop 0.6s var(--o-spring) calc(1.1s + var(--k) * 0.12s) forwards;
}

.ring {
  fill: var(--o-station);
  stroke: var(--vp-c-brand-3);
  stroke-width: 6;
}

.core {
  fill: var(--vp-c-brand-3);
}

.cap {
  fill: var(--o-station);
  stroke: var(--o-station-ink);
  stroke-width: 4;
}

.dot {
  fill: var(--o-station);
  stroke: var(--o-station-ink);
  stroke-width: 4;
}

.name {
  fill: var(--vp-c-text-1);
  font-family: var(--vp-font-family-base);
  font-size: 17px;
  font-weight: 650;
  text-anchor: middle;
}

.name.mono {
  font-family: var(--vp-font-family-mono);
  font-size: 15px;
  font-weight: 500;
}

.tag {
  direction: ltr;
  fill: currentColor;
  font-family: var(--vp-font-family-mono);
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 0.04em;
  opacity: 0;
  animation: fade 0.6s ease 1.9s forwards;
}

.rtl .tag {
  letter-spacing: 0;
}

.trains {
  opacity: 0;
  transition: opacity 0.6s;
}
.trains.on {
  opacity: 1;
}

.train {
  outline: none;
}
.train .hit {
  fill: transparent;
}
.train .halo {
  fill: currentColor;
  opacity: 0.22;
}
.train .body {
  fill: currentColor;
  stroke: var(--o-station);
  stroke-width: 2;
}
.train:focus-visible .halo {
  opacity: 0.55;
  stroke: var(--vp-c-text-1);
  stroke-width: 2;
}

.tip {
  pointer-events: none;
}
.tip rect {
  fill: var(--vp-c-bg-elv);
  stroke: var(--o-line-strong);
}
.tip text {
  fill: var(--vp-c-text-1);
  font-family: var(--vp-font-family-mono);
  font-size: 13px;
  text-anchor: middle;
}

.foot {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  justify-content: space-between;
  gap: 16px;
  margin-top: 6px;
}

.legend {
  display: flex;
  gap: 28px;
  padding: 12px 16px;
  border: 1px solid var(--o-line-strong);
  border-radius: 12px;
  background: var(--o-map-bg);
  font-size: 13.5px;
}

.legend ul {
  display: grid;
  gap: 6px;
  margin: 0;
  padding: 0;
  list-style: none;
}

.legend li {
  display: flex;
  align-items: center;
  gap: 10px;
  color: var(--vp-c-text-1);
  line-height: 1.3;
}

.bar {
  width: 26px;
  height: 7px;
  border-radius: 4px;
  background: currentColor;
}

.sym {
  position: relative;
  width: 26px;
  height: 14px;
  flex: none;
}
.sym::before {
  content: "";
  position: absolute;
  inset: 0;
  margin: auto;
}
.sym.ring::before {
  width: 14px;
  height: 14px;
  border: 3.5px solid var(--vp-c-brand-3);
  border-radius: 50%;
}
.sym.dot::before {
  width: 13px;
  height: 13px;
  border: 3px solid var(--o-station-ink);
  border-radius: 50%;
}
.sym.cap::before {
  width: 12px;
  height: 20px;
  border: 3px solid var(--o-station-ink);
  border-radius: 7px;
}
.sym.train::before {
  width: 9px;
  height: 9px;
  border-radius: 50%;
  background: var(--vp-c-text-1);
}

.side {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 8px;
}

.caption {
  margin: 0;
  font-size: 13px;
  color: var(--vp-c-text-2);
}

.pause {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  min-height: 44px;
  padding: 0 14px;
  border: 1px solid var(--o-line-strong);
  border-radius: 10px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
}
.pause:hover {
  border-color: var(--vp-c-brand-3);
}
.pause svg {
  width: 16px;
  height: 16px;
  fill: currentColor;
  stroke: currentColor;
  stroke-width: 2.4;
  stroke-linecap: round;
  stroke-linejoin: round;
}

@keyframes draw {
  to {
    stroke-dashoffset: 0;
  }
}
@keyframes pop {
  from {
    opacity: 0;
    transform: scale(0.6);
  }
  to {
    opacity: 1;
    transform: none;
  }
}
@keyframes fade {
  to {
    opacity: 1;
  }
}

@media (max-width: 1099px) and (min-width: 640px) {
  .legend {
    flex-wrap: wrap;
  }
}

@media (prefers-reduced-motion: reduce) {
  .line {
    animation: none;
    stroke-dashoffset: 0;
  }
  .st,
  .tag {
    animation: none;
    opacity: 1;
  }
}
</style>

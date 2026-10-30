<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from "vue";
import { fd } from "./copy";
import { useCopy } from "./use";

const { fa, t } = useCopy();
const l = computed(() => t.value.life);
const n = computed(() => l.value.stops.length);
const idx = ref(2);
const frac = ref(idx.value / 5);
const dragging = ref(false);
const track = ref<HTMLElement>();
const width = ref(0);
let ro: ResizeObserver | undefined;

onMounted(() => {
  ro = new ResizeObserver(() => (width.value = track.value?.clientWidth ?? 0));
  if (track.value) ro.observe(track.value);
  width.value = track.value?.clientWidth ?? 0;
});
onUnmounted(() => ro?.disconnect());

const stop = computed(() => l.value.stops[idx.value]);
const num = (v: number | string) => (fa.value ? fd(v) : String(v));
const fmt = (v: number) => {
  const s = Number.isInteger(v) ? String(v) : v.toFixed(1);
  return fa.value ? fd(s).replace(".", "٫") : s;
};

function setIdx(i: number) {
  idx.value = Math.max(0, Math.min(n.value - 1, i));
  if (!dragging.value) frac.value = idx.value / (n.value - 1);
}

function fromPointer(e: PointerEvent) {
  const r = track.value!.getBoundingClientRect();
  let f = (e.clientX - r.left) / r.width;
  if (fa.value) f = 1 - f;
  f = Math.max(0, Math.min(1, f));
  frac.value = f;
  idx.value = Math.round(f * (n.value - 1));
}
function down(e: PointerEvent) {
  dragging.value = true;
  (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId);
  fromPointer(e);
}
function move(e: PointerEvent) {
  if (dragging.value) fromPointer(e);
}
function up() {
  if (!dragging.value) return;
  dragging.value = false;
  frac.value = idx.value / (n.value - 1);
}
function key(e: KeyboardEvent) {
  const dir = fa.value ? -1 : 1;
  const map: Record<string, number> = {
    ArrowRight: dir,
    ArrowUp: 1,
    ArrowLeft: -dir,
    ArrowDown: -1,
    PageUp: 1,
    PageDown: -1,
  };
  if (e.key in map) setIdx(idx.value + map[e.key]);
  else if (e.key === "Home") setIdx(0);
  else if (e.key === "End") setIdx(n.value - 1);
  else return;
  e.preventDefault();
}

const px = computed(() => (fa.value ? -1 : 1) * frac.value * width.value);
const gb = (v: number) => `${fmt(v)} ${l.value.gb}`;
</script>

<template>
  <section :id="l.id" class="ov-section life">
    <div class="ov-wrap">
      <header class="ov-head" data-reveal>
        <p class="ov-eyebrow">{{ l.n }}</p>
        <h2 class="ov-h2">{{ l.title }}</h2>
        <p class="ov-lede">{{ l.lede }}</p>
      </header>

      <div class="ov-card box" data-reveal>
        <div class="rail">
          <div
            ref="track"
            class="track"
            role="slider"
            tabindex="0"
            :aria-label="l.sliderLabel"
            aria-valuemin="1"
            :aria-valuemax="n"
            :aria-valuenow="idx + 1"
            :aria-valuetext="`${num(idx + 1)} / ${num(n)}: ${stop.title}`"
            @pointerdown="down"
            @pointermove="move"
            @pointerup="up"
            @pointercancel="up"
            @keydown="key"
          >
            <span class="base" />
            <span class="fill" :style="{ transform: `scaleX(${frac})` }" />
            <span
              v-for="(s, i) in l.stops"
              :key="i"
              class="pt"
              :class="{ done: i <= idx, cur: i === idx }"
              :style="{ insetInlineStart: `${(i / (n - 1)) * 100}%` }"
              @pointerdown.stop="setIdx(i)"
            >
              <b>{{ num(i + 1) }}</b>
              <em>{{ s.title }}</em>
            </span>
            <span class="thumb" :class="{ drag: dragging }" :style="{ transform: `translateX(${px}px)` }" aria-hidden="true" />
          </div>
        </div>

        <div class="detail">
          <div class="story" aria-live="polite">
            <p class="step">{{ num(idx + 1) }} / {{ num(n) }}</p>
            <h3>{{ stop.title }}</h3>
            <p class="sentence">{{ stop.text }}</p>
            <div class="nav">
              <button type="button" class="nb" :disabled="idx === 0" :aria-label="fa ? 'مرحلهٔ قبل' : 'Previous stop'" @click="setIdx(idx - 1)">
                <svg viewBox="0 0 24 24" aria-hidden="true" :class="{ flip: fa }"><path d="m15 5-7 7 7 7" /></svg>
              </button>
              <button type="button" class="nb" :disabled="idx === n - 1" :aria-label="fa ? 'مرحلهٔ بعد' : 'Next stop'" @click="setIdx(idx + 1)">
                <svg viewBox="0 0 24 24" aria-hidden="true" :class="{ flip: fa }"><path d="m9 5 7 7-7 7" /></svg>
              </button>
            </div>
          </div>

          <div class="state">
            <p class="sh">{{ l.panelState }}</p>
            <p class="chip" :class="stop.tone">{{ stop.status }}</p>
            <div class="m">
              <div class="mh"><span>{{ l.traffic }}</span><b>{{ gb(stop.used) }} {{ l.of }} {{ gb(stop.limit) }}</b></div>
              <div class="meter"><i :class="stop.tone" :style="{ transform: `scaleX(${stop.used / stop.limit})` }" /></div>
            </div>
            <div class="m">
              <div class="mh"><span>{{ l.daysLeft }}</span><b>{{ stop.daysText }}</b></div>
              <div class="meter"><i class="time" :style="{ transform: `scaleX(${stop.daysFrac})` }" /></div>
            </div>
            <div class="m">
              <div class="mh"><span>{{ l.devices }}</span><b>{{ num(stop.devices) }} {{ l.of }} {{ num(stop.devicesMax) }}</b></div>
              <div class="pips" aria-hidden="true">
                <i v-for="p in stop.devicesMax" :key="p" :class="{ on: p <= stop.devices }" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.box {
  padding: 28px clamp(18px, 3vw, 36px) 32px;
}

.rail {
  padding: 8px 18px 56px;
}

.track {
  position: relative;
  height: 44px;
  margin: 0;
  cursor: grab;
  touch-action: pan-y;
  border-radius: 12px;
}
.track:focus-visible {
  outline: 2px solid var(--vp-c-brand-3);
  outline-offset: 10px;
}

.base,
.fill {
  position: absolute;
  top: 18px;
  inset-inline: 0;
  height: 8px;
  border-radius: 4px;
}
.base {
  background: var(--o-line-strong);
}
.fill {
  background: var(--vp-c-brand-3);
  box-shadow: 0 0 14px var(--o-glow);
  transform-origin: left center;
  transition: transform 0.45s var(--o-out);
}
[dir="rtl"] .fill {
  transform-origin: right center;
}

.pt {
  position: absolute;
  top: 12px;
  width: 20px;
  height: 20px;
  margin-inline-start: -10px;
  border: 4px solid var(--o-station-ink);
  border-radius: 50%;
  background: var(--o-station);
  cursor: pointer;
}
.pt.done {
  border-color: var(--vp-c-brand-3);
}
.pt b {
  position: absolute;
  top: -26px;
  inset-inline-start: 50%;
  translate: -50% 0;
  font-family: var(--vp-font-family-mono);
  font-size: 12px;
  font-weight: 500;
  color: var(--vp-c-text-2);
}
[dir="rtl"] .pt b { translate: 50% 0; font-family: var(--vp-font-family-base); }
.pt em {
  position: absolute;
  top: 30px;
  inset-inline-start: 50%;
  translate: -50% 0;
  width: 110px;
  font-style: normal;
  font-size: 13.5px;
  font-weight: 600;
  line-height: 1.3;
  text-align: center;
  color: var(--vp-c-text-2);
  transition: color 0.3s;
}
[dir="rtl"] .pt em { translate: 50% 0; }
.pt.cur em { color: var(--vp-c-text-1); }

.thumb {
  position: absolute;
  top: 9px;
  inset-inline-start: -13px;
  width: 26px;
  height: 26px;
  border-radius: 50%;
  background: var(--vp-c-brand-3);
  border: 4px solid var(--o-station);
  box-shadow: 0 0 0 2px var(--vp-c-brand-3), 0 6px 18px var(--o-glow);
  transition: transform 0.45s var(--o-spring);
  pointer-events: none;
}
.thumb.drag {
  transition: none;
}

.detail {
  display: grid;
  gap: 28px;
  padding-top: 8px;
}
@media (min-width: 800px) {
  .detail {
    grid-template-columns: minmax(0, 1fr) minmax(0, 360px);
    gap: 48px;
  }
}

.step {
  margin: 0 0 6px;
  font-family: var(--vp-font-family-mono);
  font-size: 12.5px;
  letter-spacing: 0.1em;
  color: var(--vp-c-text-2);
}
[dir="rtl"] .step { font-family: var(--vp-font-family-base); letter-spacing: 0; font-size: 14px; }
h3 {
  margin: 0;
  font-family: var(--o-display);
  font-size: 30px;
  font-weight: 650;
  line-height: 1.15;
  letter-spacing: -0.03em;
}
[dir="rtl"] h3 { letter-spacing: 0; line-height: 1.5; }
.sentence {
  min-height: 5.4em;
  margin: 12px 0 0;
  font-size: 17px;
  line-height: 1.7;
  color: var(--vp-c-text-1);
}
[dir="rtl"] .sentence { line-height: 2; }

.nav { display: flex; gap: 8px; margin-top: 14px; }
.nb {
  display: grid;
  place-items: center;
  width: 44px;
  height: 44px;
  border: 1px solid var(--o-line-strong);
  border-radius: 12px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  cursor: pointer;
}
.nb:hover:not(:disabled) { border-color: var(--vp-c-brand-3); }
.nb:disabled { opacity: 0.4; cursor: default; }
.nb svg { width: 20px; height: 20px; fill: none; stroke: currentColor; stroke-width: 2.2; stroke-linecap: round; stroke-linejoin: round; }
.nb svg.flip { transform: scaleX(-1); }

.state {
  padding: 18px 20px;
  border: 1px solid var(--o-line);
  border-radius: 16px;
  background: var(--vp-c-bg-soft);
}
.sh {
  margin: 0 0 10px;
  font-family: var(--vp-font-family-mono);
  font-size: 11.5px;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--vp-c-text-2);
}
[dir="rtl"] .sh { font-family: var(--vp-font-family-base); letter-spacing: 0; font-size: 13px; }
.chip {
  display: inline-block;
  margin: 0 0 14px;
  padding: 3px 12px;
  border: 1px solid currentColor;
  border-radius: 999px;
  font-size: 13.5px;
  font-weight: 650;
}
.chip.idle { color: var(--vp-c-text-2); }
.chip.ok { color: var(--o-good); }
.chip.warn { color: var(--o-warn); }
.chip.bad { color: var(--o-bad); }

.m { margin-top: 12px; }
.mh { display: flex; justify-content: space-between; gap: 10px; font-size: 14px; }
.mh span { color: var(--vp-c-text-2); }
.mh b { font-weight: 650; text-align: end; }
.meter { height: 7px; margin-top: 6px; overflow: hidden; border-radius: 4px; background: var(--o-line-strong); }
.meter i {
  display: block;
  height: 100%;
  border-radius: 4px;
  background: var(--o-good);
  transform-origin: left center;
  transition: transform 0.6s var(--o-out), background 0.3s;
}
[dir="rtl"] .meter i { transform-origin: right center; }
.meter i.bad { background: var(--o-bad); }
.meter i.idle { background: var(--vp-c-text-3); }
.meter i.time { background: var(--o-wg); }
.pips { display: flex; gap: 6px; margin-top: 8px; }
.pips i { width: 22px; height: 8px; border-radius: 4px; background: var(--o-line-strong); transition: background 0.3s; }
.pips i.on { background: var(--o-good); }

/* narrow screens: numbers only on the rail, the title is in the detail */
@media (max-width: 719px) {
  .pt em { display: none; }
  .rail { padding-bottom: 12px; }
  h3 { font-size: 26px; }
}

@media (prefers-reduced-motion: reduce) {
  .fill, .thumb, .meter i { transition: none; }
}
</style>

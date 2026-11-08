<script setup lang="ts">
import { computed, ref } from "vue";
import { withBase } from "vitepress";
import { LINKS, fd } from "./copy";
import { mx, roundedPath, tabKeys, useCopy, useLive } from "./use";

const { fa, t, prefix } = useCopy();
const r = computed(() => t.value.routing);
const root = ref<HTMLElement>();
const { live, reduced } = useLive(root);
const cur = ref(0);
const pick = (i: number) => (cur.value = i);

type Exit = "warp" | "nord" | "direct" | "block";
type Lane = "premium" | "standard";
type Kind = "ai" | "ir" | "ads" | "other";
type Pt = [number, number];

// Example traffic: a destination, the inbound it came in on, and what kind of site it is.
const PACKETS: { host: string; lane: Lane; kind: Kind }[] = [
  { host: "gemini.google.com", lane: "standard", kind: "ai" },
  { host: "youtube.com", lane: "premium", kind: "other" },
  { host: "digikala.com", lane: "standard", kind: "ir" },
  { host: "chatgpt.com", lane: "premium", kind: "ai" },
  { host: "ads.example", lane: "standard", kind: "ads" },
  { host: "snapp.ir", lane: "premium", kind: "ir" },
  { host: "github.com", lane: "standard", kind: "other" },
];

// Each preset: its rules, as shown in the panel, and where each packet ends up.
const PRESETS: { rules: { match: string[]; exit: Exit }[]; dflt: Exit; route: (p: (typeof PACKETS)[number]) => Exit }[] = [
  {
    rules: [
      { match: ["geosite:openai", "geosite:google-gemini"], exit: "warp" },
      { match: ["geosite:category-ads-all"], exit: "block" },
    ],
    dflt: "direct",
    route: (p) => (p.kind === "ai" ? "warp" : p.kind === "ads" ? "block" : "direct"),
  },
  {
    rules: [{ match: ["geoip:ir", "geosite:category-ir"], exit: "direct" }],
    dflt: "warp",
    route: (p) => (p.kind === "ir" ? "direct" : "warp"),
  },
  {
    rules: [{ match: ["inbound: premium"], exit: "nord" }],
    dflt: "direct",
    route: (p) => (p.lane === "premium" ? "nord" : "direct"),
  },
];

const EXITS: Exit[] = ["warp", "nord", "direct", "block"];

// Two layouts: a wide one, and a tall one for phones.
const WIDE = {
  w: 960,
  h: 400,
  clients: [70, 200] as Pt,
  engine: [480, 200] as Pt,
  node: { x: 180, y: 128, w: 140, h: 144 },
  lanes: {
    premium: [[70, 200], [120, 200], [160, 160], [320, 160], [360, 200], [480, 200]] as Pt[],
    standard: [[70, 200], [120, 200], [160, 240], [320, 240], [360, 200], [480, 200]] as Pt[],
  },
  laneLabel: { premium: [240, 150] as Pt, standard: [240, 262] as Pt },
  exits: { warp: [890, 60] as Pt, nord: [890, 130] as Pt, direct: [890, 200] as Pt, block: [800, 330] as Pt },
  branch(e: Pt): Pt[] {
    const [ex, ey] = e;
    const dy = Math.abs(ey - 200);
    if (!dy) return [[480, 200], [ex, 200]];
    return [[480, 200], [600, 200], [600 + dy, ey], [ex, ey]];
  },
};
const TALL = {
  w: 360,
  h: 610,
  clients: [180, 36] as Pt,
  engine: [180, 310] as Pt,
  node: { x: 92, y: 104, w: 176, h: 128 },
  lanes: {
    premium: [[180, 36], [180, 80], [135, 125], [135, 210], [180, 255], [180, 310]] as Pt[],
    standard: [[180, 36], [180, 80], [225, 125], [225, 210], [180, 255], [180, 310]] as Pt[],
  },
  laneLabel: { premium: [135, 168] as Pt, standard: [225, 168] as Pt },
  exits: { warp: [45, 548] as Pt, nord: [135, 548] as Pt, direct: [225, 548] as Pt, block: [315, 548] as Pt },
  branch(e: Pt): Pt[] {
    const [ex, ey] = e;
    const dx = Math.abs(ex - 180);
    return [[180, 310], [180, 370], [ex, 370 + dx], [ex, ey]];
  },
};

function build(L: typeof WIDE | typeof TALL, flip: boolean) {
  const X = (p: Pt): Pt => [mx(p[0], L.w, flip), p[1]];
  const path = (pts: Pt[], rad = 22) => roundedPath(pts.map(X), rad);
  const exits = Object.fromEntries(EXITS.map((e) => [e, X(L.exits[e])])) as Record<Exit, Pt>;
  const branches = Object.fromEntries(EXITS.map((e) => [e, path(L.branch(L.exits[e]))])) as Record<Exit, string>;
  const lanes = { premium: path(L.lanes.premium), standard: path(L.lanes.standard) };
  const full = (lane: Lane, e: Exit) => path([...L.lanes[lane], ...L.branch(L.exits[e]).slice(1)]);
  const node = { ...L.node, x: flip ? L.w - L.node.x - L.node.w : L.node.x };
  return { w: L.w, h: L.h, clients: X(L.clients), engine: X(L.engine), node, exits, branches, lanes, full, laneLabel: { premium: X(L.laneLabel.premium), standard: X(L.laneLabel.standard) } };
}

const wide = computed(() => build(WIDE, fa.value));
const tall = computed(() => build(TALL, fa.value));
const preset = computed(() => PRESETS[cur.value]);
const used = computed(() => new Set(PACKETS.map((p) => preset.value.route(p))));
const packets = computed(() => PACKETS.map((p, i) => ({ ...p, i, exit: preset.value.route(p) })));
const ms = computed(() => (fa.value ? fd(42) : "42"));
</script>

<template>
  <section :id="r.id" ref="root" class="ov-section routing" :class="{ live: live && !reduced }">
    <div class="ov-wrap">
      <header class="ov-head" data-reveal>
        <p class="ov-eyebrow">{{ r.n }}</p>
        <h2 class="ov-h2">{{ r.title }}</h2>
        <p class="ov-lede">{{ r.lede }}</p>
      </header>

      <div class="tabs" role="tablist" :aria-label="r.presetsLabel" data-reveal>
        <button
          v-for="(p, i) in r.presets"
          :id="'rt-tab-' + p.key"
          :key="p.key"
          type="button"
          role="tab"
          :aria-selected="cur === i"
          aria-controls="rt-panel"
          :tabindex="cur === i ? 0 : -1"
          :class="['tab', { on: cur === i }]"
          @click="pick(i)"
          @keydown="tabKeys($event, r.presets.length, cur, pick, fa)"
        >
          {{ p.name }}
        </button>
      </div>

      <div id="rt-panel" class="stage" role="tabpanel" :aria-labelledby="'rt-tab-' + r.presets[cur].key" data-reveal>
        <div class="board ov-card">
          <template v-for="(g, gi) in [wide, tall]" :key="gi">
            <svg :class="gi ? 'tall' : 'wide'" :viewBox="`0 0 ${g.w} ${g.h}`" role="img" :aria-label="r.label">
              <!-- node box -->
              <rect :x="g.node.x" :y="g.node.y" :width="g.node.w" :height="g.node.h" rx="22" class="nodebox" />
              <text :x="g.node.x + g.node.w / 2" :y="g.node.y - 12" class="lbl strong" text-anchor="middle">{{ r.node }}</text>

              <!-- lanes into the engine -->
              <path :d="g.lanes.premium" class="lane" :class="{ hot: cur === 2 }" />
              <path :d="g.lanes.standard" class="lane" />
              <text :x="g.laneLabel.premium[0]" :y="g.laneLabel.premium[1]" class="lbl mono" text-anchor="middle" :class="{ hotT: cur === 2 }">premium</text>
              <text :x="g.laneLabel.standard[0]" :y="g.laneLabel.standard[1]" class="lbl mono" text-anchor="middle">standard</text>

              <!-- branches out of the engine -->
              <path v-for="e in ['warp', 'nord', 'direct', 'block']" :key="e" :d="g.branches[e]" class="br" :class="['x-' + e, { on: used.has(e) }]" />

              <!-- exits -->
              <g v-for="e in ['warp', 'nord', 'direct', 'block']" :key="'s' + e" class="exit" :class="['x-' + e, { on: used.has(e) }]">
                <circle :cx="g.exits[e][0]" :cy="g.exits[e][1]" r="13" class="st" />
                <path v-if="e === 'block'" :d="`M${g.exits[e][0] - 5} ${g.exits[e][1] - 5}l10 10m0-10l-10 10`" class="xmark" />
                <text :x="g.exits[e][0]" :y="g.exits[e][1] + (gi ? 30 : -22)" class="lbl strong" text-anchor="middle">{{ r.exits[e] }}</text>
              </g>

              <!-- engine -->
              <g class="engine">
                <circle :cx="g.engine[0]" :cy="g.engine[1]" r="40" class="ring" />
                <circle :cx="g.engine[0]" :cy="g.engine[1]" r="30" class="core" />
                <text :x="g.engine[0]" :y="g.engine[1] + 5" class="lbl strong" text-anchor="middle">{{ r.engine }}</text>
              </g>

              <!-- clients -->
              <circle :cx="g.clients[0]" :cy="g.clients[1]" r="22" class="me" />
              <g class="dev" aria-hidden="true">
                <circle :cx="g.clients[0] - 7" :cy="g.clients[1] - 3" r="3.5" />
                <circle :cx="g.clients[0] + 7" :cy="g.clients[1] - 3" r="3.5" />
                <path :d="`M${g.clients[0] - 12} ${g.clients[1] + 9}q5-7 12 0q7-7 12 0`" />
              </g>
              <text v-if="!gi" :x="g.clients[0]" :y="g.clients[1] + 44" class="lbl" text-anchor="middle">{{ r.clients }}</text>

              <!-- packets -->
              <g v-if="!reduced">
                <g
                  v-for="p in packets"
                  :key="cur + '-' + p.i"
                  class="pk"
                  :class="'x-' + p.exit"
                  :style="{ offsetPath: `path('${g.full(p.lane, p.exit)}')`, animationDelay: `${-p.i * 0.95}s` }"
                >
                  <circle r="7" />
                  <text v-if="!gi" y="-14" class="pkT" text-anchor="middle">{{ p.host }}</text>
                </g>
              </g>
            </svg>
          </template>
          <p class="always">{{ r.always }}</p>
        </div>

        <aside class="side">
          <div class="rules ov-card">
            <p class="cap">{{ r.rulesTitle }}</p>
            <ol>
              <li v-for="(ru, i) in preset.rules" :key="cur + 'r' + i" class="rule">
                <span class="n">{{ fa ? fd(i + 1) : i + 1 }}</span>
                <span class="chips"><code v-for="m in ru.match" :key="m" dir="ltr">{{ m }}</code></span>
                <span class="to" :class="'x-' + ru.exit">{{ r.exits[ru.exit] }}</span>
              </li>
              <li class="rule dflt">
                <span class="n">*</span>
                <span class="chips"><em>{{ r.defaultRule }}</em></span>
                <span class="to" :class="'x-' + preset.dflt">{{ r.exits[preset.dflt] }}</span>
              </li>
            </ol>
          </div>

          <div class="test ov-card">
            <p class="cap">{{ r.test.title }} <span>· {{ r.test.from }}</span></p>
            <p class="ok"><i aria-hidden="true" />{{ r.test.ok }}</p>
            <div class="bars" aria-hidden="true"><i v-for="b in 12" :key="b" :style="{ '--b': b, height: 30 + ((b * 37) % 70) + '%' }" /></div>
            <dl>
              <div><dt>WARP</dt><dd><b>{{ ms }}</b> {{ r.test.ms }}</dd></div>
              <div><dt>{{ r.test.exit }}</dt><dd dir="ltr">104.28.x.x</dd></div>
              <div><dt>&nbsp;</dt><dd>{{ r.test.country }}</dd></div>
            </dl>
            <p class="ex">{{ r.test.example }}</p>
          </div>

          <a class="ov-btn primary" :href="withBase(prefix + LINKS.routing)">{{ r.link }}</a>
        </aside>
      </div>
    </div>
  </section>
</template>

<style scoped>
.tabs { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 16px; }
.tab {
  min-height: 44px;
  padding: 0 18px;
  border: 1px solid var(--o-line-strong);
  border-radius: 999px;
  background: transparent;
  color: var(--vp-c-text-2);
  font-size: 15px;
  font-weight: 650;
  cursor: pointer;
  transition: background 0.25s, color 0.25s, border-color 0.25s, transform 0.35s var(--o-spring);
}
.tab:hover { color: var(--vp-c-text-1); transform: translateY(-2px); }
.tab.on {
  border-color: var(--vp-c-brand-3);
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-text-1);
  box-shadow: 0 10px 26px -16px var(--o-glow);
}

.stage { display: grid; gap: 18px; }
@media (min-width: 1060px) { .stage { grid-template-columns: minmax(0, 1fr) 300px; align-items: start; } }

.board { position: relative; padding: 14px 10px 16px; overflow: hidden; }
.board svg { display: block; width: 100%; height: auto; overflow: visible; }
.tall { display: none !important; }
@media (max-width: 699px) {
  .wide { display: none !important; }
  .tall { display: block !important; max-width: 420px; margin: 0 auto; }
}

.always { margin: 4px 12px 0; font-size: 13.5px; color: var(--vp-c-text-2); }

/* colours of the four exits */
.x-warp { --c: var(--o-oc); }
.x-nord { --c: var(--o-wg); }
.x-direct { --c: var(--vp-c-brand-1); }
.x-block { --c: var(--o-bad); }

.nodebox { fill: color-mix(in srgb, var(--vp-c-bg-soft) 70%, transparent); stroke: var(--o-line-strong); stroke-width: 1.5; stroke-dasharray: 5 6; }
.lane { fill: none; stroke: var(--o-line-strong); stroke-width: 6; stroke-linecap: round; stroke-linejoin: round; transition: stroke 0.4s; }
.lane.hot { stroke: color-mix(in srgb, var(--o-wg) 70%, transparent); }
.br {
  fill: none;
  stroke: var(--c);
  stroke-width: 6;
  stroke-linecap: round;
  stroke-linejoin: round;
  opacity: 0.16;
  transition: opacity 0.5s var(--o-out);
}
.br.on { opacity: 0.85; stroke-dasharray: 2 14; }
.live .br.on { animation: dash 0.9s linear infinite; }
@keyframes dash { to { stroke-dashoffset: -32; } }

.exit .st { fill: var(--o-station); stroke: var(--c); stroke-width: 4; opacity: 0.4; transition: opacity 0.4s, filter 0.4s; }
.exit.on .st { opacity: 1; filter: drop-shadow(0 0 8px var(--c)); }
.exit .lbl { opacity: 0.5; transition: opacity 0.4s; }
.exit.on .lbl { opacity: 1; }
.xmark { stroke: var(--c); stroke-width: 2.5; stroke-linecap: round; }

.ring { fill: none; stroke: var(--vp-c-brand-3); stroke-width: 2; stroke-dasharray: 4 9; transform-box: fill-box; transform-origin: center; }
.live .ring { animation: spin 14s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
.core { fill: var(--o-station); stroke: var(--vp-c-brand-3); stroke-width: 3; filter: drop-shadow(0 0 14px var(--o-glow)); }
.me { fill: var(--o-station); stroke: var(--vp-c-text-2); stroke-width: 3; }
.dev { fill: none; stroke: var(--vp-c-text-1); stroke-width: 2; }
.dev circle { fill: var(--vp-c-text-1); stroke: none; }

.lbl { fill: var(--vp-c-text-2); font-size: 14px; font-family: var(--vp-font-family-base); }
.lbl.strong { fill: var(--vp-c-text-1); font-weight: 700; }
.lbl.mono { font-family: var(--vp-font-family-mono); font-size: 12.5px; }
.hotT { fill: var(--o-wg); }

/* a packet rides its full path from the client to its exit */
.pk {
  offset-rotate: 0deg;
  offset-distance: 0%;
  opacity: 0;
  animation: ride 6.6s cubic-bezier(0.45, 0.05, 0.4, 1) infinite;
  animation-play-state: paused;
}
.live .pk { animation-play-state: running; }
.pk circle { fill: var(--o-station); stroke: var(--c); stroke-width: 3.5; filter: drop-shadow(0 0 6px var(--c)); }
.pkT { fill: var(--vp-c-text-1); font-family: var(--vp-font-family-mono); font-size: 12px; paint-order: stroke; stroke: var(--o-station); stroke-width: 4px; stroke-linejoin: round; }
@keyframes ride {
  0% { offset-distance: 0%; opacity: 0; }
  6% { opacity: 1; }
  88% { opacity: 1; }
  100% { offset-distance: 100%; opacity: 0; }
}
.x-block.pk { animation-name: ride-block; }
@keyframes ride-block {
  0% { offset-distance: 0%; opacity: 0; }
  6% { opacity: 1; }
  84% { opacity: 1; transform: scale(1); }
  100% { offset-distance: 100%; opacity: 0; transform: scale(0.2); }
}

.side { display: grid; gap: 14px; align-content: start; }
@media (min-width: 700px) and (max-width: 1059px) {
  .side { grid-template-columns: 1fr 1fr; }
  .side .ov-btn { grid-column: 1 / -1; justify-self: start; }
}
.cap { margin: 0 0 12px; font-size: 13px; font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase; color: var(--vp-c-text-2); }
.cap span { font-weight: 500; letter-spacing: 0; text-transform: none; }
[dir="rtl"] .cap { letter-spacing: 0; }
.rules, .test { padding: 18px; }
ol { display: grid; gap: 8px; margin: 0; padding: 0; list-style: none; }
.rule {
  display: grid;
  grid-template-columns: 22px minmax(0, 1fr) auto;
  align-items: center;
  gap: 10px;
  margin: 0;
  padding: 10px;
  border: 1px solid var(--o-line);
  border-radius: 12px;
  background: var(--vp-c-bg-soft);
  animation: in 0.5s var(--o-out) backwards;
}
.rule:nth-child(2) { animation-delay: 0.07s; }
.rule:nth-child(3) { animation-delay: 0.14s; }
@keyframes in { from { opacity: 0; transform: translateY(8px); } }
.n { font-family: var(--vp-font-family-mono); font-size: 12px; color: var(--vp-c-text-3); text-align: center; }
.chips { display: flex; flex-wrap: wrap; gap: 4px; min-width: 0; }
.chips code { padding: 2px 6px; border-radius: 6px; background: var(--vp-c-default-soft); font-size: 11.5px; overflow-wrap: anywhere; }
.chips em { font-style: normal; font-size: 13.5px; color: var(--vp-c-text-2); }
.to {
  padding: 3px 9px;
  border-radius: 999px;
  border: 1px solid var(--c);
  background: color-mix(in srgb, var(--c) 14%, transparent);
  font-size: 12.5px;
  font-weight: 700;
  white-space: nowrap;
}

.ok { display: flex; align-items: center; gap: 8px; margin: 0 0 10px; font-weight: 700; color: var(--o-good); }
.ok i { width: 9px; height: 9px; border-radius: 50%; background: currentColor; box-shadow: 0 0 10px currentColor; }
.bars { display: flex; align-items: flex-end; gap: 4px; height: 34px; margin-bottom: 12px; }
.bars i {
  flex: 1;
  border-radius: 3px;
  background: linear-gradient(to top, color-mix(in srgb, var(--o-good) 35%, transparent), var(--o-good));
  transform-origin: bottom;
  transform: scaleY(0.3);
  transition: transform 0.7s var(--o-spring) calc(var(--b) * 45ms);
}
.live .bars i { transform: scaleY(1); }
dl { display: grid; gap: 0; margin: 0; }
dl div { display: flex; justify-content: space-between; gap: 10px; padding: 7px 0; border-top: 1px solid var(--o-line); font-size: 14px; }
dt { color: var(--vp-c-text-2); }
dd { margin: 0; font-weight: 600; }
dd b { font-family: var(--o-display); font-size: 18px; }
.ex { margin: 8px 0 0; font-size: 12px; color: var(--vp-c-text-3); }

@media (prefers-reduced-motion: reduce) {
  .rule, .bars i { animation: none; transition: none; transform: none; }
}
</style>

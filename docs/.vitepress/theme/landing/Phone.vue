<script setup lang="ts">
import { computed, ref } from "vue";
import { fd } from "./copy";
import { mx, tabKeys, useCopy } from "./use";

const { fa, t } = useCopy();
const s = computed(() => t.value.page);
const p = computed(() => s.value.ph);
const cur = ref(0);
const pick = (i: number) => (cur.value = i);
const num = (v: string) => (fa.value ? fd(v) : v);

// usage chart: seven days, downloads and uploads, mirrored on the Persian page
const CW = 260;
const CH = 84;
const DOWN = [1.2, 2.4, 0.8, 3.1, 2.2, 4.0, 1.6];
const UP = [0.3, 0.6, 0.2, 0.9, 0.5, 1.1, 0.4];
const area = (vals: number[]) => {
  const pts = vals.map((v, i) => [mx(6 + (i * (CW - 12)) / 6, CW, fa.value), CH - 8 - (v / 4.4) * (CH - 22)] as [number, number]);
  const line = pts.map(([x, y], i) => `${i ? "L" : "M"}${x.toFixed(1)} ${y.toFixed(1)}`).join("");
  const first = pts[0][0];
  const last = pts[pts.length - 1][0];
  return { line, fill: `${line}L${last} ${CH - 8}L${first} ${CH - 8}Z` };
};
const down = computed(() => area(DOWN));
const up = computed(() => area(UP));

// the traffic and days rings
const R = 30;
const C = 2 * Math.PI * R;
const trafficFrac = 34.2 / 50;
const daysFrac = 21 / 30;

// a stand-in QR pattern, decorative only
const qr = Array.from({ length: 21 * 21 }, (_, i) => {
  const x = i % 21;
  const y = Math.floor(i / 21);
  const finder = (x < 7 && y < 7) || (x > 13 && y < 7) || (x < 7 && y > 13);
  if (finder) {
    const fx = x > 13 ? x - 14 : x;
    const fy = y > 13 ? y - 14 : y;
    return fx === 0 || fx === 6 || fy === 0 || fy === 6 || (fx > 1 && fx < 5 && fy > 1 && fy < 5);
  }
  return ((x * 7 + y * 13 + x * y) % 5) % 2 === 0;
});
</script>

<template>
  <section :id="s.id" class="ov-section page">
    <div class="ov-wrap">
      <header class="ov-head" data-reveal>
        <p class="ov-eyebrow">{{ s.n }}</p>
        <h2 class="ov-h2">{{ s.title }}</h2>
        <p class="ov-lede">{{ s.lede }}</p>
      </header>

      <div class="grid">
        <ul class="facts" data-reveal>
          <li v-for="x in s.facts" :key="x">{{ x }}</li>
        </ul>

        <div class="stage" data-reveal>
          <div class="phone" role="group" :aria-label="p.example">
            <div class="screen">
              <i class="glow g1" aria-hidden="true" />
              <i class="glow g2" aria-hidden="true" />
              <div class="inner">
                <p class="kick">{{ p.kicker }} <b>{{ p.name }}</b></p>
                <p class="ttl">{{ p.title }}</p>

                <div class="figs">
                  <div class="fig">
                    <svg viewBox="0 0 80 80" aria-hidden="true">
                      <circle cx="40" cy="40" :r="R" class="trk" />
                      <circle cx="40" cy="40" :r="R" class="arc" :stroke-dasharray="`${C * trafficFrac} ${C}`" />
                    </svg>
                    <div><b>{{ num(p.trafficVal) }}</b><span>{{ p.trafficUnit }}</span><small>{{ p.trafficLeft }}</small></div>
                  </div>
                  <div class="fig">
                    <svg viewBox="0 0 80 80" aria-hidden="true">
                      <circle cx="40" cy="40" :r="R" class="trk" />
                      <circle cx="40" cy="40" :r="R" class="arc b" :stroke-dasharray="`${C * daysFrac} ${C}`" />
                    </svg>
                    <div><b>{{ num(p.daysVal) }}</b><small>{{ p.daysLeft }}</small></div>
                  </div>
                </div>

                <div class="gl usage">
                  <p class="h">{{ p.usage }}</p>
                  <svg :viewBox="`0 0 ${CW} ${CH}`" aria-hidden="true">
                    <path :d="down.fill" class="a1" />
                    <path :d="down.line" class="l1" />
                    <path :d="up.fill" class="a2" />
                    <path :d="up.line" class="l2" />
                  </svg>
                  <p class="lg"><span class="k1" />{{ p.down }} <span class="k2" />{{ p.up }}</p>
                </div>

                <div class="tabs" role="tablist" :aria-label="p.tabsLabel">
                  <button
                    v-for="(tb, i) in p.tabs"
                    :id="'ph-tab-' + i"
                    :key="tb"
                    type="button"
                    role="tab"
                    :aria-selected="cur === i"
                    :aria-controls="'ph-panel-' + i"
                    :tabindex="cur === i ? 0 : -1"
                    :class="{ on: cur === i }"
                    @click="pick(i)"
                    @keydown="tabKeys($event, p.tabs.length, cur, pick, fa)"
                  >{{ tb }}</button>
                </div>

                <div v-show="cur === 0" id="ph-panel-0" role="tabpanel" aria-labelledby="ph-tab-0" class="tp">
                  <span class="b prime">{{ p.ovpnImport }}</span>
                  <span class="b">{{ p.ovpnDownload }}</span>
                  <div class="gl note"><b>{{ p.allIn }}</b><span>{{ p.allInLede }}</span></div>
                </div>
                <div v-show="cur === 1" id="ph-panel-1" role="tabpanel" aria-labelledby="ph-tab-1" class="tp">
                  <div class="qrrow">
                    <svg viewBox="0 0 21 21" class="qr" aria-hidden="true" shape-rendering="crispEdges">
                      <rect width="21" height="21" fill="#fff" />
                      <template v-for="(on, i) in qr" :key="i"><rect v-if="on" :x="i % 21" :y="Math.floor(i / 21)" width="1" height="1" fill="#0b1020" /></template>
                    </svg>
                    <div><span class="b prime">{{ p.wgDownload }}</span><span class="hint">{{ p.wgHint }}</span></div>
                  </div>
                </div>
                <div v-show="cur === 2" id="ph-panel-2" role="tabpanel" aria-labelledby="ph-tab-2" class="tp">
                  <span class="hint">{{ p.ocLede }}</span>
                  <div class="gl kv"><small>{{ p.ocAddress }}</small><code dir="ltr">vpn.example.com</code></div>
                  <div class="gl kv"><small>{{ p.ocUser }}</small><code dir="ltr">{{ p.name }}</code></div>
                </div>

                <p class="live"><i aria-hidden="true" />{{ p.online }}<span>{{ p.devices }}</span></p>
              </div>
            </div>
          </div>
          <p class="cap">{{ p.example }}</p>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.grid {
  display: grid;
  gap: 40px;
  align-items: center;
}
@media (min-width: 900px) {
  .grid {
    grid-template-columns: minmax(0, 1fr) minmax(0, 360px);
    gap: 72px;
  }
}

.facts {
  display: grid;
  gap: 18px;
  margin: 0;
  padding: 0;
  list-style: none;
}
.facts li {
  position: relative;
  padding-inline-start: 28px;
  font-size: 17px;
  line-height: 1.7;
}
[dir="rtl"] .facts li { line-height: 2; }
.facts li::before {
  content: "";
  position: absolute;
  top: 0.62em;
  inset-inline-start: 0;
  width: 12px;
  height: 12px;
  border: 3px solid var(--vp-c-brand-3);
  border-radius: 50%;
  background: var(--o-station);
}

.stage {
  justify-self: center;
  width: 100%;
  max-width: 340px;
}

/* Aurora, as the customer page draws it: soft colour glow, frosted cards */
.phone {
  --pg-bg: #f5f7fb;
  --pg-ink: #0f172a;
  --pg-dim: #475569;
  --pg-card: rgba(255, 255, 255, 0.72);
  --pg-line: rgba(15, 23, 42, 0.1);
  --pg-acc: #0d9488;
  --pg-acc2: #6d5be6;
  --pg-btn-ink: #fff;
  padding: 10px;
  border: 1px solid var(--o-line-strong);
  border-radius: 44px;
  background: var(--vp-c-bg-elv);
  box-shadow: 0 40px 70px -34px var(--o-shadow), inset 0 1px 0 var(--o-edge);
}
.dark .phone {
  --pg-bg: #0b1020;
  --pg-ink: #e8edf8;
  --pg-dim: #a5b1c9;
  --pg-card: rgba(255, 255, 255, 0.07);
  --pg-line: rgba(255, 255, 255, 0.12);
  --pg-acc: #2dd4bf;
  --pg-acc2: #8b7bff;
  --pg-btn-ink: #04201c;
}

.screen {
  position: relative;
  overflow: hidden;
  border-radius: 34px;
  background: var(--pg-bg);
  color: var(--pg-ink);
}
.glow {
  position: absolute;
  width: 240px;
  height: 240px;
  border-radius: 50%;
  filter: blur(54px);
  opacity: 0.55;
}
.g1 { top: -90px; inset-inline-start: -70px; background: var(--pg-acc); }
.g2 { top: 120px; inset-inline-end: -110px; background: var(--pg-acc2); opacity: 0.4; }

.inner {
  position: relative;
  display: grid;
  gap: 12px;
  padding: 26px 18px 20px;
}
.kick { margin: 0; font-size: 12.5px; color: var(--pg-dim); }
.kick b { color: var(--pg-ink); }
.ttl { margin: -4px 0 2px; font-family: var(--o-display); font-size: 26px; font-weight: 700; letter-spacing: -0.03em; }
[dir="rtl"] .ttl { letter-spacing: 0; }

.gl {
  border: 1px solid var(--pg-line);
  border-radius: 16px;
  background: var(--pg-card);
  backdrop-filter: blur(10px);
}

.figs { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.fig {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px;
  border: 1px solid var(--pg-line);
  border-radius: 16px;
  background: var(--pg-card);
  backdrop-filter: blur(10px);
}
.fig svg { flex: none; width: 52px; height: 52px; transform: rotate(-90deg); }
[dir="rtl"] .fig svg { transform: rotate(-90deg) scaleY(-1); }
.trk { fill: none; stroke: var(--pg-line); stroke-width: 9; }
.arc { fill: none; stroke: var(--pg-acc); stroke-width: 9; stroke-linecap: round; }
.arc.b { stroke: var(--pg-acc2); }
.fig b { font-size: 21px; line-height: 1.1; font-variant-numeric: tabular-nums; }
.fig span { margin-inline-start: 3px; font-size: 11px; color: var(--pg-dim); }
.fig small { display: block; margin-top: 2px; font-size: 11px; line-height: 1.3; color: var(--pg-dim); }

.usage { padding: 12px 14px 10px; }
.h { margin: 0 0 4px; font-size: 13px; font-weight: 650; }
.usage svg { display: block; width: 100%; height: auto; }
.a1 { fill: var(--pg-acc); opacity: 0.2; }
.l1 { fill: none; stroke: var(--pg-acc); stroke-width: 2.2; stroke-linejoin: round; }
.a2 { fill: var(--pg-acc2); opacity: 0.2; }
.l2 { fill: none; stroke: var(--pg-acc2); stroke-width: 2.2; stroke-linejoin: round; }
.lg { display: flex; align-items: center; gap: 6px; margin: 4px 0 0; font-size: 11.5px; color: var(--pg-dim); }
.lg span { width: 14px; height: 4px; border-radius: 2px; }
.lg .k1 { background: var(--pg-acc); }
.lg .k2 { background: var(--pg-acc2); margin-inline-start: 8px; }

.tabs { display: flex; gap: 4px; padding: 4px; border: 1px solid var(--pg-line); border-radius: 14px; background: var(--pg-card); }
.tabs button {
  flex: 1;
  min-height: 44px;
  border: 0;
  border-radius: 10px;
  background: transparent;
  color: var(--pg-dim);
  font-size: 13px;
  font-weight: 650;
  cursor: pointer;
}
.tabs button.on { background: var(--pg-ink); color: var(--pg-bg); }
.tabs button:focus-visible { outline: 2px solid var(--pg-acc); outline-offset: 2px; }

.tp { display: grid; gap: 8px; min-height: 148px; align-content: start; }
.b {
  display: grid;
  place-items: center;
  min-height: 44px;
  padding: 0 12px;
  border: 1px solid var(--pg-line);
  border-radius: 12px;
  background: var(--pg-card);
  font-size: 13.5px;
  font-weight: 650;
  text-align: center;
}
.b.prime { border-color: transparent; background: var(--pg-acc); color: var(--pg-btn-ink); }
.note { display: grid; gap: 2px; padding: 10px 12px; font-size: 12.5px; line-height: 1.5; }
.note span, .hint { color: var(--pg-dim); font-size: 12.5px; line-height: 1.55; }
.qrrow { display: flex; gap: 12px; align-items: flex-start; }
.qrrow > div { display: grid; gap: 8px; flex: 1; min-width: 0; }
.qr { flex: none; width: 82px; height: 82px; padding: 5px; border-radius: 10px; background: #fff; }
.kv { display: grid; gap: 2px; padding: 8px 12px; }
.kv small { font-size: 11px; color: var(--pg-dim); }
.kv code { background: none; padding: 0; font-family: var(--vp-font-family-mono); font-size: 13px; color: var(--pg-ink); }

.live { display: flex; flex-wrap: wrap; align-items: center; gap: 6px; margin: 0; font-size: 12.5px; font-weight: 650; }
.live i { width: 8px; height: 8px; border-radius: 50%; background: #22c55e; box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.25); }
.live span { margin-inline-start: auto; color: var(--pg-dim); font-weight: 500; }

.cap { margin: 12px 0 0; font-size: 13px; text-align: center; color: var(--vp-c-text-2); }
</style>

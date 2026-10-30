<script setup lang="ts">
import { computed, ref } from "vue";
import { mx, roundedPath, tabKeys, useCopy, useLive } from "./use";

const { fa, t } = useCopy();
const w = computed(() => t.value.ways);
const cur = ref(0);
const root = ref<HTMLElement>();
const { live, reduced } = useLive(root);

const CODE = {
  ovpn: [
    "client",
    "dev tun",
    "remote vpn.example.com 1194 udp",
    "resolv-retry infinite",
    "nobind",
    "remote-cert-tls server",
    "auth-user-pass",
    "<ca>",
    "-----BEGIN CERTIFICATE-----",
    "...",
    "</ca>",
  ],
  wg: [
    "[Interface]",
    "PrivateKey = <client key>",
    "Address = 10.7.0.2/32",
    "DNS = 1.1.1.1",
    "MTU = 1420",
    "",
    "[Peer]",
    "PublicKey = <server key>",
    "PresharedKey = <shared key>",
    "Endpoint = vpn.example.com:51820",
    "AllowedIPs = 0.0.0.0/0, ::/0",
    "PersistentKeepalive = 25",
  ],
} as const;

const kind = (l: string) => (l.startsWith("[") || l.startsWith("<") ? "h" : l.startsWith("-") || l === "..." ? "d" : "");

// mini map: the client on the left, three lines out to three servers
const MW = 360;
const MH = 150;
type Pt = [number, number];
const RAW: Pt[][] = [
  [[50, 62], [170, 62], [210, 26], [316, 26]],
  [[50, 75], [316, 75]],
  [[50, 88], [170, 88], [210, 124], [316, 124]],
];
const mini = computed(() =>
  RAW.map((pts) => {
    const m = pts.map(([x, y]) => [mx(x, MW, fa.value), y] as Pt);
    return { d: roundedPath(m, 16), end: m[m.length - 1] };
  }),
);
const cx = computed(() => mx(30, MW, fa.value));
const KEY = ["ovpn", "wg", "oc"] as const;
const pick = (i: number) => (cur.value = i);
</script>

<template>
  <section :id="w.id" ref="root" class="ov-section ways">
    <div class="ov-wrap">
      <header class="ov-head" data-reveal>
        <p class="ov-eyebrow">{{ w.n }}</p>
        <h2 class="ov-h2">{{ w.title }}</h2>
        <p class="ov-lede">{{ w.lede }}</p>
      </header>

      <div class="grid" data-reveal>
        <div class="left">
          <div class="card ov-card">
            <p class="ex">{{ w.client.example }}</p>
            <p class="who"><span class="av" aria-hidden="true">{{ w.client.name[0] }}</span>{{ w.client.name }}</p>
            <dl>
              <div><dt>{{ w.client.traffic }}</dt><dd>{{ w.client.trafficVal }}</dd></div>
              <div><dt>{{ w.client.days }}</dt><dd>{{ w.client.daysVal }}</dd></div>
              <div><dt>{{ w.client.devices }}</dt><dd>{{ w.client.devicesVal }}</dd></div>
            </dl>
          </div>

          <svg class="mini" :viewBox="`0 0 ${MW} ${MH}`" role="img" :aria-label="w.tabs[cur].name" preserveAspectRatio="xMidYMid meet">
            <g v-for="(m, i) in mini" :key="i" :class="['c-' + KEY[i], { on: cur === i }]" class="mline">
              <path :d="m.d" class="p" />
              <circle :cx="m.end[0]" :cy="m.end[1]" r="7" class="end" />
              <circle v-if="cur === i && live && !reduced" r="5" class="tr" :style="{ offsetPath: `path('${m.d}')` }" />
            </g>
            <circle :cx="cx" cy="75" r="17" class="me" />
            <text :x="cx" y="80" class="meT">{{ w.client.name[0] }}</text>
          </svg>
          <p class="note">{{ w.note }}</p>
        </div>

        <div class="right">
          <div class="tabs" role="tablist" :aria-label="w.tabsLabel">
            <button
              v-for="(tb, i) in w.tabs"
              :id="'way-tab-' + tb.key"
              :key="tb.key"
              type="button"
              role="tab"
              :aria-selected="cur === i"
              :aria-controls="'way-panel-' + tb.key"
              :tabindex="cur === i ? 0 : -1"
              :class="['tab', 'k-' + tb.key, { on: cur === i }]"
              @click="pick(i)"
              @keydown="tabKeys($event, w.tabs.length, cur, pick, fa)"
            >
              <i class="ov-dot" aria-hidden="true" />{{ tb.name }}
            </button>
          </div>

          <div
            v-for="(tb, i) in w.tabs"
            v-show="cur === i"
            :id="'way-panel-' + tb.key"
            :key="tb.key"
            role="tabpanel"
            :aria-labelledby="'way-tab-' + tb.key"
            class="panel ov-card"
            tabindex="0"
          >
            <p class="text">{{ tb.text }}</p>
            <div class="file" :class="'k-' + tb.key">
              <div class="bar"><span class="dots" aria-hidden="true"><i /><i /><i /></span><span class="fn" dir="ltr">{{ tb.file }}</span></div>
              <pre v-if="tb.key !== 'oc'" dir="ltr"><code><template v-for="(l, j) in CODE[tb.key]" :key="j"><span :class="kind(l)">{{ l || " " }}</span>{{ "\n" }}</template></code></pre>
              <div v-else class="oc">
                <label>{{ w.ocAddress }}<span class="field" dir="ltr">vpn.example.com</span></label>
                <label>{{ w.ocUser }}<span class="field" dir="ltr">{{ w.client.name }}</span></label>
                <label>{{ w.ocPass }}<span class="field dim">{{ w.ocPassVal }}</span></label>
              </div>
            </div>
            <p v-if="tb.key !== 'oc'" class="abr">{{ w.abridged }}</p>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.grid {
  display: grid;
  gap: 28px;
}

@media (min-width: 900px) {
  .grid {
    grid-template-columns: minmax(0, 380px) minmax(0, 1fr);
    gap: 40px;
  }
}

.card {
  padding: 22px 24px;
}

.ex {
  margin: 0 0 10px;
  font-family: var(--vp-font-family-mono);
  font-size: 11.5px;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--vp-c-text-2);
}
[dir="rtl"] .ex { font-family: var(--vp-font-family-base); letter-spacing: 0; font-size: 13px; }

.who {
  display: flex;
  align-items: center;
  gap: 12px;
  margin: 0 0 16px;
  font-family: var(--o-display);
  font-size: 24px;
  font-weight: 650;
}
.av {
  display: grid;
  place-items: center;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: var(--vp-c-brand-soft);
  border: 1px solid var(--o-line-strong);
  font-size: 17px;
  text-transform: uppercase;
  color: var(--vp-c-brand-1);
}
dl { margin: 0; display: grid; gap: 0; }
dl div {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  padding: 10px 0;
  border-top: 1px solid var(--o-line);
  font-size: 15px;
}
dt { color: var(--vp-c-text-2); }
dd { margin: 0; font-weight: 650; }

.mini { display: block; width: 100%; height: auto; margin-top: 18px; overflow: visible; }
.mline { opacity: 0.22; transition: opacity 0.4s; }
.mline.on { opacity: 1; }
.p { fill: none; stroke: currentColor; stroke-width: 7; stroke-linecap: round; stroke-linejoin: round; }
.end { fill: var(--o-station); stroke: currentColor; stroke-width: 4; }
.me { fill: var(--o-station); stroke: var(--vp-c-brand-3); stroke-width: 5; }
.meT { fill: var(--vp-c-text-1); font-size: 16px; font-weight: 700; text-anchor: middle; text-transform: uppercase; }
.tr {
  fill: var(--vp-c-text-1);
  stroke: currentColor;
  stroke-width: 3;
  offset-rotate: 0deg;
  animation: go 3.4s linear infinite;
}
@keyframes go { from { offset-distance: 0%; } to { offset-distance: 100%; } }

.note { margin: 6px 0 0; font-size: 14px; color: var(--vp-c-text-2); line-height: 1.7; }

.tabs { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 14px; }
.tab {
  display: inline-flex;
  align-items: center;
  gap: 9px;
  min-height: 44px;
  padding: 0 18px;
  border: 1px solid var(--o-line-strong);
  border-radius: 999px;
  background: transparent;
  color: var(--vp-c-text-2);
  font-size: 15px;
  font-weight: 650;
  cursor: pointer;
  transition: background 0.25s, color 0.25s, border-color 0.25s;
}
.tab .ov-dot { color: currentColor; }
.tab:hover { color: var(--vp-c-text-1); }
.tab.on {
  border-color: currentColor;
  background: color-mix(in srgb, currentColor 13%, transparent);
}
.tab.on { color: var(--vp-c-text-1); }
.tab.on .ov-dot { box-shadow: 0 0 10px currentColor; }
.tab.k-ovpn .ov-dot { color: var(--o-ovpn); }
.tab.k-wg .ov-dot { color: var(--o-wg); }
.tab.k-oc .ov-dot { color: var(--o-oc); }
.tab.k-ovpn.on { border-color: var(--o-ovpn); background: color-mix(in srgb, var(--o-ovpn) 14%, transparent); }
.tab.k-wg.on { border-color: var(--o-wg); background: color-mix(in srgb, var(--o-wg) 14%, transparent); }
.tab.k-oc.on { border-color: var(--o-oc); background: color-mix(in srgb, var(--o-oc) 14%, transparent); }

.panel { padding: 22px; }
.text { margin: 0 0 16px; font-size: 16px; line-height: 1.75; }
[dir="rtl"] .text { line-height: 2; }

.file {
  overflow: hidden;
  border: 1px solid var(--o-line);
  border-radius: 14px;
  background: var(--vp-code-block-bg, #070d0e);
}
.dark .file { background: #070d0e; }
.bar {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 9px 14px;
  border-bottom: 1px solid var(--o-line);
  font-family: var(--vp-font-family-mono);
  font-size: 12.5px;
  color: var(--vp-c-text-2);
}
.dots { display: inline-flex; gap: 5px; }
.dots i { width: 9px; height: 9px; border-radius: 50%; background: var(--o-line-strong); }
.fn { overflow-wrap: anywhere; }
pre {
  margin: 0;
  padding: 14px 16px;
  overflow-x: auto;
  font-family: var(--vp-font-family-mono);
  font-size: 13px;
  line-height: 1.65;
  color: var(--vp-c-text-1);
}
pre .h { color: var(--vp-c-brand-1); }
pre .d { color: var(--vp-c-text-3); }
.k-wg pre .h { color: var(--o-wg); }
.k-oc pre .h { color: var(--o-oc); }
.abr { margin: 10px 0 0; font-size: 12.5px; color: var(--vp-c-text-2); }

.oc { display: grid; gap: 12px; padding: 18px 16px; }
.oc label { display: grid; gap: 6px; font-size: 13px; color: var(--vp-c-text-2); }
.field {
  display: block;
  padding: 11px 12px;
  border: 1px solid var(--o-line-strong);
  border-radius: 10px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  font-family: var(--vp-font-family-mono);
  font-size: 14px;
}
.field.dim { font-family: var(--vp-font-family-base); color: var(--vp-c-text-2); }

@media (prefers-reduced-motion: reduce) {
  .tr { animation: none; }
}
</style>

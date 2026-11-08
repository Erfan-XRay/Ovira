<script setup lang="ts">
import { computed, ref } from "vue";
import { withBase } from "vitepress";
import { INSTALL_CMD, LINKS } from "./copy";
import { useCopy } from "./use";
import Ticket from "./Ticket.vue";
import LineMap from "./LineMap.vue";
import VerticalMap from "./VerticalMap.vue";

const { t, prefix } = useCopy();
const root = ref<HTMLElement>();

// The headline as words, so they can rise one after another. The words from
// `accent` on carry the brand gradient.
const words = computed(() => t.value.hero.title.split(" ").map((w, i) => ({ w, accent: i >= t.value.hero.accent })));

</script>

<template>
  <section ref="root" class="hero ov-wrap">
    <div class="text">
      <a class="pill" :href="withBase(prefix + LINKS.changelog)">
        <span class="spark" aria-hidden="true" />
        <b>{{ t.hero.release }}</b>
        <span class="sub">{{ t.hero.releaseSub }}</span>
        <svg class="arr" viewBox="0 0 16 16" aria-hidden="true"><path d="M5 3l5 5-5 5" /></svg>
      </a>
      <p class="ov-eyebrow">{{ t.hero.eyebrow }}</p>
      <h1 :aria-label="t.hero.title">
        <template v-for="(x, i) in words" :key="i"><span class="wm" aria-hidden="true"><span class="w" :class="{ accent: x.accent }" :style="{ '--i': i }">{{ x.w }}</span></span>{{ i < words.length - 1 ? " " : "" }}</template>
      </h1>
      <p class="ov-lede">{{ t.hero.lede }}</p>
      <div class="hero-ticket">
        <Ticket :cmd="INSTALL_CMD" :kicker="t.hero.ticketKicker" :stub="t.hero.ticketStub" :stub-sub="t.hero.ticketStubSub" :note="t.hero.ticketNote" />
      </div>
      <div class="cta">
        <a class="ov-btn primary" :href="withBase(prefix + LINKS.install)">{{ t.hero.primary }}</a>
        <a class="ov-btn" :href="withBase(prefix + LINKS.how)">{{ t.hero.secondary }}</a>
      </div>
    </div>
    <div class="map">
      <div class="wide"><LineMap /></div>
      <div class="tall"><VerticalMap /></div>
    </div>
    <div class="marquee" role="region" :aria-label="t.hero.marqueeLabel">
      <ul class="track">
        <li v-for="m in t.hero.marquee" :key="m">{{ m }}</li>
      </ul>
      <ul class="track" aria-hidden="true">
        <li v-for="m in t.hero.marquee" :key="'b' + m">{{ m }}</li>
      </ul>
    </div>
  </section>
</template>

<style scoped>
.hero {
  display: grid;
  gap: 40px;
  padding-top: 48px;
  padding-bottom: 32px;
}

.text { min-width: 0; }

/* release pill with a moving shine */
.pill {
  position: relative;
  display: inline-flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 4px 10px;
  max-width: 100%;
  min-height: 40px;
  margin-bottom: 22px;
  padding: 7px 14px 7px 12px;
  overflow: hidden;
  border: 1px solid var(--o-line-strong);
  border-radius: 999px;
  background: var(--o-glass);
  color: var(--vp-c-text-1);
  font-size: 14px;
  text-decoration: none;
  transition: border-color 0.25s, transform 0.4s var(--o-spring);
}
[dir="rtl"] .pill { padding: 7px 12px 7px 14px; }
.pill:hover { border-color: var(--vp-c-brand-3); transform: translateY(-2px); }
.pill::after {
  content: "";
  position: absolute;
  inset: 0;
  background: linear-gradient(100deg, transparent 30%, color-mix(in srgb, var(--vp-c-brand-1) 22%, transparent) 50%, transparent 70%);
  transform: translateX(-100%);
  animation: shine 4.5s var(--o-out) 1.2s infinite;
  pointer-events: none;
}
.pill b { font-weight: 700; }
.pill .sub { color: var(--vp-c-text-2); }
.spark {
  width: 9px;
  height: 9px;
  border-radius: 50%;
  background: var(--vp-c-brand-1);
  animation: ping 2.2s ease-out infinite;
}
.arr { width: 14px; height: 14px; fill: none; stroke: currentColor; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
[dir="rtl"] .arr { transform: scaleX(-1); }

h1 {
  margin: 0;
  max-width: 14ch;
  font-family: var(--o-display);
  font-size: clamp(40px, 6.2vw, 70px);
  font-weight: 700;
  line-height: 1.04;
  letter-spacing: -0.045em;
  text-wrap: balance;
  color: var(--vp-c-text-1);
}
[dir="rtl"] h1 { max-width: 16ch; line-height: 1.4; letter-spacing: 0; }

/* each word is masked so it rises from below its own line */
.wm { display: inline-block; overflow: hidden; padding-bottom: 0.1em; margin-bottom: -0.1em; vertical-align: top; }
.w { display: inline-block; }
.w.accent {
  background: linear-gradient(100deg, var(--vp-c-brand-1), var(--o-cyan) 50%, var(--vp-c-brand-1));
  background-size: 200% 100%;
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}

.hero-ticket,
.cta { margin-top: 28px; }

/* entrance: pill, then the words one by one, then the rest */
.pill { animation: drop 0.7s var(--o-out) backwards, none; }
.w { animation: word 1s var(--o-out) calc(0.15s + var(--i) * 0.06s) backwards; }
.w.accent { animation: word 1s var(--o-out) calc(0.15s + var(--i) * 0.06s) backwards, flow 8s linear 1.2s infinite; }
.text > .ov-eyebrow { animation: fade 0.8s var(--o-out) 0.1s backwards; }
.text > .ov-lede { animation: rise 0.9s var(--o-out) 0.55s backwards; }
.hero-ticket { animation: rise 0.9s var(--o-out) 0.65s backwards; }
.cta { animation: rise 0.9s var(--o-out) 0.75s backwards; }
.map { animation: grow 1.4s var(--o-out) 0.25s backwards; }
.marquee { animation: fade 1.2s var(--o-out) 0.9s backwards; }
@keyframes drop { from { opacity: 0; transform: translateY(-14px); } }
@keyframes word { from { opacity: 0; transform: translateY(110%) rotate(4deg); } }
@keyframes rise { from { opacity: 0; transform: translateY(22px); filter: blur(6px); } }
@keyframes grow { from { opacity: 0; transform: scale(0.94); } }
@keyframes fade { from { opacity: 0; } }
.cta { display: flex; flex-wrap: wrap; gap: 12px; }

.map { min-width: 0; }
.tall { display: none; }

/* protocols and outbounds, scrolling past */
.marquee {
  display: flex;
  min-width: 0;
  overflow: hidden;
  padding: 6px 0;
  mask-image: linear-gradient(90deg, transparent, #000 10%, #000 90%, transparent);
  -webkit-mask-image: linear-gradient(90deg, transparent, #000 10%, #000 90%, transparent);
}
.track {
  display: flex;
  flex-shrink: 0;
  gap: 12px;
  margin: 0;
  padding: 0 6px;
  list-style: none;
  animation: slide 46s linear infinite;
}
[dir="rtl"] .track { animation-name: slide-rtl; }
.marquee:hover .track { animation-play-state: paused; }
.track li {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  margin: 0;
  padding: 8px 16px;
  border: 1px solid var(--o-line);
  border-radius: 999px;
  background: var(--o-glass);
  font-family: var(--vp-font-family-mono);
  font-size: 13.5px;
  line-height: 1.3;
  white-space: nowrap;
  color: var(--vp-c-text-2);
}
.track li::before {
  content: "";
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--vp-c-brand-3);
}

@keyframes shine { 0% { transform: translateX(-100%); } 40%, 100% { transform: translateX(100%); } }
@keyframes ping {
  0% { box-shadow: 0 0 0 0 var(--o-glow); }
  80%, 100% { box-shadow: 0 0 0 9px transparent; }
}
@keyframes flow { to { background-position: -200% 0; } }
@keyframes slide { to { transform: translateX(-100%); } }
@keyframes slide-rtl { to { transform: translateX(100%); } }

@media (min-width: 1100px) {
  .hero {
    grid-template-columns: minmax(0, 500px) minmax(0, 1fr);
    align-items: center;
    gap: 32px;
    padding-top: 64px;
  }
  .marquee { grid-column: 1 / -1; }
}

@media (max-width: 639px) {
  .wide { display: none; }
  .tall { display: block; }
  .hero { padding-top: 28px; }
  .pill { font-size: 13px; }
}

@media (prefers-reduced-motion: reduce) {
  .pill, .pill::after, .spark, .w, .w.accent, .text > *, .hero-ticket, .cta, .map, .marquee { animation: none; }
  .marquee { mask-image: none; -webkit-mask-image: none; }
  .track { animation: none; flex-wrap: wrap; flex-shrink: 1; }
  .track[aria-hidden="true"] { display: none; }
}
</style>

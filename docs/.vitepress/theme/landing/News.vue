<script setup lang="ts">
import { computed, ref } from "vue";
import { withBase } from "vitepress";
import { LINKS, RELEASE_URL } from "./copy";
import { useCopy } from "./use";

const { t, prefix } = useCopy();
const n = computed(() => t.value.news);
const root = ref<HTMLElement>();

// Lucide-style icon paths, 24x24, stroke only.
const ICON: Record<string, string> = {
  routing: "M6 3v12M18 9a3 3 0 1 0 0-6 3 3 0 0 0 0 6ZM6 21a3 3 0 1 0 0-6 3 3 0 0 0 0 6ZM18 9a9 9 0 0 1-9 9",
  warp: "M17.5 19H9a7 7 0 1 1 6.71-9h1.79a4.5 4.5 0 1 1 0 9Z",
  test: "M22 12h-4l-3 9L9 3l-3 9H2",
  ipsec: "M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10ZM9 12l2 2 4-4",
  certs: "M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6ZM8.5 14 7 22l5-3 5 3-1.5-8M4 4h16v5H4z",
  ports: "M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83",
};

</script>

<template>
  <section :id="n.id" ref="root" class="ov-section news">
    <div class="ov-wrap">
      <header class="head" data-reveal>
        <div>
          <p class="ov-eyebrow">{{ t.hero.release }}</p>
          <h2 class="ov-h2">{{ n.title }}</h2>
          <p class="ov-lede">{{ n.lede }}</p>
        </div>
        <span class="big" aria-hidden="true">{{ n.n }}</span>
      </header>

      <ul class="bento">
        <li v-for="(c, i) in n.cards" :key="c.key" class="cell glow ov-card" data-reveal data-tilt :style="{ '--rd': i * 90 + 'ms' }" :class="['k-' + c.key, { wide: i === 0 }]">
          <a :href="withBase(prefix + c.link)">
            <span class="ic" aria-hidden="true">
              <svg viewBox="0 0 24 24"><path :d="ICON[c.key]" /></svg>
            </span>
            <span class="tag">{{ c.tag }}</span>
            <h3>{{ c.title }}</h3>
            <p>{{ c.text }}</p>
            <svg v-if="i === 0" class="flow" viewBox="0 0 400 90" aria-hidden="true" preserveAspectRatio="none">
              <path class="f0" d="M0 45 H150 C200 45 200 15 250 15 H400" />
              <path class="f1" d="M0 45 H400" />
              <path class="f2" d="M0 45 H150 C200 45 200 75 250 75 H400" />
            </svg>
          </a>
        </li>
      </ul>

      <p class="links" data-reveal>
        <a class="ov-btn" :href="withBase(prefix + LINKS.changelog)">{{ n.more }}</a>
        <a class="ov-link" :href="RELEASE_URL" target="_blank" rel="noopener">{{ n.notes }}</a>
      </p>
    </div>
  </section>
</template>

<style scoped>
.head {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 24px;
  margin-bottom: 40px;
}
.big {
  flex-shrink: 0;
  font-family: var(--o-display);
  font-size: clamp(84px, 14vw, 168px);
  font-weight: 800;
  line-height: 0.8;
  letter-spacing: -0.06em;
  background: linear-gradient(160deg, var(--vp-c-brand-1), color-mix(in srgb, var(--o-cyan) 70%, transparent));
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
  opacity: 0.9;
}
@media (max-width: 767px) { .big { display: none; } }

.bento {
  display: grid;
  gap: 16px;
  margin: 0;
  padding: 0;
  list-style: none;
  perspective: 1200px;
}
@media (min-width: 700px) { .bento { grid-template-columns: repeat(2, minmax(0, 1fr)); } }
@media (min-width: 1000px) {
  .bento { grid-template-columns: repeat(3, minmax(0, 1fr)); }
  .cell.wide { grid-column: span 2; }
}

.cell {
  position: relative;
  margin: 0;
  overflow: hidden;
}
.cell:hover { border-color: color-mix(in srgb, var(--k) 45%, transparent); }
/* the pointer lights the card (Layout.vue sets --mx / --my) */
.cell::before {
  content: "";
  position: absolute;
  inset: 0;
  background: radial-gradient(360px circle at var(--mx, 50%) var(--my, -40%), color-mix(in srgb, var(--k) 18%, transparent), transparent 60%);
  opacity: 0;
  transition: opacity 0.3s;
  pointer-events: none;
}
.cell:hover::before { opacity: 1; }

.cell a {
  position: relative;
  display: flex;
  flex-direction: column;
  gap: 8px;
  height: 100%;
  padding: 24px;
  color: inherit;
  text-decoration: none;
}

.ic {
  display: grid;
  place-items: center;
  width: 46px;
  height: 46px;
  margin-bottom: 6px;
  border: 1px solid color-mix(in srgb, var(--k) 40%, transparent);
  border-radius: 14px;
  background: color-mix(in srgb, var(--k) 12%, transparent);
  color: var(--k);
  transition: transform 0.5s var(--o-spring);
}
.cell:hover .ic { transform: rotate(-8deg) scale(1.08); }
.ic svg { width: 22px; height: 22px; fill: none; stroke: currentColor; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }

.tag {
  font-family: var(--vp-font-family-mono);
  font-size: 11.5px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--k);
}
[dir="rtl"] .tag { font-family: var(--vp-font-family-base); letter-spacing: 0; font-size: 13px; }
h3 { margin: 0; font-family: var(--o-display); font-size: 21px; font-weight: 650; line-height: 1.25; letter-spacing: -0.02em; }
[dir="rtl"] h3 { letter-spacing: 0; line-height: 1.6; }
.cell p { margin: 0; color: var(--vp-c-text-2); font-size: 15px; line-height: 1.65; }
[dir="rtl"] .cell p { line-height: 1.95; }

.k-routing { --k: var(--vp-c-brand-1); }
.k-warp { --k: var(--o-oc); }
.k-test { --k: var(--o-good); }
.k-ipsec { --k: var(--o-ike); }
.k-certs { --k: var(--o-wg); }
.k-ports { --k: var(--o-l2tp); }

/* the wide card shows traffic splitting three ways */
.flow { width: 100%; height: 70px; margin-top: auto; padding-top: 12px; overflow: visible; }
[dir="rtl"] .flow { transform: scaleX(-1); }
.flow path { fill: none; stroke-width: 2.5; stroke-linecap: round; stroke-dasharray: 6 12; animation: dash 1.6s linear infinite; }
.f0 { stroke: var(--o-oc); }
.f1 { stroke: var(--vp-c-brand-1); animation-duration: 1.2s; }
.f2 { stroke: var(--o-wg); animation-duration: 2s; }
@keyframes dash { to { stroke-dashoffset: -36; } }

.links { display: flex; flex-wrap: wrap; align-items: center; gap: 20px; margin: 32px 0 0; }

@media (prefers-reduced-motion: reduce) {
  .flow path { animation: none; }
  .ic { transition: none; }
}
</style>

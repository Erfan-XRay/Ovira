<script setup lang="ts">
import { computed } from "vue";
import { withBase } from "vitepress";
import { fd, LINKS } from "./copy";
import { useCopy } from "./use";

const { fa, t, prefix } = useCopy();
const r = computed(() => t.value.resellers);
const num = (v: number | string) => (fa.value ? fd(v) : String(v));
const pct = (a: { used: number; pool: number }) => Math.round((a.used / a.pool) * 100);
</script>

<template>
  <section :id="r.id" class="ov-section resellers">
    <div class="ov-wrap">
      <header class="ov-head" data-reveal>
        <p class="ov-eyebrow">{{ r.n }}</p>
        <h2 class="ov-h2">{{ r.title }}</h2>
        <p class="ov-lede">{{ r.lede }}</p>
      </header>

      <div class="grid">
        <figure class="tree" data-reveal>
          <div class="owner ov-card">
            <span class="ring" aria-hidden="true" />
            <div>
              <b>{{ r.owner }}</b>
              <small>{{ r.ownerSub }}</small>
            </div>
          </div>
          <div class="bus" aria-hidden="true"><i /></div>
          <ul class="accts">
            <li v-for="a in r.accounts" :key="a.name" class="acct ov-card" :class="a.tone">
              <p class="nm ov-mono">{{ a.name }}</p>
              <div class="mh">
                <span>{{ r.pool }}</span>
                <b>{{ num(a.used) }} {{ r.of }} {{ num(a.pool) }} {{ fa ? "گیگابایت" : "GB" }}</b>
              </div>
              <div class="meter"><i :style="{ transform: `scaleX(${a.used / a.pool})` }" /></div>
              <p class="meta">
                <span>{{ num(a.clients) }} {{ r.clients }}</span>
                <span>{{ r.ends }} {{ a.end }}</span>
              </p>
              <p v-if="a.tone === 'bad'" class="flag bad">{{ r.paused }}</p>
              <p v-else-if="a.tone === 'warn'" class="flag warn">{{ num(pct(a)) }}{{ fa ? "٪" : "%" }} · {{ r.warn.replace(/^[^:]*: /, "") }}</p>
              <div class="people" aria-hidden="true">
                <i v-for="k in Math.min(a.clients, 12)" :key="k" :class="{ off: a.tone === 'bad' }" />
              </div>
            </li>
          </ul>
          <figcaption>{{ r.example }}</figcaption>
        </figure>

        <div class="facts" data-reveal>
          <ul>
            <li v-for="x in r.facts" :key="x">{{ x }}</li>
          </ul>
          <a class="ov-link" :href="withBase(prefix + LINKS.resellers)">{{ r.link }}</a>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.grid {
  display: grid;
  gap: 36px;
}
@media (min-width: 1000px) {
  .grid {
    grid-template-columns: minmax(0, 1.25fr) minmax(0, 1fr);
    gap: 56px;
    align-items: start;
  }
}

.tree {
  margin: 0;
}

.owner {
  display: flex;
  align-items: center;
  gap: 14px;
  width: max-content;
  max-width: 100%;
  margin: 0 auto;
  padding: 14px 22px;
}
.owner b {
  display: block;
  font-family: var(--o-display);
  font-size: 19px;
}
.owner small {
  color: var(--vp-c-text-2);
  font-size: 13.5px;
}
.ring {
  width: 28px;
  height: 28px;
  border: 6px solid var(--vp-c-brand-3);
  border-radius: 50%;
  background: var(--o-station);
  box-shadow: 0 0 14px var(--o-glow);
}

/* one trunk down, one bar across, a drop to each account: right angles only */
.bus {
  position: relative;
  height: 34px;
  margin: 0 auto;
}
.bus i {
  position: absolute;
  top: 0;
  bottom: 0;
  inset-inline-start: 50%;
  width: 4px;
  margin-inline-start: -2px;
  background: var(--vp-c-text-3);
}
.accts {
  position: relative;
  display: grid;
  gap: 14px;
  margin: 0;
  padding: 0;
  list-style: none;
}
@media (min-width: 700px) {
  .accts {
    grid-template-columns: repeat(3, minmax(0, 1fr));
    padding-top: 26px;
  }
  .accts::before {
    content: "";
    position: absolute;
    top: 0;
    inset-inline: calc(16.66% - 2px);
    height: 26px;
    border: 4px solid var(--vp-c-text-3);
    border-bottom: 0;
    border-radius: 14px 14px 0 0;
  }
  .accts::after {
    content: "";
    position: absolute;
    top: -34px;
    inset-inline-start: 50%;
    width: 4px;
    height: 34px;
    margin-inline-start: -2px;
    background: var(--vp-c-text-3);
  }
  .bus { display: none; }
  .tree { padding-top: 0; }
  .owner { margin-bottom: 34px; }
}
@media (max-width: 699px) {
  .accts {
    padding-inline-start: 22px;
    border-inline-start: 4px solid var(--vp-c-text-3);
    margin-inline-start: 18px;
  }
  .bus { display: none; }
  .owner { margin-inline: 0; margin-bottom: 16px; }
}

.acct {
  padding: 16px;
  --tone: var(--o-good);
}
.acct.warn { --tone: var(--o-warn); }
.acct.bad { --tone: var(--o-bad); }
.nm {
  margin: 0 0 10px;
  font-size: 14px;
  font-weight: 600;
}
.mh {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  gap: 4px 8px;
  font-size: 13px;
}
.mh span { color: var(--vp-c-text-2); }
.mh b { font-weight: 650; }
.meter {
  height: 8px;
  margin-top: 6px;
  overflow: hidden;
  border-radius: 4px;
  background: var(--o-line-strong);
}
.meter i {
  display: block;
  height: 100%;
  border-radius: 4px;
  background: var(--tone);
  transform-origin: left center;
}
[dir="rtl"] .meter i { transform-origin: right center; }
.meta {
  display: flex;
  justify-content: space-between;
  gap: 8px;
  margin: 10px 0 0;
  font-size: 13px;
  color: var(--vp-c-text-2);
}
.flag {
  margin: 10px 0 0;
  font-size: 13px;
  font-weight: 600;
  line-height: 1.5;
}
.flag.bad { color: var(--o-bad); }
.flag.warn { color: var(--o-warn); }
.people {
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
  margin-top: 12px;
}
.people i {
  width: 9px;
  height: 9px;
  border-radius: 50%;
  background: var(--tone);
}
.people i.off {
  background: transparent;
  border: 2px solid var(--o-bad);
}
figcaption {
  margin-top: 14px;
  font-size: 13px;
  text-align: center;
  color: var(--vp-c-text-2);
}

.facts ul {
  display: grid;
  gap: 14px;
  margin: 0 0 20px;
  padding: 0;
  list-style: none;
}
.facts li {
  position: relative;
  padding-inline-start: 26px;
  font-size: 16.5px;
  line-height: 1.7;
}
[dir="rtl"] .facts li { line-height: 2; }
.facts li::before {
  content: "";
  position: absolute;
  top: 0.6em;
  inset-inline-start: 0;
  width: 12px;
  height: 12px;
  border: 3px solid var(--vp-c-brand-3);
  border-radius: 50%;
  background: var(--o-station);
}
</style>

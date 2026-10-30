<script setup lang="ts">
import { computed } from "vue";
import { withBase } from "vitepress";
import { LINKS } from "./copy";
import { useCopy } from "./use";
import Ticket from "./Ticket.vue";

const { fa, t, prefix } = useCopy();
const s = computed(() => t.value.start);
const stepLinks = [LINKS.install, LINKS.nodes, LINKS.how];
</script>

<template>
  <section :id="s.id" class="ov-section start">
    <div class="ov-wrap">
      <header class="ov-head" data-reveal>
        <p class="ov-eyebrow">{{ s.n }}</p>
        <h2 class="ov-h2">{{ s.title }}</h2>
      </header>

      <ol class="steps">
        <li v-for="(st, i) in s.steps" :key="i" data-reveal>
          <span class="no" aria-hidden="true">{{ fa ? ["۱", "۲", "۳"][i] : i + 1 }}</span>
          <div class="body">
            <h3>{{ st.title }}</h3>
            <p>{{ st.text }}</p>
            <Ticket v-if="st.cmd" :cmd="st.cmd" :kicker="st.title" />
            <a class="ov-link" :href="withBase(prefix + stepLinks[i])">{{ st.link }}</a>
          </div>
        </li>
      </ol>

      <div class="plans" data-reveal>
        <div class="ph">
          <h3>{{ s.plansTitle }}</h3>
          <p>{{ s.plansLede }}</p>
        </div>
        <ul>
          <li v-for="p in s.plans" :key="p.name" class="ov-card">
            <b>{{ p.name }}</b>
            <span>{{ p.clients }}</span>
            <span>{{ p.nodes }}</span>
            <em>{{ p.price }}</em>
            <small v-if="'note' in p && p.note">{{ p.note }}</small>
          </li>
        </ul>
        <a class="ov-btn primary" :href="withBase(prefix + LINKS.plans)">{{ s.plansLink }}</a>
      </div>
    </div>
  </section>
</template>

<style scoped>
/* the three steps are stops on one vertical line */
.steps {
  position: relative;
  display: grid;
  gap: 36px;
  margin: 0;
  padding: 0;
  list-style: none;
}
.steps::before {
  content: "";
  position: absolute;
  top: 18px;
  bottom: 18px;
  inset-inline-start: 17px;
  width: 6px;
  margin-inline-start: -3px;
  border-radius: 3px;
  background: linear-gradient(var(--o-ovpn), var(--o-wg), var(--o-oc));
}
.steps li {
  position: relative;
  display: flex;
  gap: 24px;
}
.no {
  position: relative;
  z-index: 1;
  display: grid;
  flex: none;
  place-items: center;
  width: 36px;
  height: 36px;
  border: 4px solid var(--o-station-ink);
  border-radius: 50%;
  background: var(--o-station);
  font-family: var(--vp-font-family-mono);
  font-size: 15px;
  font-weight: 700;
}
[dir="rtl"] .no { font-family: var(--vp-font-family-base); }
.body { min-width: 0; padding-bottom: 6px; }
h3 {
  margin: 4px 0 6px;
  font-family: var(--o-display);
  font-size: 24px;
  font-weight: 650;
  letter-spacing: -0.025em;
}
[dir="rtl"] h3 { letter-spacing: 0; }
.body p, .ph p {
  max-width: 620px;
  margin: 0 0 14px;
  font-size: 16.5px;
  line-height: 1.7;
  color: var(--vp-c-text-2);
}
[dir="rtl"] .body p, [dir="rtl"] .ph p { line-height: 2; }
.body :deep(.ticket) { margin: 0 0 14px; }

.plans { margin-top: 84px; }
.ph h3 { margin-top: 0; }
.plans ul {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
  gap: 14px;
  margin: 18px 0 24px;
  padding: 0;
  list-style: none;
}
.plans li {
  display: grid;
  gap: 4px;
  padding: 18px 20px;
  font-size: 15px;
}
.plans b { font-family: var(--o-display); font-size: 20px; }
.plans span { color: var(--vp-c-text-2); }
.plans em { margin-top: 6px; font-style: normal; font-weight: 650; color: var(--vp-c-brand-1); }
.plans small { color: var(--vp-c-text-2); font-size: 13px; }
</style>

<script setup lang="ts">
import { withBase } from "vitepress";
import { INSTALL_CMD, LINKS } from "./copy";
import { useCopy } from "./use";
import Ticket from "./Ticket.vue";
import LineMap from "./LineMap.vue";
import VerticalMap from "./VerticalMap.vue";

const { t, prefix } = useCopy();
</script>

<template>
  <section class="hero ov-wrap">
    <div class="text">
      <p class="ov-eyebrow">{{ t.hero.eyebrow }}</p>
      <h1>{{ t.hero.title }}</h1>
      <p class="ov-lede">{{ t.hero.lede }}</p>
      <Ticket :cmd="INSTALL_CMD" :kicker="t.hero.ticketKicker" :stub="t.hero.ticketStub" :stub-sub="t.hero.ticketStubSub" :note="t.hero.ticketNote" />
      <div class="cta">
        <a class="ov-btn primary" :href="withBase(prefix + LINKS.install)">{{ t.hero.primary }}</a>
        <a class="ov-btn" :href="withBase(prefix + LINKS.how)">{{ t.hero.secondary }}</a>
      </div>
    </div>
    <div class="map">
      <div class="wide"><LineMap /></div>
      <div class="tall"><VerticalMap /></div>
    </div>
  </section>
</template>

<style scoped>
.hero {
  display: grid;
  gap: 40px;
  padding-top: 56px;
  padding-bottom: 40px;
}

.text {
  min-width: 0;
}

h1 {
  margin: 0;
  max-width: 14ch;
  font-family: var(--o-display);
  font-size: clamp(40px, 6.2vw, 68px);
  font-weight: 700;
  line-height: 1.02;
  letter-spacing: -0.045em;
  text-wrap: balance;
  color: var(--vp-c-text-1);
  animation: rise 1s var(--o-out) backwards;
}

[dir="rtl"] h1 {
  max-width: 16ch;
  line-height: 1.35;
  letter-spacing: 0;
}

.text > :deep(.ticket),
.cta {
  margin-top: 28px;
}

.text .ov-lede {
  animation: rise 1s var(--o-out) 0.12s backwards;
}

.text :deep(.ticket) {
  animation: rise 1s var(--o-out) 0.3s backwards;
}

.cta {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  animation: rise 1s var(--o-out) 0.42s backwards;
}

.map {
  min-width: 0;
}

.tall {
  display: none;
}

@keyframes rise {
  from {
    opacity: 0;
    transform: translateY(24px);
  }
}

@media (min-width: 1100px) {
  .hero {
    grid-template-columns: minmax(0, 480px) minmax(0, 1fr);
    align-items: center;
    gap: 32px;
    padding-top: 72px;
  }
}

@media (max-width: 639px) {
  .wide {
    display: none;
  }
  .tall {
    display: block;
  }
  .hero {
    padding-top: 36px;
  }
}
</style>

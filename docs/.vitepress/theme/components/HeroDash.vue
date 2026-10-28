<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from "vue";
import { useData } from "vitepress";

// An illustration of the panel: figures that count up, a chart that keeps
// moving, clients whose lamps light one by one. The numbers are made up.
const { lang } = useData();
const fa = computed(() => lang.value === "fa");

const text = computed(() =>
  fa.value
    ? {
        online: "آنلاین الان",
        active: "کاربران فعال",
        today: "ترافیک امروز",
        unit: "ترابایت",
        traffic: "ترافیک ۲۴ ساعت",
        node: "نود فرانکفورت ×۱٫۵",
        support: "پشتیبانی تلگرام",
        plan: "پلن پرو",
        status: "آنلاین",
      }
    : {
        online: "Online now",
        active: "Active clients",
        today: "Traffic today",
        unit: "TB",
        traffic: "Traffic, last 24 hours",
        node: "Node Frankfurt ×1.5",
        support: "Telegram support",
        plan: "Pro plan",
        status: "online",
      },
);

const fmt = (n: number, digits = 0) => n.toLocaleString(fa.value ? "fa-IR" : "en-US", { minimumFractionDigits: digits, maximumFractionDigits: digits });

const online = ref(0);
const active = ref(0);
const today = ref(0);
const bars = ref<number[]>(Array.from({ length: 24 }, () => 0));
const clients = [
  { name: "ali.mobile", left: 9, on: true },
  { name: "sara-laptop", left: 6, on: true },
  { name: "reza.home", left: 3, on: false },
];

const rnd = () => 0.18 + Math.random() * 0.78;
let timer: ReturnType<typeof setInterval> | undefined;
let frame = 0;

function tween(set: (v: number) => void, to: number, ms = 1700) {
  const t0 = performance.now();
  const step = (t: number) => {
    const p = Math.min(1, (t - t0) / ms);
    set(to * (1 - Math.pow(1 - p, 4)));
    if (p < 1) frame = requestAnimationFrame(step);
  };
  frame = requestAnimationFrame(step);
}

onMounted(() => {
  tween((v) => (online.value = Math.round(v)), 128);
  tween((v) => (active.value = Math.round(v)), 342);
  tween((v) => (today.value = v), 1.8);
  setTimeout(() => (bars.value = Array.from({ length: 24 }, (_, i) => Math.min(0.96, 0.22 + Math.sin(i / 3.2) * 0.2 + rnd() * 0.5))), 350);
  if (matchMedia("(prefers-reduced-motion: reduce)").matches) return;
  timer = setInterval(() => {
    bars.value = [...bars.value.slice(1), rnd()];
    online.value = Math.max(90, 128 + Math.round((Math.random() - 0.5) * 14));
  }, 2400);
});
onUnmounted(() => {
  if (timer) clearInterval(timer);
  cancelAnimationFrame(frame);
});
</script>

<template>
  <div class="dash-wrap" aria-hidden="true">
    <div class="dash glow">
      <div class="dash-top">
        <span class="dots"><i /><i /><i /></span>
        <span class="brand">
          <svg viewBox="0 0 32 32" width="20" height="20" class="mini">
            <rect width="32" height="32" rx="9" fill="var(--vp-c-brand-3)" />
            <circle class="ring" cx="16" cy="16" r="8.4" pathLength="1" fill="none" stroke="#0b1300" stroke-width="2.6" stroke-linecap="round" />
            <path class="v" d="M11.9 13.4 16 19.2l4.1-5.8" fill="none" stroke="#0b1300" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" />
          </svg>
          Ovira
        </span>
      </div>

      <div class="kpis">
        <div class="kpi first">
          <small>{{ text.online }}</small>
          <b>{{ fmt(online) }}</b>
        </div>
        <div class="kpi">
          <small>{{ text.active }}</small>
          <b>{{ fmt(active) }}</b>
        </div>
        <div class="kpi">
          <small>{{ text.today }}</small>
          <b>{{ fmt(today, 1) }}<em>{{ text.unit }}</em></b>
        </div>
      </div>

      <div class="chart">
        <small>{{ text.traffic }}</small>
        <div class="bars">
          <i v-for="(h, i) in bars" :key="i" :style="{ '--h': h, '--i': i }" />
        </div>
      </div>

      <ul class="rows">
        <li v-for="(c, r) in clients" :key="c.name" :style="{ '--r': r }">
          <span class="who">{{ c.name }}</span>
          <span class="lamps">
            <i v-for="n in 10" :key="n" :class="{ on: n <= c.left }" :style="{ '--i': n }" />
          </span>
          <span class="tag" :class="{ on: c.on }"><s />{{ c.on ? text.status : "—" }}</span>
        </li>
      </ul>
    </div>

    <span class="chip one">{{ text.node }}</span>
    <span class="chip two">{{ text.support }}</span>
    <span class="chip three">{{ text.plan }}</span>
  </div>
</template>

<style scoped>
.dash-wrap {
  position: relative;
  width: 100%;
  max-width: 560px;
  margin-inline: auto;
  padding: 18px 18px 26px;
  direction: ltr;
  animation: enter 1.1s var(--o-out) 0.25s backwards;
}

.dash {
  position: relative;
  overflow: hidden;
  padding: 14px 16px 16px;
  border: 1px solid var(--o-line);
  border-radius: 22px;
  background: var(--o-glass);
  box-shadow: inset 0 1px 0 var(--o-edge), 0 50px 90px -40px var(--o-shadow);
  backdrop-filter: blur(18px);
  transform: perspective(1200px) rotateY(-5deg) rotateX(3deg);
  transition: transform 0.9s var(--o-out);
}

.dash-wrap:hover .dash {
  transform: perspective(1200px) rotateY(0) rotateX(0);
}

.dash-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}

.dots {
  display: inline-flex;
  gap: 6px;
}

.dots i {
  width: 9px;
  height: 9px;
  border-radius: 50%;
  background: var(--o-line-strong);
}

.dots i:first-child {
  background: var(--vp-c-brand-3);
  box-shadow: 0 0 10px var(--vp-c-brand-3);
}

.brand {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-family: var(--o-display);
  font-weight: 700;
  font-size: 15px;
  letter-spacing: -0.03em;
}

.mini .ring {
  stroke-dasharray: 1;
  stroke-dashoffset: 1;
  transform-box: fill-box;
  transform-origin: center;
  transform: rotate(-90deg);
  animation: draw 1.2s var(--o-out) 0.6s forwards;
}

.mini .v {
  transform-box: fill-box;
  transform-origin: center;
  animation: v-in 0.7s var(--o-spring) 1.2s backwards;
}

.kpis {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  border: 1px solid var(--o-line);
  border-radius: 14px;
  overflow: hidden;
}

.kpi {
  display: grid;
  gap: 2px;
  padding: 10px 12px 12px;
}

.kpi + .kpi {
  border-inline-start: 1px solid var(--o-line);
}

.kpi small,
.chart small {
  font-family: var(--vp-font-family-mono);
  font-size: 9.5px;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--vp-c-text-3);
}

.kpi b {
  font-family: var(--o-display);
  font-size: 28px;
  font-weight: 600;
  line-height: 1.1;
  letter-spacing: -0.04em;
  font-variant-numeric: tabular-nums;
}

.kpi b em {
  margin-inline-start: 4px;
  font-family: var(--vp-font-family-base);
  font-size: 11px;
  font-style: normal;
  font-weight: 560;
  letter-spacing: 0;
  color: var(--vp-c-text-2);
}

.kpi.first b {
  color: var(--vp-c-brand-1);
  filter: drop-shadow(0 0 14px var(--o-glow));
}

.chart {
  display: grid;
  gap: 8px;
  margin-top: 12px;
  padding: 12px 12px 10px;
  border: 1px solid var(--o-line);
  border-radius: 14px;
}

.bars {
  display: flex;
  align-items: flex-end;
  gap: 4px;
  height: 92px;
}

.bars i {
  flex: 1;
  height: calc(var(--h) * 100%);
  border-radius: 3px 3px 1px 1px;
  background: linear-gradient(to top, color-mix(in srgb, var(--vp-c-brand-3) 40%, transparent), var(--vp-c-brand-3));
  transition: height 1.2s var(--o-out);
  transition-delay: calc(var(--i) * 18ms);
}

.bars i:nth-child(3n) {
  background: linear-gradient(to top, color-mix(in srgb, var(--o-cyan) 40%, transparent), var(--o-cyan));
}

.rows {
  list-style: none;
  margin: 12px 0 0;
  padding: 0;
  display: grid;
  gap: 8px;
}

.rows li {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto auto;
  align-items: center;
  gap: 14px;
  padding: 9px 12px;
  border: 1px solid var(--o-line);
  border-radius: 12px;
  font-size: 13px;
  animation: rise 0.8s var(--o-out) backwards;
  animation-delay: calc(var(--r) * 120ms + 900ms);
}

.who {
  font-weight: 650;
}

.lamps {
  display: inline-flex;
  gap: 3px;
}

.lamps i {
  width: 5px;
  height: 12px;
  border-radius: 2px;
  background: var(--o-unlit);
  animation: lamp 0.6s var(--o-spring) backwards;
  animation-delay: calc(var(--i) * 45ms + 1300ms);
}

.lamps i.on {
  background: var(--vp-c-brand-3);
  box-shadow: 0 0 8px -1px var(--o-glow);
}

.tag {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  min-width: 62px;
  justify-content: flex-end;
  font-family: var(--vp-font-family-mono);
  font-size: 10.5px;
  color: var(--vp-c-text-3);
}

.tag s {
  position: relative;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--o-unlit);
}

.tag.on {
  color: var(--o-good);
}

.tag.on s {
  background: var(--o-good);
}

.tag.on s::after {
  content: "";
  position: absolute;
  inset: 0;
  border-radius: 50%;
  background: var(--o-good);
  animation: ripple 2s ease-out infinite;
}

.chip {
  position: absolute;
  padding: 7px 14px;
  border: 1px solid var(--o-line-strong);
  border-radius: 999px;
  background: var(--o-glass);
  box-shadow: 0 18px 40px -18px var(--o-shadow);
  backdrop-filter: blur(14px);
  font-size: 12px;
  font-weight: 650;
  white-space: nowrap;
  animation: float 7s ease-in-out infinite, enter 1s var(--o-out) 1.1s backwards;
}

.one {
  top: 0;
  inset-inline-end: 0;
}

.two {
  bottom: 8px;
  inset-inline-start: 0;
  animation-delay: -2.4s, 1.3s;
}

.three {
  top: 46%;
  inset-inline-end: -6px;
  animation-delay: -4.6s, 1.5s;
}

@keyframes enter {
  from {
    opacity: 0;
    transform: translateY(40px) scale(0.96);
  }
}

@keyframes rise {
  from {
    opacity: 0;
    transform: translateY(14px);
  }
}

@keyframes draw {
  to {
    stroke-dashoffset: 0;
  }
}

@keyframes v-in {
  from {
    opacity: 0;
    transform: translateY(-7px) scale(0.4);
  }
}

@keyframes lamp {
  from {
    opacity: 0;
    transform: scaleY(0.2);
  }
}

@keyframes ripple {
  from {
    transform: scale(1);
    opacity: 0.7;
  }
  to {
    transform: scale(3.4);
    opacity: 0;
  }
}

@keyframes float {
  50% {
    transform: translateY(-9px);
  }
}

@media (max-width: 640px) {
  .dash-wrap {
    padding: 18px 0 26px;
  }

  .dash {
    padding: 12px;
    transform: none;
  }

  .kpi {
    padding: 10px 8px;
  }

  .kpi small {
    font-family: var(--vp-font-family-base);
    font-size: 11px;
    letter-spacing: 0;
  }

  .rows li {
    gap: 8px;
    padding: 9px 8px;
  }

  .who {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .lamps {
    gap: 2px;
  }

  .lamps i {
    width: 3px;
  }

  .chip.three {
    display: none;
  }

  .kpi b {
    font-size: 22px;
  }
}

@media (prefers-reduced-motion: reduce) {
  .dash {
    transform: none;
  }
}
</style>

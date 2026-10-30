<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from "vue";
import { NODE_CMD } from "./copy";
import { mx, roundedPath, useCopy, useLive } from "./use";

const W = 900;
const H = 360;
const { fa, t } = useCopy();
const f = computed(() => t.value.fleet);
const X = (x: number) => mx(x, W, fa.value);
type Pt = [number, number];
const P = (pts: Pt[], r = 22) => roundedPath(pts.map(([x, y]) => [X(x), y] as Pt), r);

const root = ref<HTMLElement>();
const stage = ref<HTMLElement>();
const zoom = ref<SVGGElement>();
const relay = ref<SVGGElement>();
const node2 = ref<SVGGElement>();
const step = ref(0);
const pinned = ref(false);
const { live, reduced } = useLive(root);

const mgmt1 = computed(() => P([[120, 170], [200, 170], [260, 110], [460, 110]]));
const mgmt2 = computed(() => P([[120, 170], [200, 170], [280, 250], [460, 250]]));
const cust1 = computed(() => P([[460, 110], [830, 110]]));
const cust2 = computed(() => P([[460, 250], [830, 250]]));

let cleanup: (() => void) | undefined;

onMounted(async () => {
  const [{ gsap }, { ScrollTrigger }] = await Promise.all([import("gsap"), import("gsap/ScrollTrigger")]);
  gsap.registerPlugin(ScrollTrigger);
  if (!stage.value || !zoom.value) return;
  const g = gsap.context(() => {
    const mm = gsap.matchMedia();
    mm.add("(min-width: 900px) and (prefers-reduced-motion: no-preference)", () => {
      pinned.value = true;
      const view = (cx: number, cy: number, s: number) => ({ x: W / 2 - s * X(cx), y: H / 2 - s * cy, scale: s });
      gsap.set(zoom.value!, { svgOrigin: "0 0", ...view(290, 140, 1.55) });
      gsap.set([relay.value!, node2.value!], { autoAlpha: 0 });
      const tl = gsap.timeline({
        defaults: { ease: "power2.inOut" },
        scrollTrigger: {
          trigger: stage.value!,
          start: "top 84px",
          end: "+=1500",
          pin: true,
          scrub: 0.7,
          anticipatePin: 1,
          invalidateOnRefresh: true,
          onUpdate: (self) => {
            const p = self.progress;
            step.value = p < 0.33 ? 0 : p < 0.66 ? 1 : 2;
          },
        },
      });
      tl.to({}, { duration: 0.8 })
        .to(zoom.value!, { ...view(580, 120, 1.6), duration: 0.9 })
        .to(relay.value!, { autoAlpha: 1, duration: 0.5 }, "<0.3")
        .to({}, { duration: 0.5 })
        .to(zoom.value!, { ...view(470, 200, 1.35), duration: 0.9 })
        .to(node2.value!, { autoAlpha: 1, duration: 0.6 }, "<0.3")
        .to({}, { duration: 0.6 })
        .to(zoom.value!, { ...view(450, 180, 1), duration: 0.8 });
      return () => {
        pinned.value = false;
        step.value = 0;
      };
    });
  }, stage.value);
  document.fonts?.ready.then(() => ScrollTrigger.refresh());
  cleanup = () => {
    g.revert();
  };
});
onUnmounted(() => cleanup?.());

const run = computed(() => live.value && !reduced.value);
</script>

<template>
  <section :id="f.id" ref="root" class="ov-section fleet">
    <div class="ov-wrap">
      <header class="ov-head" data-reveal>
        <p class="ov-eyebrow">{{ f.n }}</p>
        <h2 class="ov-h2">{{ f.title }}</h2>
        <p class="ov-lede">{{ f.lede }}</p>
      </header>

      <div ref="stage" class="stage" :class="{ pinned }">
        <ol class="steps">
          <li v-for="(s, i) in f.steps" :key="i" :class="{ on: !pinned || step === i }">
            <span class="no" aria-hidden="true">{{ fa ? ["۱", "۲", "۳"][i] : i + 1 }}</span>
            <div>
              <h3>{{ s.title }}</h3>
              <p>{{ s.text }}</p>
              <code v-if="i === 2" class="cmd" dir="ltr">{{ NODE_CMD }}</code>
            </div>
          </li>
        </ol>

        <div class="fig ov-card" :class="{ run }" tabindex="0" role="group" :aria-label="f.title">
          <svg :viewBox="`0 0 ${W} ${H}`" role="img" :aria-label="f.label" preserveAspectRatio="xMidYMid meet">
            <g ref="zoom" class="zoom">
              <g class="mgmt">
                <path :d="mgmt1" class="ml" />
                <text :x="X(330)" y="94" class="lab">{{ f.scene.mgmt }}</text>
              </g>

              <g class="cust c-ovpn">
                <path :d="cust1" class="cl" />
                <circle v-for="k in 2" :key="'a' + k" r="5" class="tr" :style="{ offsetPath: `path('${cust1}')`, animationDelay: `${-k * 1.9}s`, animationDirection: k === 1 ? 'normal' : 'reverse' }" />
              </g>

              <g ref="node2" class="n2">
                <path :d="mgmt2" class="ml" />
                <g class="cust c-wg">
                  <path :d="cust2" class="cl" />
                  <circle r="5" class="tr" :style="{ offsetPath: `path('${cust2}')`, animationDelay: '-1s' }" />
                </g>
                <circle :cx="X(460)" cy="250" r="11" class="dot" />
                <text :x="X(460)" y="224" class="name mono">{{ f.scene.node2 }}</text>
                <g class="cmdbox">
                  <rect :x="X(500) - (fa ? 190 : 0)" y="262" width="190" height="30" rx="8" />
                  <text :x="X(500) + (fa ? -95 : 95)" y="282" class="mono">{{ f.scene.cmd }}</text>
                </g>
              </g>

              <circle :cx="X(460)" cy="110" r="11" class="dot" />
              <text :x="X(460)" y="82" class="name mono">{{ f.scene.node1 }}</text>

              <g ref="relay" class="rl">
                <rect :x="X(640) - 9" y="86" width="18" height="48" rx="9" class="cap" />
                <text :x="X(640)" y="76" class="name mono">{{ f.scene.relay }}</text>
                <text :x="X(550)" y="138" class="lab">{{ f.scene.tunnel }}</text>
              </g>

              <g class="cl2">
                <circle :cx="X(850)" cy="104" r="6" class="cu" />
                <circle :cx="X(862)" cy="118" r="6" class="cu" />
                <circle :cx="X(850)" cy="250" r="6" class="cu" />
                <text :x="X(850)" y="184" class="name">{{ f.scene.customers }}</text>
              </g>

              <g class="pn">
                <circle :cx="X(90)" cy="170" r="30" class="ring" />
                <circle :cx="X(90)" cy="170" r="9" class="core" />
                <text :x="X(90)" y="222" class="name">{{ f.scene.panel }}</text>
              </g>
            </g>
          </svg>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.stage {
  display: grid;
  gap: 28px;
}

.steps {
  display: grid;
  gap: 18px;
  margin: 0;
  padding: 0;
  list-style: none;
  align-content: center;
}

.steps li {
  display: flex;
  gap: 16px;
  padding: 18px 20px;
  border: 1px solid var(--o-line);
  border-radius: 18px;
  background: var(--o-glass);
  transition: opacity 0.4s, border-color 0.4s, transform 0.5s var(--o-out);
}

.pinned .steps li:not(.on) {
  opacity: 0.4;
}
.pinned .steps li:not(.on) p,
.pinned .steps li:not(.on) .cmd {
  display: none;
}
.pinned .steps li.on {
  border-color: color-mix(in srgb, var(--vp-c-brand-3) 55%, var(--o-line));
  transform: translateX(6px);
}
[dir="rtl"] .pinned .steps li.on {
  transform: translateX(-6px);
}

.no {
  display: grid;
  flex: none;
  place-items: center;
  width: 32px;
  height: 32px;
  border: 3px solid var(--vp-c-brand-3);
  border-radius: 50%;
  background: var(--o-station);
  font-family: var(--vp-font-family-mono);
  font-size: 14px;
  font-weight: 700;
}
[dir="rtl"] .no { font-family: var(--vp-font-family-base); }

h3 {
  margin: 2px 0 6px;
  font-family: var(--o-display);
  font-size: 20px;
  font-weight: 650;
  letter-spacing: -0.02em;
}
[dir="rtl"] h3 { letter-spacing: 0; }
p {
  margin: 0;
  font-size: 15.5px;
  line-height: 1.7;
  color: var(--vp-c-text-2);
}
[dir="rtl"] p { line-height: 1.95; }

.cmd {
  display: block;
  margin-top: 10px;
  padding: 10px 12px;
  border: 1px solid var(--o-line);
  border-radius: 10px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  font-family: var(--vp-font-family-mono);
  font-size: 12px;
  line-height: 1.55;
  overflow-wrap: anywhere;
}

.fig {
  overflow-x: auto;
  overflow-y: hidden;
  padding: 0;
}
.fig svg {
  display: block;
  width: 100%;
  min-width: 640px;
  height: auto;
}

@media (min-width: 900px) {
  .stage {
    grid-template-columns: minmax(0, 380px) minmax(0, 1fr);
    gap: 36px;
    align-items: center;
    min-height: 460px;
  }
}

.ml {
  fill: none;
  stroke: var(--vp-c-text-2);
  stroke-width: 4;
  stroke-linecap: round;
  stroke-linejoin: round;
  stroke-dasharray: 3 11;
}
.run .ml {
  animation: flow 1.4s linear infinite;
}
.cl {
  fill: none;
  stroke: currentColor;
  stroke-width: 9;
  stroke-linecap: round;
}
.tr {
  fill: var(--vp-c-text-1);
  stroke: currentColor;
  stroke-width: 3;
  offset-rotate: 0deg;
  animation: go 4.2s linear infinite paused;
}
.run .tr {
  animation-play-state: running;
}
.dot {
  fill: var(--o-station);
  stroke: var(--o-station-ink);
  stroke-width: 4.5;
}
.cap {
  fill: var(--o-station);
  stroke: var(--o-station-ink);
  stroke-width: 4;
}
.ring {
  fill: var(--o-station);
  stroke: var(--vp-c-brand-3);
  stroke-width: 6;
}
.core { fill: var(--vp-c-brand-3); }
.cu { fill: var(--vp-c-text-2); }
.name {
  fill: var(--vp-c-text-1);
  font-family: var(--vp-font-family-base);
  font-size: 16px;
  font-weight: 650;
  text-anchor: middle;
}
.name.mono {
  font-family: var(--vp-font-family-mono);
  font-size: 14px;
  font-weight: 500;
}
.lab {
  fill: var(--vp-c-text-2);
  font-family: var(--vp-font-family-base);
  font-size: 13.5px;
  text-anchor: middle;
}
.cmdbox rect {
  fill: var(--vp-c-bg-elv);
  stroke: var(--o-line-strong);
}
.cmdbox text {
  fill: var(--vp-c-text-1);
  font-size: 13px;
  text-anchor: middle;
}

@keyframes flow { to { stroke-dashoffset: -28; } }
@keyframes go { from { offset-distance: 0%; } to { offset-distance: 100%; } }

@media (prefers-reduced-motion: reduce) {
  .ml { animation: none; }
  .tr { display: none; }
  .steps li { transition: none; }
}
</style>

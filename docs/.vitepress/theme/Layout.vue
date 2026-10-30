<script setup lang="ts">
import DefaultTheme from "vitepress/theme";
import { useData, useRoute } from "vitepress";
import { nextTick, onMounted, onUnmounted, ref, watch } from "vue";
import Ambient from "./components/Ambient.vue";
import Landing from "./landing/Landing.vue";

const { Layout } = DefaultTheme;
const route = useRoute();
const { frontmatter } = useData();
const progress = ref(0);

let io: IntersectionObserver | undefined;
let raf = 0;
let ev: PointerEvent | null = null;

// Cards fade up the first time they scroll into view.
function observe() {
  nextTick(() => {
    if (!io) return;
    document.querySelectorAll<HTMLElement>(".VPFeature:not([data-seen])").forEach((el, i) => {
      el.dataset.seen = "";
      el.style.setProperty("--d", `${(i % 3) * 90}ms`);
      el.classList.add("will-reveal");
      io!.observe(el);
    });
  });
}

function onScroll() {
  const h = document.documentElement;
  const max = h.scrollHeight - h.clientHeight;
  progress.value = max > 0 ? Math.min(1, h.scrollTop / max) : 0;
}

// The pointer position lights the grid and the card under it.
function frame() {
  raf = 0;
  if (!ev) return;
  const root = document.documentElement;
  root.style.setProperty("--cx", ev.clientX + "px");
  root.style.setProperty("--cy", ev.clientY + "px");
  const card = (ev.target as Element | null)?.closest?.<HTMLElement>(".VPFeature, .glow");
  if (card) {
    const r = card.getBoundingClientRect();
    card.style.setProperty("--mx", ev.clientX - r.left + "px");
    card.style.setProperty("--my", ev.clientY - r.top + "px");
  }
}
function onMove(e: PointerEvent) {
  ev = e;
  document.documentElement.dataset.pointer = "on";
  if (!raf) raf = requestAnimationFrame(frame);
}

onMounted(() => {
  io = new IntersectionObserver(
    (entries) =>
      entries.forEach((e) => {
        if (e.isIntersecting) {
          e.target.classList.add("is-in");
          io!.unobserve(e.target);
        }
      }),
    { threshold: 0.15 },
  );
  observe();
  onScroll();
  window.addEventListener("scroll", onScroll, { passive: true });
  if (matchMedia("(pointer: fine)").matches && !matchMedia("(prefers-reduced-motion: reduce)").matches) {
    window.addEventListener("pointermove", onMove, { passive: true });
  }
});
onUnmounted(() => {
  io?.disconnect();
  window.removeEventListener("scroll", onScroll);
  window.removeEventListener("pointermove", onMove);
  if (raf) cancelAnimationFrame(raf);
});
watch(() => route.path, observe);
</script>

<template>
  <Layout>
    <template #layout-top>
      <Ambient />
      <div class="progress" :style="{ transform: `scaleX(${progress})` }" aria-hidden="true" />
    </template>
    <template #home-hero-before>
      <Landing v-if="frontmatter.landing" />
    </template>
  </Layout>
</template>

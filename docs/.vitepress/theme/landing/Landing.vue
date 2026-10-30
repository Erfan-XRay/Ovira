<script setup lang="ts">
import { onMounted, onUnmounted, ref } from "vue";
import "./landing.css";
import Hero from "./Hero.vue";
import Ways from "./Ways.vue";
import Life from "./Life.vue";
import Fleet from "./Fleet.vue";
import Resellers from "./Resellers.vue";
import Phone from "./Phone.vue";
import Start from "./Start.vue";

const root = ref<HTMLElement>();
const armed = ref(false);
let io: IntersectionObserver | undefined;

// Sections fade up the first time they come into view. Nothing is hidden
// until this script has run, so the page also reads without it.
onMounted(() => {
  io = new IntersectionObserver(
    (entries) =>
      entries.forEach((e) => {
        if (e.isIntersecting) {
          e.target.classList.add("is-in");
          io!.unobserve(e.target);
        }
      }),
    { threshold: 0.12, rootMargin: "0px 0px -6% 0px" },
  );
  root.value?.querySelectorAll("[data-reveal]").forEach((el) => io!.observe(el));
  armed.value = true;
});
onUnmounted(() => io?.disconnect());
</script>

<template>
  <div ref="root" class="ov" :class="{ armed }">
    <Hero />
    <Ways />
    <Life />
    <Fleet />
    <Resellers />
    <Phone />
    <Start />
  </div>
</template>

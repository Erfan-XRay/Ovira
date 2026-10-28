<script setup lang="ts">
import { computed, ref } from "vue";
import { useData } from "vitepress";

const { lang } = useData();
const fa = computed(() => lang.value === "fa");
const cmd = "bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/install.sh)";
const done = ref(false);

async function copy() {
  try {
    await navigator.clipboard.writeText(cmd);
    done.value = true;
    setTimeout(() => (done.value = false), 1600);
  } catch {
    /* clipboard blocked */
  }
}
</script>

<template>
  <div class="install glow">
    <div class="line">
      <span class="prompt" aria-hidden="true">$</span>
      <code class="cmd" dir="ltr"><span class="type">{{ cmd }}</span></code>
      <button type="button" class="copy" :class="{ done }" :aria-label="fa ? 'کپی دستور' : 'Copy command'" @click="copy">
        <svg v-if="!done" viewBox="0 0 24 24" aria-hidden="true"><rect x="9" y="9" width="11" height="11" rx="2.5" /><path d="M5 15V6a2 2 0 0 1 2-2h9" /></svg>
        <svg v-else viewBox="0 0 24 24" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5" /></svg>
        <span>{{ done ? (fa ? "کپی شد" : "Copied") : fa ? "کپی" : "Copy" }}</span>
      </button>
    </div>
    <p class="hint">{{ fa ? "روی Debian، Ubuntu، AlmaLinux و Rocky، با دسترسی root. تا یک دقیقه." : "Debian, Ubuntu, AlmaLinux and Rocky, as root. Takes about a minute." }}</p>
  </div>
</template>

<style scoped>
.install {
  position: relative;
  margin-top: 28px;
  max-width: 640px;
  padding: 12px 12px 12px 16px;
  border: 1px solid var(--o-line-strong);
  border-radius: 16px;
  background: var(--o-glass);
  box-shadow: inset 0 1px 0 var(--o-edge), 0 24px 50px -30px var(--o-shadow);
  backdrop-filter: blur(14px);
  animation: rise 1s var(--o-out) 0.7s backwards;
}

.line {
  display: flex;
  align-items: center;
  gap: 12px;
  direction: ltr;
}

.prompt {
  color: var(--vp-c-brand-1);
  font-family: var(--vp-font-family-mono);
  font-weight: 700;
}

.cmd {
  flex: 1;
  min-width: 0;
  overflow: hidden;
  white-space: nowrap;
  background: none;
  color: var(--vp-c-text-1);
  font-family: var(--vp-font-family-mono);
  font-size: 13px;
}

/* typed out once, with a caret */
.type {
  display: inline-block;
  max-width: 100%;
  overflow: hidden;
  vertical-align: bottom;
  white-space: nowrap;
  border-inline-end: 2px solid var(--vp-c-brand-1);
  animation: type 2.4s steps(78, end) 1.1s backwards, caret 0.9s step-end 1.1s 4, caret-off 0s 5s forwards;
}

.copy {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  height: 34px;
  padding: 0 14px;
  border: 1px solid var(--o-line-strong);
  border-radius: 10px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.4s var(--o-spring), border-color 0.2s, background 0.2s;
}

.copy:hover {
  transform: translateY(-1px);
  border-color: var(--vp-c-brand-3);
}

.copy:active {
  transform: scale(0.96);
}

.copy.done {
  border-color: var(--vp-c-brand-3);
  background: var(--vp-c-brand-soft);
}

.copy svg {
  width: 16px;
  height: 16px;
  fill: none;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
}

.copy.done svg path {
  stroke-dasharray: 24;
  animation: tick 0.4s var(--o-out);
}

.hint {
  margin: 8px 0 0;
  font-size: 12.5px;
  color: var(--vp-c-text-3);
}

@keyframes type {
  from {
    max-width: 0;
  }
}

@keyframes caret {
  50% {
    border-color: transparent;
  }
}

@keyframes caret-off {
  to {
    border-color: transparent;
  }
}

@keyframes tick {
  from {
    stroke-dashoffset: 24;
  }
}

@keyframes rise {
  from {
    opacity: 0;
    transform: translateY(18px);
  }
}

@media (max-width: 640px) {
  .copy span {
    display: none;
  }

  .copy {
    padding: 0 10px;
  }
}

@media (prefers-reduced-motion: reduce) {
  .type {
    animation: none;
    border: 0;
  }
}
</style>

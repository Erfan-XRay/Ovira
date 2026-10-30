<script setup lang="ts">
import { onUnmounted, ref } from "vue";
import { useCopy } from "./use";

const props = defineProps<{ cmd: string; kicker: string; stub?: string; stubSub?: string; note?: string }>();
const { t } = useCopy();
const done = ref(false);
const failed = ref(false);
let timer: ReturnType<typeof setTimeout> | undefined;

async function copy() {
  if (timer) clearTimeout(timer);
  failed.value = false;
  try {
    await navigator.clipboard.writeText(props.cmd);
    done.value = true;
    timer = setTimeout(() => (done.value = false), 1800);
  } catch {
    failed.value = true;
  }
}
onUnmounted(() => timer && clearTimeout(timer));
</script>

<template>
  <div class="ticket">
    <div v-if="stub" class="stub" aria-hidden="true">
      <span class="stub-k">{{ stub }}</span>
      <span v-if="stubSub" class="stub-s">{{ stubSub }}</span>
    </div>
    <div class="main">
      <p class="kicker">{{ kicker }}</p>
      <div class="row">
        <span class="prompt" aria-hidden="true">$</span>
        <code class="cmd" dir="ltr">{{ cmd }}</code>
        <button type="button" class="copy" :class="{ done }" :aria-label="t.hero.copyLabel" @click="copy">
          <svg v-if="!done" viewBox="0 0 24 24" aria-hidden="true"><rect x="9" y="9" width="11" height="11" rx="2.5" /><path d="M5 15V6a2 2 0 0 1 2-2h9" /></svg>
          <svg v-else viewBox="0 0 24 24" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5" /></svg>
          <span>{{ done ? t.hero.copied : t.hero.copy }}</span>
        </button>
      </div>
      <p v-if="note" class="note">{{ note }}</p>
      <p class="note" role="status">{{ failed ? t.hero.copyFailed : done ? t.hero.copiedStatus : "" }}</p>
    </div>
  </div>
</template>

<style scoped>
.ticket {
  --stub: 96px;
  position: relative;
  display: flex;
  max-width: 660px;
  overflow: hidden;
  border: 1px solid var(--o-line-strong);
  border-radius: 18px;
  background: var(--o-glass);
  box-shadow: inset 0 1px 0 var(--o-edge), 0 26px 50px -30px var(--o-shadow);
  backdrop-filter: blur(14px);
}

.stub {
  position: relative;
  display: flex;
  flex: 0 0 var(--stub);
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  padding: 14px 8px;
  border-inline-end: 2px dashed var(--o-line-strong);
  background: linear-gradient(160deg, var(--vp-c-brand-soft), transparent);
  text-align: center;
}

/* the two punched notches on the perforation */
.stub::before,
.stub::after {
  content: "";
  position: absolute;
  inset-inline-end: -10px;
  width: 18px;
  height: 18px;
  border: 1px solid var(--o-line-strong);
  border-radius: 50%;
  background: var(--vp-c-bg);
}
.stub::before { top: -10px; }
.stub::after { bottom: -10px; }

.stub-k {
  font-family: var(--o-display);
  font-size: 19px;
  font-weight: 700;
  color: var(--vp-c-brand-1);
}

.stub-s {
  font-family: var(--vp-font-family-mono);
  font-size: 11px;
  color: var(--vp-c-text-2);
}

[dir="rtl"] .stub-s { font-family: var(--vp-font-family-base); font-size: 12px; }

.main {
  flex: 1;
  min-width: 0;
  padding: 14px 14px 12px 18px;
}

[dir="rtl"] .main { padding: 14px 18px 12px 14px; }

.kicker {
  margin: 0 0 8px;
  font-family: var(--vp-font-family-mono);
  font-size: 11.5px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--vp-c-text-2);
}

[dir="rtl"] .kicker { font-family: var(--vp-font-family-base); font-size: 13px; letter-spacing: 0; }

.row {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  direction: ltr;
}

.prompt {
  padding-top: 11px;
  color: var(--vp-c-brand-1);
  font-family: var(--vp-font-family-mono);
  font-weight: 700;
}

.cmd {
  flex: 1;
  min-width: 0;
  padding: 11px 0;
  background: none;
  color: var(--vp-c-text-1);
  font-family: var(--vp-font-family-mono);
  font-size: 12.5px;
  line-height: 1.55;
  overflow-wrap: anywhere;
  user-select: all;
}

.copy {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  flex-shrink: 0;
  min-width: 44px;
  height: 44px;
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

.copy:hover { transform: translateY(-1px); border-color: var(--vp-c-brand-3); }
.copy:active { transform: scale(0.96); }
.copy.done { border-color: var(--vp-c-brand-3); background: var(--vp-c-brand-soft); }

.copy svg {
  width: 16px;
  height: 16px;
  fill: none;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
}

.note {
  margin: 4px 0 0;
  min-height: 1em;
  font-size: 12.5px;
  line-height: 1.6;
  color: var(--vp-c-text-2);
}

@media (max-width: 520px) {
  .ticket { --stub: 64px; }
  .stub-k { font-size: 15px; }
  .stub-s { display: none; }
  .copy span { display: none; }
  .copy { padding: 0 10px; }
}
</style>

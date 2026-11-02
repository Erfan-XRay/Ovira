<script setup lang="ts">
import { computed } from "vue";
import { useData } from "vitepress";

const props = withDefaults(
  defineProps<{
    method: string;
    path: string;
    perm?: string;
    token?: boolean | null;
  }>(),
  { perm: "", token: true },
);

const { lang } = useData();
const fa = computed(() => lang.value.toLowerCase().startsWith("fa"));
const method = computed(() => props.method.toUpperCase());
const label = computed(() => `${method.value} ${props.path}`);
const permLabel = computed(() => (fa.value ? "دسترسی" : "permission"));
const sessionLabel = computed(() => (fa.value ? "فقط نشست" : "session only"));
</script>

<template>
  <div class="ov-endpoint" role="group" :aria-label="label">
    <span class="ov-method" :class="`is-${method.toLowerCase()}`">{{ method }}</span>
    <code class="ov-path" dir="ltr">{{ path }}</code>
    <span v-if="perm" class="ov-chip ov-perm">
      <span class="ov-chip-label">{{ permLabel }}</span>
      <code dir="ltr">{{ perm }}</code>
    </span>
    <span v-if="token === false" class="ov-chip ov-session">{{ sessionLabel }}</span>
  </div>
</template>

<style scoped>
.ov-endpoint {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 7px 9px;
  max-width: 100%;
  min-width: 0;
  margin: 26px 0 12px;
  padding: 10px 12px;
  border: 1px solid var(--o-line);
  border-radius: 12px;
  background: var(--vp-c-bg-soft);
  box-shadow: inset 0 1px 0 var(--o-edge);
}

.ov-method {
  flex: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 4.4em;
  min-height: 26px;
  padding: 2px 9px;
  border: 1px solid transparent;
  border-radius: 8px;
  font-family: var(--vp-font-family-mono);
  font-size: 11.5px;
  font-weight: 600;
  letter-spacing: 0.06em;
  line-height: 1.4;
}

.ov-method.is-get {
  color: #05505a;
  background: #d7f4f8;
  border-color: #8bd9e4;
}

.ov-method.is-post {
  color: #2f5b00;
  background: #e6f8c8;
  border-color: #b7e27a;
}

.ov-method.is-put {
  color: #6b4a00;
  background: #fdf0cc;
  border-color: #e6c574;
}

.ov-method.is-patch {
  color: #4b2d8a;
  background: #ece2ff;
  border-color: #c9b3ff;
}

.ov-method.is-delete {
  color: #8a1f1a;
  background: #fbe0df;
  border-color: #eba6a2;
}

:global(.dark .ov-method.is-get) {
  color: #8feaf4;
  background: #0c3b41;
  border-color: #1b6a76;
}

:global(.dark .ov-method.is-post) {
  color: #c4f82a;
  background: #24380a;
  border-color: #4a6b12;
}

:global(.dark .ov-method.is-put) {
  color: #ffd166;
  background: #3a2c08;
  border-color: #6d5510;
}

:global(.dark .ov-method.is-patch) {
  color: #c9b3ff;
  background: #2a1d45;
  border-color: #4f3a80;
}

:global(.dark .ov-method.is-delete) {
  color: #ff9b94;
  background: #3d1513;
  border-color: #702a26;
}

.ov-path {
  flex: 1 1 16ch;
  min-width: 0;
  margin: 0;
  padding: 0;
  border: 0;
  background: none;
  color: var(--vp-c-text-1);
  font-family: var(--vp-font-family-mono);
  font-size: 13px;
  line-height: 1.6;
  overflow-wrap: anywhere;
  word-break: break-word;
  unicode-bidi: isolate;
}

.ov-chip {
  flex: none;
  display: inline-flex;
  align-items: center;
  gap: 5px;
  max-width: 100%;
  padding: 2px 9px;
  border: 1px solid var(--o-line-strong);
  border-radius: 999px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-2);
  font-size: 11.5px;
  line-height: 1.6;
  white-space: nowrap;
}

.ov-chip-label {
  color: var(--vp-c-text-2);
}

.ov-chip code {
  margin: 0;
  padding: 0;
  border: 0;
  background: none;
  color: var(--vp-c-text-1);
  font-size: 11.5px;
  unicode-bidi: isolate;
}

.ov-session {
  color: var(--vp-c-text-1);
  border-style: dashed;
}

/* Keep the location, type and required labels readable in API field tables.
   The table retains VitePress's own horizontal scrolling on small screens. */
:global(.vp-doc:has(.ov-endpoint) table:has(th:nth-child(4)) :is(th, td):nth-child(2)),
:global(.vp-doc:has(.ov-endpoint) table:has(th:nth-child(4)) :is(th, td):nth-child(3)) {
  white-space: nowrap;
  overflow-wrap: normal;
}

@media (max-width: 480px) {
  .ov-endpoint {
    padding: 9px 10px;
  }

  .ov-path {
    flex-basis: 100%;
    font-size: 12.5px;
  }
}
</style>

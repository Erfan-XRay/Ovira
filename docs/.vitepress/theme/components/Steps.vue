<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from "vue";
import { useData, withBase } from "vitepress";

const { lang } = useData();
const fa = computed(() => lang.value === "fa");

const copy = computed(() =>
  fa.value
    ? {
        title: "در سه قدم راه می‌افتد",
        steps: [
          { h: "نصب", p: "یک دستور روی سرور. پورت‌ها و HTTPS را همان لحظه انتخاب می‌کنید و رمز اولیه چاپ می‌شود.", to: "/fa/guide/install" },
          { h: "ورود و تنظیم", p: "آدرس پنل را باز کنید، سرورهای OpenVPN را ببینید و هر نود را که خواستید اضافه کنید.", to: "/fa/guide/first-steps" },
          { h: "ساخت کاربر", p: "حجم و زمان تعیین کنید و لینک اشتراک را بدهید. بقیه‌اش با پنل است.", to: "/fa/guide/servers" },
        ],
        cta: "شروع کنید",
        ctaTo: "/fa/guide/install",
        more: "پلن‌ها و لایسنس",
        moreTo: "/fa/guide/plans",
      }
    : {
        title: "Running in three steps",
        steps: [
          { h: "Install", p: "One command on the server. Pick the ports and HTTPS as it goes; the first password is printed at the end.", to: "/guide/install" },
          { h: "Sign in and set up", p: "Open the panel address, look over the OpenVPN servers and add nodes whenever you like.", to: "/guide/first-steps" },
          { h: "Create clients", p: "Set traffic and time, hand out the subscription link. The panel does the rest.", to: "/guide/servers" },
        ],
        cta: "Get started",
        ctaTo: "/guide/install",
        more: "Plans and licenses",
        moreTo: "/guide/plans",
      },
);

const root = ref<HTMLElement>();
const seen = ref(false);
const mounted = ref(false);
let io: IntersectionObserver | undefined;
onMounted(() => {
  mounted.value = true;
  io = new IntersectionObserver(([e]) => {
    if (e.isIntersecting) {
      seen.value = true;
      io?.disconnect();
    }
  }, { threshold: 0.25 });
  if (root.value) io.observe(root.value);
});
onUnmounted(() => io?.disconnect());
</script>

<template>
  <section ref="root" class="steps" :class="{ seen, mounted }">
    <h2>{{ copy.title }}</h2>
    <ol>
      <li v-for="(s, i) in copy.steps" :key="s.h" :style="{ '--i': i }">
        <a :href="withBase(s.to)" class="step glow">
          <span class="no">{{ i + 1 }}</span>
          <h3>{{ s.h }}</h3>
          <p>{{ s.p }}</p>
        </a>
      </li>
    </ol>
    <div class="cta">
      <a class="btn primary" :href="withBase(copy.ctaTo)">{{ copy.cta }}</a>
      <a class="btn" :href="withBase(copy.moreTo)">{{ copy.more }}</a>
    </div>
  </section>
</template>

<style scoped>
.steps {
  max-width: 1152px;
  margin: 0 auto;
  padding: 72px 24px 96px;
}

h2 {
  margin: 0 0 36px;
  border: 0;
  padding: 0;
  font-family: var(--o-display);
  font-size: clamp(30px, 5vw, 44px);
  font-weight: 650;
  letter-spacing: -0.035em;
  text-align: center;
  transition: opacity 0.8s var(--o-out), transform 0.8s var(--o-out);
}

.mounted:not(.seen) h2 { opacity: 0; transform: translateY(18px); }

ol {
  position: relative;
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 20px;
}

/* a line that draws itself through the three numbers */
ol::before {
  content: "";
  position: absolute;
  top: 46px;
  inset-inline: 16%;
  height: 2px;
  background: linear-gradient(to right, transparent, var(--vp-c-brand-3), transparent);
  transform: scaleX(0);
  transform-origin: center;
  transition: transform 1.6s var(--o-out) 0.4s;
}

li {
  transition: opacity 0.8s var(--o-out), transform 0.9s var(--o-spring);
  transition-delay: calc(var(--i) * 140ms + 200ms);
}

.mounted:not(.seen) li { opacity: 0; transform: translateY(30px); }

.seen h2,
.seen li {
  opacity: 1;
  transform: none;
}

.seen ol::before {
  transform: scaleX(1);
}

.step {
  position: relative;
  display: block;
  height: 100%;
  padding: 24px 24px 28px;
  border: 1px solid var(--o-line);
  border-radius: 22px;
  background: var(--o-glass);
  box-shadow: inset 0 1px 0 var(--o-edge);
  color: inherit;
  text-decoration: none;
  transition: transform 0.6s var(--o-spring), border-color 0.3s;
}

.step:hover {
  transform: translateY(-6px);
  border-color: var(--vp-c-brand-3);
}

.no {
  display: grid;
  place-items: center;
  width: 44px;
  height: 44px;
  margin-bottom: 18px;
  border-radius: 14px;
  background: var(--vp-c-brand-3);
  color: var(--vp-button-brand-text);
  font-family: var(--o-display);
  font-size: 20px;
  font-weight: 700;
  box-shadow: 0 10px 26px -10px var(--o-glow);
}

h3 {
  margin: 0 0 8px;
  font-family: var(--o-display);
  font-size: 22px;
  font-weight: 650;
  letter-spacing: -0.02em;
}

p {
  margin: 0;
  color: var(--vp-c-text-2);
  line-height: 1.65;
}

.cta {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 12px;
  margin-top: 44px;
}

.btn {
  display: inline-flex;
  align-items: center;
  height: 46px;
  padding: 0 24px;
  border: 1px solid var(--o-line-strong);
  border-radius: 14px;
  color: var(--vp-c-text-1);
  font-weight: 650;
  text-decoration: none;
  transition: transform 0.4s var(--o-spring), border-color 0.2s, box-shadow 0.3s;
}

.btn:hover {
  transform: translateY(-3px);
  border-color: var(--vp-c-brand-3);
}

.btn.primary {
  border-color: transparent;
  background: var(--vp-button-brand-bg);
  color: var(--vp-button-brand-text);
  box-shadow: 0 14px 30px -12px var(--o-glow);
}

@media (max-width: 860px) {
  ol {
    grid-template-columns: minmax(0, 1fr);
  }

  ol::before {
    display: none;
  }
}

@media (prefers-reduced-motion: reduce) {
  .mounted:not(.seen) h2,
  .mounted:not(.seen) li {
    opacity: 1;
    transform: none;
    transition: none;
  }
}
</style>

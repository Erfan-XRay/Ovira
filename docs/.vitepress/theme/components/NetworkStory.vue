<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from "vue";
import { useData, withBase } from "vitepress";
import InstallBox from "./InstallBox.vue";

const { lang } = useData();
const fa = computed(() => lang.value === "fa");
const root = ref<HTMLElement>();
const stage = ref(0);
const animated = ref(false);
const prefix = computed(() => fa.value ? "/fa" : "");
const copy = computed(() => fa.value ? {
  eyebrow: "زیرساخت شما. کنترل در دستان شما.",
  title: "از یک سرور،", accent: "تا شبکهٔ شما.",
  intro: "OpenVPN و OpenConnect را از یک جا مدیریت کنید. سرورها روی زیرساخت خودتان؛ کاربران، حجم و زمان، در اویرا.",
  start: "راهنمای نصب", explore: "اویرا چطور کار می‌کند؟", label: "از سرور تا اتصال",
  scroll: "اسکرول کنید؛ شبکه را بسازید", schematic: "نمای مفهومی معماری اویرا",
  panel: "پنل اویرا", control: "مدیریت کاربران و دسترسی", node: "نود", local: "سرور محلی", client: "کاربر", subscription: "لینک اشتراک",
  note: "نمای مفهومی · ترافیک VPN از نودها عبور می‌کند؛ پنل مدیریت را بر عهده دارد.",
  chapters: [
    { title: "یک نقطهٔ شروع.", text: "پنل را روی سرور لینوکس نصب کنید. سرور VPN می‌تواند روی همین سرور اجرا شود؛ یا پنل فقط نودها را مدیریت کند.", link: "نصب و راه‌اندازی", to: "/guide/install" },
    { title: "فضا برای گسترش.", text: "سرورهای دیگر را به‌عنوان نود اضافه کنید. کاربر را یک بار بسازید و دسترسی، حجم و تعداد دستگاه‌هایش را در سراسر شبکه مدیریت کنید.", link: "نودها و سرورهای واسط", to: "/guide/nodes" },
    { title: "یک لینک تا اتصال.", text: "کاربر از صفحهٔ اشتراک، حجم و زمان باقی‌مانده را می‌بیند و پروفایل اتصال خود را دریافت می‌کند. دسترسی به سرورها را شما تعیین می‌کنید.", link: "ساخت اولین کاربر", to: "/guide/first-steps" },
  ],
  foundation: "جزئیاتی که کار روزمره را ساده می‌کنند.",
} : {
  eyebrow: "YOUR INFRASTRUCTURE. YOUR CONTROL.",
  title: "Start with a server.", accent: "Make it a network.",
  intro: "One place to manage OpenVPN and OpenConnect. Servers on your infrastructure. Clients, traffic and time limits in Ovira.",
  start: "Installation guide", explore: "See how it works", label: "FROM SERVER TO CONNECTION",
  scroll: "Scroll to build your network", schematic: "Conceptual diagram of the Ovira architecture",
  panel: "Ovira panel", control: "Clients & access control", node: "Node", local: "Local server", client: "Client", subscription: "Subscription link",
  note: "Architecture illustration · VPN traffic flows through nodes. The panel manages access.",
  chapters: [
    { title: "One starting point.", text: "Install the panel on a Linux server. Run VPN servers on that same machine, or let the panel manage only your remote nodes.", link: "Install and set up", to: "/guide/install" },
    { title: "Room to grow.", text: "Add more servers as nodes. Create a client once, then manage access, traffic allowances and device limits across your network.", link: "Explore nodes and relays", to: "/guide/nodes" },
    { title: "One link to connect.", text: "Clients see remaining traffic and time on their subscription page and download their connection profiles. You decide which servers they can access.", link: "Create your first client", to: "/guide/first-steps" },
  ],
  foundation: "The details that make everyday work easier.",
});

let media: { revert: () => void } | undefined;
let disposed = false;
onMounted(async () => {
  const [{ gsap }, { ScrollTrigger }] = await Promise.all([import("gsap"), import("gsap/ScrollTrigger")]);
  if (disposed || !root.value) return;
  gsap.registerPlugin(ScrollTrigger);
  media = gsap.matchMedia();
  // Native document scrolling, one scrubbed scene, no wheel interception.
  (media as ReturnType<typeof gsap.matchMedia>).add("(min-width: 900px) and (min-height: 680px) and (prefers-reduced-motion: no-preference)", () => {
    animated.value = true;
    const el = root.value!;
    const select = gsap.utils.selector(el);
    const timeline = gsap.timeline({
      defaults: { ease: "none" },
      scrollTrigger: {
        trigger: select(".story-track")[0], start: "top 80px", end: "bottom bottom", scrub: 0.65,
        onUpdate: self => { stage.value = Math.min(2, Math.floor(self.progress * 3)); },
      },
    });
    timeline.fromTo(select(".remote"), { opacity: 0.15, scale: 0.8, y: 36 }, { opacity: 1, scale: 1, y: 0, stagger: 0.09, duration: 0.6 }, 0.05)
      .fromTo(select(".node-link"), { opacity: 0.08 }, { opacity: 1, duration: 0.5 }, 0.12)
      .fromTo(select(".client-device"), { opacity: 0.08, y: 35 }, { opacity: 1, y: 0, duration: 0.45 }, 0.62)
      .fromTo(select(".traffic-link"), { opacity: 0.08 }, { opacity: 1, duration: 0.35 }, 0.65)
      .fromTo(select(".signal"), { x: -110 }, { x: 110, duration: 0.8 }, 0.2);
    return () => { stage.value = 0; animated.value = false; };
  }, root.value);
  await document.fonts.ready;
  if (!disposed) ScrollTrigger.refresh();
});
onUnmounted(() => { disposed = true; media?.revert(); });
</script>

<template>
  <div ref="root" class="network-home" :class="{ animated }">
    <section class="network-hero">
      <div class="hero-meta"><span class="eyebrow"><i />{{ copy.eyebrow }}</span><span class="edition" dir="ltr">OVIRA / VPN</span></div>
      <h1>{{ copy.title }}<br><span>{{ copy.accent }}</span></h1>
      <div class="hero-bottom">
        <div class="hero-description"><p>{{ copy.intro }}</p><div class="hero-actions"><a class="primary-link" :href="withBase(`${prefix}/guide/install`)">{{ copy.start }}<span aria-hidden="true">↗</span></a><a class="text-link" href="#network-story">{{ copy.explore }}<span aria-hidden="true">↓</span></a></div></div>
        <div class="hero-mark" aria-hidden="true"><span class="orbit orbit-one" /><span class="orbit orbit-two" /><span class="orbit orbit-three" /><img :src="withBase('/logo.svg')" alt="" width="76" height="76"><span class="coordinate" dir="ltr">01 — ∞</span></div>
      </div>
      <InstallBox />
      <a href="#network-story" class="scroll-cue"><span aria-hidden="true">↓</span>{{ copy.scroll }}<span class="cue-line" /></a>
    </section>

    <section id="network-story" class="story-track" :aria-label="copy.label">
      <div class="story-sticky">
        <div class="story-heading"><span class="eyebrow">{{ copy.label }}</span><span class="diagram-index" dir="ltr">0{{ stage + 1 }} / 03</span></div>
        <div class="story-layout">
          <div class="chapter-stack">
            <article v-for="(chapter, i) in copy.chapters" :key="i" class="chapter" :class="{ 'is-active': stage === i }">
              <span class="chapter-number" dir="ltr">0{{ i + 1 }} /</span><h2>{{ chapter.title }}</h2><p>{{ chapter.text }}</p><a :href="withBase(`${prefix}${chapter.to}`)">{{ chapter.link }}<span aria-hidden="true">↗</span></a>
            </article>
            <div class="chapter-progress" aria-hidden="true"><i v-for="i in 3" :key="i" :class="{ active: stage === i - 1 }" /></div>
          </div>
          <div class="network-diagram" role="img" :aria-label="copy.schematic" dir="ltr">
            <div class="diagram-grid" />
            <div class="diagram-orbit orbit-a" /><div class="diagram-orbit orbit-b" />
            <svg class="connections" viewBox="0 0 600 480" fill="none" aria-hidden="true">
              <g class="node-link" stroke="var(--vp-c-brand-1)" stroke-width="1.5" stroke-dasharray="4 7"><path d="M300 164 L130 290" /><path d="M300 164 L470 290" /></g>
              <path d="M300 164 V290" stroke="var(--vp-c-brand-1)" stroke-width="1.5" stroke-dasharray="4 7" />
              <g class="traffic-link" stroke="var(--o-cyan)" stroke-width="1.5"><path d="M130 310 Q130 416 300 416" /><path d="M470 310 Q470 416 300 416" /><path d="M300 310 V416" /></g>
            </svg>
            <div class="control-node"><div class="node-icon"><img :src="withBase('/logo.svg')" width="38" height="38" alt=""></div><strong>{{ copy.panel }}</strong><span>{{ copy.control }}</span><div class="signal-track"><i class="signal" /></div></div>
            <div class="server-node remote server-left"><svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="3" width="18" height="7" rx="2"/><rect x="3" y="14" width="18" height="7" rx="2"/><path d="M7 6h.01M7 17h.01M11 6h6M11 17h6"/></svg><strong>{{ copy.node }} 01</strong><span>OpenVPN</span></div>
            <div class="server-node server-middle"><svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="3" width="18" height="7" rx="2"/><rect x="3" y="14" width="18" height="7" rx="2"/><path d="M7 6h.01M7 17h.01M11 6h6M11 17h6"/></svg><strong>{{ copy.local }}</strong><span>OpenVPN</span></div>
            <div class="server-node remote server-right"><svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="3" width="18" height="7" rx="2"/><rect x="3" y="14" width="18" height="7" rx="2"/><path d="M7 6h.01M7 17h.01M11 6h6M11 17h6"/></svg><strong>{{ copy.node }} 02</strong><span>OpenVPN</span></div>
            <div class="client-device"><svg viewBox="0 0 24 24" aria-hidden="true"><rect x="6" y="2" width="12" height="20" rx="3"/><path d="M10 18h4"/></svg><div><strong>{{ copy.client }}</strong><span>{{ copy.subscription }}</span></div></div>
            <span class="diagram-caption" dir="auto">{{ copy.note }}</span>
          </div>
        </div>
      </div>
    </section>
    <div class="features-intro"><span class="eyebrow">OVIRA / TOOLKIT</span><h2>{{ copy.foundation }}</h2></div>
  </div>
</template>

<style scoped>
:global(.VPHome .VPHero) { display: none; }
.network-home { --network-muted: var(--vp-c-text-2); }
.network-hero { max-width: 1200px; margin: auto; padding: 62px 32px 0; }
.hero-meta, .story-heading { display:flex; justify-content:space-between; align-items:center; gap:24px; }
.eyebrow, .edition, .diagram-index, .chapter-number, .coordinate { font-family:var(--vp-font-family-mono); font-size:11px; line-height:1.6; letter-spacing:.12em; }
.eyebrow { color:var(--vp-c-brand-1); display:flex; align-items:center; gap:10px; }
.eyebrow i { width:6px; height:6px; border-radius:50%; background:currentColor; }
.edition, .diagram-index { color:var(--network-muted); }
h1 { margin:36px 0 28px; font-family:var(--o-display); font-size:clamp(52px,7.7vw,104px); line-height:1.04; font-weight:600; letter-spacing:-.065em; }
h1 span { color:var(--vp-c-brand-1); }
.hero-bottom { display:flex; align-items:center; justify-content:space-between; gap:30px; }
.hero-description { max-width:585px; }
.hero-description p { color:var(--network-muted); font-size:20px; line-height:1.65; margin:0; text-wrap:pretty; }
.hero-actions { display:flex; flex-wrap:wrap; align-items:center; gap:24px; margin-top:28px; }
.primary-link, .text-link { display:inline-flex; align-items:center; gap:24px; min-height:48px; font-weight:650; font-size:15px; }
.primary-link { background:var(--vp-button-brand-bg); color:var(--vp-button-brand-text); padding:0 22px; border-radius:8px; transition:background .2s,transform .2s; }
.primary-link:hover { background:var(--vp-button-brand-hover-bg); transform:translateY(-2px); }
.text-link { color:var(--vp-c-text-1); border-bottom:1px solid var(--o-line-strong); }
a:focus-visible { outline:2px solid var(--vp-c-brand-1); outline-offset:6px; }
.hero-mark { position:relative; display:grid; place-items:center; width:230px; height:200px; flex-shrink:0; margin-inline-end:70px; }
.hero-mark img { transform:rotate(-12deg); border-radius:22px; box-shadow:0 0 70px -20px var(--o-glow); }
.orbit { position:absolute; width:200px; height:90px; border:1px solid var(--o-line-strong); border-radius:50%; transform:rotate(-32deg); }
.orbit-two { transform:rotate(32deg); }.orbit-three { width:180px; height:180px; transform:none; border-style:dashed; opacity:.5; }
.coordinate { position:absolute; bottom:-12px; color:var(--network-muted); }
.network-hero :deep(.install) { max-width:700px; margin-top:38px; animation:none; border-radius:10px; backdrop-filter:none; }
.network-hero :deep(.type) { animation:none; border:0; }
.scroll-cue { display:flex; align-items:center; gap:14px; min-height:76px; margin-top:30px; color:var(--network-muted); font-size:12px; }
.scroll-cue > span:first-child { font-size:20px; color:var(--vp-c-brand-1); }.cue-line { height:1px; background:var(--o-line-strong); flex:1; margin-inline-start:20px; }
.story-track { max-width:1200px; margin:auto; padding:0 32px; scroll-margin-top:80px; }
.story-sticky { padding:32px 0; border-top:1px solid var(--o-line-strong); }
.story-layout { display:grid; grid-template-columns:.85fr 1.15fr; align-items:center; gap:36px; min-height:510px; }
.chapter-stack { position:relative; }
.chapter { margin:28px 0; }.chapter-number { color:var(--vp-c-brand-1); }
.chapter h2 { font-family:var(--o-display); font-size:clamp(32px,3.4vw,46px); font-weight:550; letter-spacing:-.04em; line-height:1.15; margin:16px 0; }
.chapter p { font-size:17px; line-height:1.8; color:var(--network-muted); max-width:390px; margin:0; }
.chapter a { display:inline-flex; align-items:center; gap:20px; min-height:48px; margin-top:16px; font-size:14px; color:var(--vp-c-brand-1); }
.chapter-progress { display:none; gap:8px; margin-top:30px; }.chapter-progress i { width:42px; height:3px; background:var(--o-line-strong); }.chapter-progress .active { background:var(--vp-c-brand-1); }
.network-diagram { position:relative; aspect-ratio:600/520; border:1px solid var(--o-line-strong); border-radius:16px; background:var(--vp-c-bg-alt); overflow:hidden; }
.diagram-grid { position:absolute; inset:0; background-image:linear-gradient(var(--o-line) 1px,transparent 1px),linear-gradient(90deg,var(--o-line) 1px,transparent 1px); background-size:36px 36px; opacity:.4; mask-image:radial-gradient(ellipse,#000,transparent 80%); }
.diagram-orbit { position:absolute; width:76%; height:76%; border:1px solid var(--o-line); border-radius:50%; left:12%; top:9%; }.orbit-b { width:98%; height:98%; left:1%; top:-2%; }
.connections { position:absolute; inset:0; width:100%; height:92.3%; }
.control-node { position:absolute; top:12%; left:50%; transform:translateX(-50%); width:174px; text-align:center; border:1px solid var(--vp-c-brand-1); border-radius:12px; background:var(--vp-c-bg-elv); padding:14px 10px 0; box-shadow:0 16px 50px -30px var(--o-glow); overflow:hidden; }
.node-icon { margin-bottom:7px; display:flex; justify-content:center; }.control-node strong { display:block; font-size:16px; font-family:var(--o-display); }.control-node > span { font-size:11px; color:var(--network-muted); }
.signal-track { height:2px; margin-top:12px; overflow:hidden; }.signal { display:block; width:50px; height:2px; background:var(--vp-c-brand-1); margin:auto; }
.server-node { position:absolute; top:48%; width:23%; display:grid; justify-items:center; gap:4px; padding:12px 3px; background:var(--vp-c-bg-elv); border:1px solid var(--o-line-strong); border-radius:10px; }
.server-left { left:10%; }.server-middle { left:38.5%; }.server-right { right:10%; }
.server-node svg { width:24px; height:24px; stroke:var(--vp-c-brand-1); fill:none; stroke-width:1.3; margin-bottom:4px; }.server-node strong { font-size:12px; font-weight:550; }.server-node span { font-size:10px; color:var(--network-muted); font-family:var(--vp-font-family-mono); }
.client-device { position:absolute; top:73%; left:50%; transform:translateX(-50%); display:flex; align-items:center; gap:10px; padding:10px 18px; background:var(--vp-c-bg-elv); border:1px solid var(--o-cyan); border-radius:10px; white-space:nowrap; }
.client-device svg { width:22px; height:28px; fill:none; stroke:var(--o-cyan); stroke-width:1.4; }.client-device strong { display:block; font-size:13px; }.client-device span { font-size:10px; color:var(--network-muted); }
.diagram-caption { position:absolute; bottom:3%; inset-inline:6%; text-align:center; color:var(--network-muted); font-size:10px; line-height:1.7; text-wrap:balance; }
.features-intro { max-width:1152px; margin:40px auto 36px; padding:0 24px; }.features-intro h2 { font-family:var(--o-display); font-size:clamp(28px,3.4vw,42px); font-weight:550; letter-spacing:-.035em; line-height:1.3; max-width:650px; margin-top:14px; }
:global([dir="rtl"]) h1, :global([dir="rtl"]) .chapter h2, :global([dir="rtl"]) .features-intro h2 { font-family:"Vazirmatn Variable",sans-serif; letter-spacing:0; line-height:1.55; }
:global([dir="rtl"]) .eyebrow { letter-spacing:0; font-family:var(--vp-font-family-base); }
@media (min-width:900px) and (min-height:680px) and (prefers-reduced-motion:no-preference) {
  .animated .story-track { height:235vh; }.animated .story-sticky { position:sticky; top:80px; }.animated .story-layout { min-height:min(72vh,650px); }
  .animated .chapter-stack { display:grid; }.animated .chapter { grid-area:1/1; opacity:0; visibility:hidden; transform:translateY(14px); transition:opacity .4s,transform .4s,visibility .4s; pointer-events:none; }.animated .chapter.is-active { opacity:1; visibility:visible; transform:none; pointer-events:auto; }
  .animated .chapter-progress { display:flex; }
}
@media (max-width:899px), (max-height:679px), (prefers-reduced-motion:reduce) {
  .story-layout { grid-template-columns:1fr 1.15fr; align-items:start; gap:24px; }.network-diagram { position:sticky; top:100px; margin-top:30px; }.chapter h2 { font-size:30px; }.chapter p { font-size:15px; }.chapter { margin:30px 0 50px; }
}
@media (max-width:639px) {
  .network-hero { padding:36px 24px 0; }.edition { display:none; }.eyebrow { font-size:10px; }h1 { font-size:clamp(42px,10.4vw,64px); letter-spacing:-.05em; margin:26px 0; line-height:1.1; }
  .hero-description p { font-size:17px; }.hero-mark { display:none; }.hero-actions { gap:16px; }.primary-link,.text-link { font-size:13px; gap:14px; }.primary-link { padding:0 16px; }
  .network-hero :deep(.install) { margin-top:28px; }.scroll-cue { margin-top:16px; }.story-track { padding:0 24px; }.story-layout { display:flex; flex-direction:column-reverse; gap:0; }.network-diagram { width:100%; position:relative; top:auto; margin:24px 0 0; }.chapter-stack { width:100%; }.chapter { margin:28px 0 36px; padding-bottom:24px; border-bottom:1px solid var(--o-line); }.chapter p { max-width:none; }.chapter h2 { font-size:30px; }.story-sticky { padding-bottom:0; }.control-node { width:138px; padding-top:10px; }.control-node strong { font-size:13px; }.control-node > span { font-size:9px; }.node-icon img { width:26px; height:26px; }.server-node { padding:8px 2px; }.server-node svg { width:20px; height:20px; }.server-node strong { font-size:10px; }.server-node span { font-size:9px; }.client-device { padding:6px 12px; }.diagram-caption { font-size:9px; }.features-intro { margin-top:20px; }
}
@media (prefers-reduced-motion:reduce) { .network-diagram { position:relative; top:auto; } }
</style>

import { computed, onMounted, onUnmounted, ref, type Ref } from "vue";
import { useData } from "vitepress";
import { EN, FA, type Copy } from "./copy";

/** Language, copy and path prefix for the current page. */
export function useCopy() {
  const { lang } = useData();
  const fa = computed(() => lang.value === "fa");
  const t = computed<Copy>(() => (fa.value ? FA : EN));
  const prefix = computed(() => (fa.value ? "/fa" : ""));
  return { fa, t, prefix };
}

/**
 * True while the element is on screen, the tab is visible and the visitor has
 * not asked for reduced motion. Animations start and stop on this.
 */
export function useLive(el: Ref<HTMLElement | undefined | null>) {
  const inView = ref(false);
  const tabHidden = ref(false);
  const reduced = ref(false);
  const live = computed(() => inView.value && !tabHidden.value && !reduced.value);
  let io: IntersectionObserver | undefined;
  let mq: MediaQueryList | undefined;
  const onVis = () => (tabHidden.value = document.hidden);
  const onMq = () => (reduced.value = !!mq?.matches);

  onMounted(() => {
    mq = matchMedia("(prefers-reduced-motion: reduce)");
    onMq();
    onVis();
    mq.addEventListener("change", onMq);
    document.addEventListener("visibilitychange", onVis);
    if (el.value) {
      io = new IntersectionObserver(([e]) => (inView.value = e.isIntersecting), { rootMargin: "80px" });
      io.observe(el.value);
    }
  });
  onUnmounted(() => {
    io?.disconnect();
    mq?.removeEventListener("change", onMq);
    document.removeEventListener("visibilitychange", onVis);
  });
  return { live, inView, reduced };
}

/** Arrow-key navigation for a row of tabs. */
export function tabKeys(e: KeyboardEvent, count: number, current: number, set: (i: number) => void, rtl: boolean) {
  const step = e.key === "ArrowRight" ? (rtl ? -1 : 1) : e.key === "ArrowLeft" ? (rtl ? 1 : -1) : 0;
  let next = current;
  if (step) next = (current + step + count) % count;
  else if (e.key === "Home") next = 0;
  else if (e.key === "End") next = count - 1;
  else return;
  e.preventDefault();
  set(next);
  const tabs = (e.currentTarget as HTMLElement).closest('[role="tablist"]')?.querySelectorAll<HTMLElement>('[role="tab"]');
  tabs?.[next]?.focus();
}

/** Mirror x for right-to-left maps. */
export const mx = (x: number, w: number, flip: boolean) => (flip ? w - x : x);

/** A path through points with rounded corners (all corners are 45 or 90 degrees). */
export function roundedPath(pts: [number, number][], r = 22): string {
  if (pts.length < 2) return "";
  let d = `M${pts[0][0]} ${pts[0][1]}`;
  for (let i = 1; i < pts.length - 1; i++) {
    const [px, py] = pts[i - 1];
    const [x, y] = pts[i];
    const [nx, ny] = pts[i + 1];
    const l1 = Math.hypot(x - px, y - py);
    const l2 = Math.hypot(nx - x, ny - y);
    const k = Math.min(r, l1 / 2, l2 / 2);
    const ax = x - ((x - px) / l1) * k;
    const ay = y - ((y - py) / l1) * k;
    const bx = x + ((nx - x) / l2) * k;
    const by = y + ((ny - y) / l2) * k;
    d += `L${ax.toFixed(1)} ${ay.toFixed(1)}Q${x} ${y} ${bx.toFixed(1)} ${by.toFixed(1)}`;
  }
  const [lx, ly] = pts[pts.length - 1];
  return d + `L${lx} ${ly}`;
}

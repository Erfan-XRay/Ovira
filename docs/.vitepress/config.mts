import { defineConfig } from "vitepress";

const enGuide = [
  {
    text: "Getting started",
    items: [
      { text: "Install", link: "/guide/install" },
      { text: "First steps", link: "/guide/first-steps" },
      { text: "HTTPS", link: "/guide/https" },
    ],
  },
  {
    text: "Running it",
    items: [
      { text: "OpenVPN servers", link: "/guide/servers" },
      { text: "Nodes and relays", link: "/guide/nodes" },
      { text: "Updates", link: "/guide/updates" },
      { text: "Plans and licenses", link: "/guide/plans" },
    ],
  },
  {
    text: "Reference",
    items: [
      { text: "Command line", link: "/guide/cli" },
      { text: "Troubleshooting", link: "/guide/faq" },
    ],
  },
];

const faGuide = [
  {
    text: "شروع",
    items: [
      { text: "نصب", link: "/fa/guide/install" },
      { text: "قدم‌های اول", link: "/fa/guide/first-steps" },
      { text: "HTTPS", link: "/fa/guide/https" },
    ],
  },
  {
    text: "کار با پنل",
    items: [
      { text: "سرورهای OpenVPN", link: "/fa/guide/servers" },
      { text: "نودها و سرورهای واسط", link: "/fa/guide/nodes" },
      { text: "به‌روزرسانی", link: "/fa/guide/updates" },
      { text: "پلن‌ها و لایسنس", link: "/fa/guide/plans" },
    ],
  },
  {
    text: "مرجع",
    items: [
      { text: "خط فرمان", link: "/fa/guide/cli" },
      { text: "رفع مشکل", link: "/fa/guide/faq" },
    ],
  },
];

export default defineConfig({
  base: "/Burrow/",
  title: "Burrow",
  description: "An OpenVPN panel for Linux servers",
  cleanUrls: true,
  lastUpdated: true,
  head: [
    [
      "link",
      {
        rel: "icon",
        type: "image/svg+xml",
        href: "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'%3E%3Crect width='32' height='32' rx='4' fill='%23f0a33a'/%3E%3Cpath d='M7 26V16a9 9 0 0 1 18 0v10' fill='none' stroke='%231d1407' stroke-width='3.2'/%3E%3Ccircle cx='16' cy='15.5' r='2.6' fill='%231d1407'/%3E%3C/svg%3E",
      },
    ],
  ],
  themeConfig: {
    logo: { src: "/logo.svg", alt: "" },
    socialLinks: [{ icon: "github", link: "https://github.com/Erfan-XRay/Burrow" }],
    search: { provider: "local" },
  },
  locales: {
    root: {
      label: "English",
      lang: "en",
      themeConfig: {
        nav: [
          { text: "Guide", link: "/guide/install" },
          { text: "Plans", link: "/guide/plans" },
          { text: "Releases", link: "https://github.com/Erfan-XRay/Burrow/releases" },
        ],
        sidebar: { "/guide/": enGuide },
        footer: { message: "Proprietary software · documentation free to share", copyright: "© 2026 Burrow" },
      },
    },
    fa: {
      label: "فارسی",
      lang: "fa",
      dir: "rtl",
      title: "بارو",
      description: "پنل OpenVPN برای سرورهای لینوکس",
      themeConfig: {
        nav: [
          { text: "راهنما", link: "/fa/guide/install" },
          { text: "پلن‌ها", link: "/fa/guide/plans" },
          { text: "نسخه‌ها", link: "https://github.com/Erfan-XRay/Burrow/releases" },
        ],
        sidebar: { "/fa/guide/": faGuide },
        outline: { label: "در این صفحه" },
        docFooter: { prev: "قبلی", next: "بعدی" },
        lastUpdated: { text: "آخرین به‌روزرسانی" },
        returnToTopLabel: "بازگشت به بالا",
        sidebarMenuLabel: "فهرست",
        darkModeSwitchLabel: "حالت تیره",
        footer: { message: "نرم‌افزار انحصاری · مستندات آزاد برای اشتراک", copyright: "© ۲۰۲۶ بارو" },
      },
    },
  },
});

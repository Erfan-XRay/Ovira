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
      { text: "Hosts", link: "/guide/hosts" },
      { text: "Groups", link: "/guide/groups" },
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
      { text: "هاست‌ها", link: "/fa/guide/hosts" },
      { text: "گروه‌ها", link: "/fa/guide/groups" },
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
  base: "/Ovira/",
  title: "Ovira",
  description: "OpenVPN panel for Linux servers",
  appearance: "dark",
  cleanUrls: true,
  lastUpdated: true,
  head: [
    [
      "link",
      {
        rel: "icon",
        type: "image/svg+xml",
        href: "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'%3E%3Crect width='32' height='32' rx='9' fill='%23c4f82a'/%3E%3Ccircle cx='16' cy='16' r='8.4' fill='none' stroke='%230b1300' stroke-width='2.6'/%3E%3Cpath d='M11.9 13.4 16 19.2l4.1-5.8' fill='none' stroke='%230b1300' stroke-width='2.6' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E",
      },
    ],
  ],
  themeConfig: {
    logo: { src: "/logo.svg", alt: "" },
    siteTitle: "Ovira",
    socialLinks: [{ icon: "github", link: "https://github.com/Erfan-XRay/Ovira" }],
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
          { text: "Releases", link: "https://github.com/Erfan-XRay/Ovira/releases" },
        ],
        sidebar: { "/guide/": enGuide },
        footer: { message: "Proprietary software · documentation free to share", copyright: "© 2026 Ovira" },
      },
    },
    fa: {
      label: "فارسی",
      lang: "fa",
      dir: "rtl",
      title: "اویرا",
      description: "پنل OpenVPN برای سرورهای لینوکس",
      themeConfig: {
        nav: [
          { text: "راهنما", link: "/fa/guide/install" },
          { text: "پلن‌ها", link: "/fa/guide/plans" },
          { text: "نسخه‌ها", link: "https://github.com/Erfan-XRay/Ovira/releases" },
        ],
        sidebar: { "/fa/guide/": faGuide },
        outline: { label: "در این صفحه" },
        docFooter: { prev: "قبلی", next: "بعدی" },
        lastUpdated: { text: "آخرین به‌روزرسانی" },
        returnToTopLabel: "بازگشت به بالا",
        sidebarMenuLabel: "فهرست",
        darkModeSwitchLabel: "حالت تیره",
        footer: { message: "نرم‌افزار انحصاری · مستندات آزاد برای اشتراک", copyright: "© ۲۰۲۶ اویرا" },
      },
    },
  },
});

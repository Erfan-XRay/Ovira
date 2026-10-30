import { defineConfig } from "vitepress";

type Item = { text: string; link: string };
type Group = { text: string; items: Item[] };

// One sidebar for every section, so the reader can move between them.
function sections(prefix: string, t: Record<string, string>): Group[] {
  const p = (s: string) => `${prefix}/${s}`;
  return [
    {
      text: t.start,
      items: [
        { text: t.getStarted, link: p("start/") },
        { text: t.installPanel, link: p("start/install-panel") },
        { text: t.firstSignIn, link: p("start/first-sign-in") },
        { text: t.https, link: p("start/https") },
        { text: t.addNode, link: p("start/add-node") },
        { text: t.sameServer, link: p("start/same-server") },
        { text: t.firstClient, link: p("start/first-client") },
        { text: t.update, link: p("start/update") },
        { text: t.moveServer, link: p("start/move-server") },
        { text: t.uninstall, link: p("start/uninstall") },
      ],
    },
    {
      text: t.use,
      items: [
        { text: t.usingPanel, link: p("use/") },
        { text: t.overview, link: p("use/dashboard") },
        { text: t.clients, link: p("use/clients") },
        { text: t.connections, link: p("use/connections") },
        { text: t.inbounds, link: p("use/inbounds") },
        { text: t.nodes, link: p("use/nodes") },
        { text: t.groups, link: p("use/groups") },
        { text: t.admins, link: p("use/admins") },
        { text: t.resellers, link: p("use/resellers") },
        { text: t.subPage, link: p("use/subscription-page") },
        { text: t.settings, link: p("use/settings") },
        { text: t.backup, link: p("use/backup") },
        { text: t.audit, link: p("use/audit") },
        { text: t.updates, link: p("use/updates") },
        { text: t.license, link: p("use/license") },
      ],
    },
    {
      text: t.protocols,
      items: [
        { text: t.choosing, link: p("protocols/") },
        { text: "OpenVPN", link: p("protocols/openvpn") },
        { text: t.wireguard, link: p("protocols/wireguard") },
        { text: "OpenConnect", link: p("protocols/openconnect") },
        { text: t.apps, link: p("protocols/apps") },
      ],
    },
    {
      text: t.how,
      items: [
        { text: t.fits, link: p("how/") },
        { text: t.connection, link: p("how/connection") },
        { text: t.traffic, link: p("how/traffic") },
        { text: t.nodePanel, link: p("how/nodes") },
        { text: t.relays, link: p("how/relays") },
      ],
    },
    {
      text: t.reference,
      items: [
        { text: t.cli, link: p("reference/cli") },
        { text: t.files, link: p("reference/files-and-ports") },
        { text: t.trouble, link: p("reference/troubleshooting") },
        { text: t.glossary, link: p("reference/glossary") },
        { text: t.changelog, link: p("reference/changelog") },
      ],
    },
  ];
}

const en = {
  start: "Get started", getStarted: "Get started", installPanel: "Install the panel", firstSignIn: "The first sign-in",
  https: "HTTPS for the panel", addNode: "Add a node", sameServer: "This server as a node", firstClient: "Your first client",
  update: "Update Ovira", moveServer: "Move to a new server", uninstall: "Remove Ovira",
  use: "Use the panel", usingPanel: "Using the panel", overview: "Overview", clients: "Clients", connections: "Connections",
  inbounds: "Inbounds", nodes: "Nodes", groups: "Groups", admins: "Panel accounts", resellers: "Roles and resellers",
  subPage: "The subscription page", settings: "Settings", backup: "Back up and restore", audit: "Activity log",
  updates: "Updates", license: "License",
  protocols: "Protocols", choosing: "Choosing a protocol", wireguard: "WireGuard and AmneziaWG", apps: "Client apps",
  how: "How it works", fits: "How Ovira fits together", connection: "The life of a connection",
  traffic: "Traffic, quotas and limits", nodePanel: "A node and its panel", relays: "Relays and connect addresses",
  reference: "Reference", cli: "Command line", files: "Files, services and ports", trouble: "Troubleshooting",
  glossary: "Glossary", changelog: "Changelog",
};

const fa = {
  start: "شروع کار", getStarted: "شروع کار", installPanel: "نصب پنل", firstSignIn: "اولین ورود",
  https: "HTTPS برای پنل", addNode: "افزودن نود", sameServer: "همین سرور به‌عنوان نود", firstClient: "اولین کاربر شما",
  update: "به‌روزرسانی اویرا", moveServer: "انتقال به سرور جدید", uninstall: "حذف اویرا",
  use: "کار با پنل", usingPanel: "استفاده از پنل", overview: "نمای کلی", clients: "کاربران", connections: "اتصال‌ها",
  inbounds: "اینباندها", nodes: "نودها", groups: "گروه‌ها", admins: "حساب‌های پنل", resellers: "نقش‌ها و نماینده‌های فروش",
  subPage: "صفحهٔ اشتراک", settings: "تنظیمات", backup: "پشتیبان‌گیری و بازگردانی", audit: "گزارش فعالیت",
  updates: "به‌روزرسانی‌ها", license: "لایسنس",
  protocols: "پروتکل‌ها", choosing: "انتخاب پروتکل", wireguard: "WireGuard و AmneziaWG", apps: "برنامه‌های کاربران",
  how: "طرز کار", fits: "اجزای اویرا و ارتباطشان", connection: "چرخهٔ عمر یک اتصال",
  traffic: "ترافیک، سهمیه و محدودیت‌ها", nodePanel: "نود و پنلش", relays: "رله‌ها و آدرس‌های اتصال",
  reference: "مرجع", cli: "خط فرمان", files: "فایل‌ها، سرویس‌ها و پورت‌ها", trouble: "عیب‌یابی",
  glossary: "واژه‌نامه", changelog: "تاریخچهٔ تغییرات",
};

const enGuide = sections("", en);
const faGuide = sections("/fa", fa);
const sectionDirs = ["start", "use", "protocols", "how", "reference", "guide"];
const sidebarFor = (prefix: string, groups: Group[]) =>
  Object.fromEntries(sectionDirs.map((d) => [`${prefix}/${d}/`, groups]));

export default defineConfig({
  base: "/Ovira/",
  title: "Ovira",
  description: "OpenVPN and OpenConnect panel for Linux servers",
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
          { text: "Get started", link: "/start/" },
          { text: "Docs", link: "/use/" },
          { text: "Protocols", link: "/protocols/" },
          { text: "License", link: "/use/license" },
          { text: "Releases", link: "https://github.com/Erfan-XRay/Ovira/releases" },
        ],
        sidebar: sidebarFor("", enGuide),
        footer: { message: "Proprietary software · documentation free to share", copyright: "© 2026 Ovira" },
      },
    },
    fa: {
      label: "فارسی",
      lang: "fa",
      dir: "rtl",
      title: "اویرا",
      description: "پنل OpenVPN و OpenConnect برای سرورهای لینوکس",
      themeConfig: {
        nav: [
          { text: "شروع کار", link: "/fa/start/" },
          { text: "مستندات", link: "/fa/use/" },
          { text: "پروتکل‌ها", link: "/fa/protocols/" },
          { text: "لایسنس", link: "/fa/use/license" },
          { text: "نسخه‌ها", link: "https://github.com/Erfan-XRay/Ovira/releases" },
        ],
        sidebar: sidebarFor("/fa", faGuide),
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

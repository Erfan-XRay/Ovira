import DefaultTheme from "vitepress/theme";
import "@fontsource-variable/hanken-grotesk";
import "@fontsource-variable/bricolage-grotesque";
import "@fontsource-variable/jetbrains-mono";
import "@fontsource-variable/vazirmatn";
import "./style.css";
import Layout from "./Layout.vue";
import Endpoint from "./components/Endpoint.vue";

export default {
  extends: DefaultTheme,
  Layout,
  enhanceApp({ app }) {
    app.component("Endpoint", Endpoint);
  },
};

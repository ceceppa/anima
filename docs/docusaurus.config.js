// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require("prism-react-renderer/themes/github");
const darkCodeTheme = require("prism-react-renderer/themes/dracula");

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: "Anima",
  tagline: "Animations are your friend",
  url: "https://anima.ceceppa.me",
  baseUrl: "/anima/",
  onBrokenLinks: "ignore",
  onBrokenMarkdownLinks: "warn",
  favicon: "img/favicon.ico",
  organizationName: "ceceppa",
  projectName: "anima",
  trailingSlash: false,
  presets: [
    [
      "classic",
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        debug: true,
        docs: {
          sidebarPath: require.resolve("./sidebars.js"),
          editUrl: "https://github.com/ceceppa/anima/docs/",
          showLastUpdateTime: true,
        },
        theme: {
          customCss: require.resolve("./src/css/custom.css"),
        },
        sitemap: {
          changefreq: "weekly",
          priority: 0.5,
        },
      }),
    ],
  ],
  plugins: [
    [
      "@docusaurus/plugin-content-docs",
      {
        id: "tutorials",
        path: "tutorials",
        routeBasePath: "tutorials",
        sidebarPath: require.resolve("./sidebars.js"),
      },
    ],
  ],
  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      navbar: {
        title: "Anima",
        logo: {
          alt: "Anima Logo",
          src: "/anima/img/logo.svg",
        },
        items: [
          {
            type: "doc",
            docId: "intro",
            position: "left",
            label: "Docs",
          },
          {
            to: "/anima/tutorials/intro",
            position: "left",
            label: "Tutorials",
          },
          {
            href: "https://github.com/ceceppa/anima",
            label: "GitHub",
            position: "right",
          },
          {
            href: "https://anima.ceceppa.me/demo/",
            label: "Demo",
            position: "right",
          },
        ],
      },
      footer: {
        style: "dark",
        links: [
          {
            title: "Docs",
            items: [
              {
                label: "Documentation",
                to: "/anima/docs/intro",
              },
              {
                label: "Tutorial",
                to: "/anima/tutorial/fundamentals",
              },
            ],
          },
          {
            title: "Community",
            items: [
              {
                label: "Discord",
                href: "https://discord.gg/zgtF3us5yN",
              },
              {
                label: "Twitter",
                href: "https://twitter.com/ceceppa",
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Ceceppa. Built with Docusaurus.`,
      },
      prism: {
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
        additionalLanguages: ["gdscript"],
      },
    }),
};

module.exports = config;

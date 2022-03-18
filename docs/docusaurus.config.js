// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require('prism-react-renderer/themes/github');
const darkCodeTheme = require('prism-react-renderer/themes/dracula');

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Anima',
  tagline: 'Animations are your friend',
  url: 'https://anima.ceceppa.me',
  baseUrl: '/docs/',
  onBrokenLinks: 'ignore',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/favicon.ico',
  organizationName: 'ceceppa',
  projectName: 'anima',

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          // Please change this to your repo.
          editUrl: 'https://github.com/ceceppa/anima/docs/',
        },
        blog: {
          showReadingTime: true,
          editUrl:
            'https://github.com/ceceppa/anima/docs/',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      navbar: {
        title: 'Anima',
        logo: {
          alt: 'Anima Logo',
          src: 'img/logo.svg',
        },
        items: [
          {
            type: 'doc',
            docId: 'intro',
            position: 'left',
            label: 'Docs',
          },
          {
            href: 'https://github.com/ceceppa/anima',
            label: 'GitHub',
            position: 'right',
          },
          {
            href: 'https://anima.ceceppa.me/demo/',
            label: 'Demo',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {
                label: 'Documentation',
                to: '/docs/docs/intro',
              },
              {
                label: 'Tutorial',
                to: '/docs/tutorial/fundamentals',
              },
            ],
          },
          {
            title: 'Community',
            items: [
              {
                label: 'Discord',
                href: 'https://discord.gg/zgtF3us5yN',
              },
              {
                label: 'Twitter',
                href: 'https://twitter.com/ceceppa',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Ceceppa. Built with Docusaurus.`,
      },
      prism: {
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
        additionalLanguages: ['gdscript']
      },
    }),
};

module.exports = config;

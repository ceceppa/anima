const { description } = require('../../package')

module.exports = {
  /**
   * Ref：https://v1.vuepress.vuejs.org/config/#title
   */
  title: 'Anima',
  /**
   * Ref：https://v1.vuepress.vuejs.org/config/#description
   */
  description: description,

  /**
   * Extra tags to be injected to the page HTML `<head>`
   *
   * ref：https://v1.vuepress.vuejs.org/config/#head
   */
  head: [
    ['meta', { name: 'theme-color', content: '#3eaf7c' }],
    ['meta', { name: 'apple-mobile-web-app-capable', content: 'yes' }],
    ['meta', { name: 'apple-mobile-web-app-status-bar-style', content: 'black' }],
    ['script', { src: 'https://plausible.io/js/plausible.js', "data-domain": "anima.ceceppa.me", defer: true, async: true }]
  ],
  /**
   * Theme configuration, here is the default theme configuration for VuePress.
   *
   * ref：https://v1.vuepress.vuejs.org/theme/default-theme-config.html
   */
  themeConfig: {
    repo: '',
    editLinks: false,
    docsDir: '',
    editLinkText: '',
    sidebarDepth: 3,
    lastUpdated: false,
    displayAllHeaders: true,
    nav: [
      {
        text: 'Documentation',
        link: '/doc/'
      },
      {
        text: 'Live demo',
        link: 'https://anima.ceceppa.me/demo',
      },
      {
        text: 'Source',
        link: 'https://github.com/ceceppa/anima'
      }
    ],
    sidebar: {
      '/doc/': [
        {
          title: 'Documentation',
          collapsable: false,
          children: [
            '',
            'anima',
            'anima-node',
            'anima-tween',
            'anima-node-properties',
            'custom-animations',
          ]
        }
      ],
    }
  },

  /**
   * Apply plugins，ref：https://v1.vuepress.vuejs.org/zh/plugin/
   */
  plugins: [
    '@vuepress/plugin-back-to-top',
    '@vuepress/plugin-medium-zoom',
  ]
}

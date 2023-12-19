import { themes as prismThemes } from 'prism-react-renderer';
import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Keep Learning',
  tagline: 'Invest in Your Future',
  // favicon: 'img/favicon.ico',

  // Set the production url of your site here
  url: 'https://darkless456.github.com',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'darkless456', // Usually your GitHub org/user name.
  projectName: 'darkless456.github.io', // Usually your repo name.

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          routeBasePath: '/docs',
          sidebarPath: './sidebars.ts',
          exclude: ['README.md'],
          lastVersion: 'current',
        },
        blog: {
          routeBasePath: '/blog',
          blogSidebarTitle: 'All posts',
          blogSidebarCount: 'ALL',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    // Replace with your project's social card
    // image: 'img/docusaurus-social-card.jpg',
    navbar: {
      title: 'darkless456',
      // logo: {
      //   alt: '',
      //   src: '',
      // },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'learningNoteSidebar',
          position: 'left',
          label: 'Docs',
        },
        {
          to: 'blog',
          label: 'Blog',
          position: 'left'
        },
        {
          type: 'docSidebar',
          sidebarId: 'favoriteSidebar',
          position: 'left',
          label: 'Favorite',
        },
        // {
        //   href: 'https://github.com/darkless456',
        //   label: 'GitHub',
        //   position: 'right',
        // },
        
      ],
    },
    // footer: {
    //   style: 'dark',
    //   links: [
    //   ],
    //   copyright: `Copyright © 2023 - ${new Date().getFullYear()} darkless456.`,
    // },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;

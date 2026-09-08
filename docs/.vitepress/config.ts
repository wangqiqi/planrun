import { defineConfig } from 'vitepress'
import type { DefaultTheme } from 'vitepress'

const sharedHead = [
  ['link', { rel: 'icon', href: '/planrun/logo.svg', type: 'image/svg+xml' }],
]

const sharedSocial: DefaultTheme.SocialLink[] = [
  { icon: 'github', link: 'https://github.com/wangqiqi/planrun' },
]

const versionNav: DefaultTheme.NavItemWithChildren = {
  text: 'v1.6.1',
  items: [
    { text: 'CHANGELOG', link: 'https://github.com/wangqiqi/planrun/blob/main/CHANGELOG.md' },
    { text: 'npm @planrun/bundle', link: 'https://www.npmjs.com/package/@planrun/bundle' },
  ],
}

/** Same structure in en/zh so the locale switcher keeps the current page path. */
function docSidebar(locale: 'en' | 'zh'): DefaultTheme.SidebarItem[] {
  const p = `/${locale}`
  if (locale === 'en') {
    return [
      {
        text: 'Getting started',
        items: [
          { text: 'Install', link: `${p}/install` },
          { text: 'Quickstart', link: `${p}/quickstart` },
          { text: 'Dogfood', link: `${p}/dogfood` },
          { text: 'Publish & install', link: `${p}/publish` },
        ],
      },
      {
        text: 'Workflow',
        items: [
          { text: 'Discipline', link: `${p}/discipline` },
          { text: 'Workflow guard', link: `${p}/workflow-guard` },
          { text: 'Hooks map', link: `${p}/workflow-hooks-map` },
          { text: 'Subagents', link: `${p}/subagents` },
        ],
      },
      {
        text: 'Reference',
        items: [
          { text: 'Super Cursor mapping', link: `${p}/mapping-from-super-cursor` },
          { text: 'Naming & packages', link: `${p}/naming` },
        ],
      },
    ]
  }
  return [
    {
      text: '入门',
      items: [
        { text: '安装', link: `${p}/install` },
        { text: '快速开始', link: `${p}/quickstart` },
        { text: 'Dogfood', link: `${p}/dogfood` },
        { text: '发布与用户安装', link: `${p}/publish` },
      ],
    },
    {
      text: '工作流',
      items: [
        { text: '纪律摘要', link: `${p}/discipline` },
        { text: 'Workflow guard', link: `${p}/workflow-guard` },
        { text: 'Hooks 映射', link: `${p}/workflow-hooks-map` },
        { text: 'Subagents', link: `${p}/subagents` },
      ],
    },
    {
      text: '参考',
      items: [
        { text: 'Super Cursor 映射', link: `${p}/mapping-from-super-cursor` },
        { text: '命名与包坐标', link: `${p}/naming` },
      ],
    },
  ]
}

const sharedTheme = {
  logo: { src: '/planrun/logo.svg', alt: 'PlanRun' },
  socialLinks: sharedSocial,
  search: { provider: 'local' as const },
}

export default defineConfig({
  title: 'PlanRun',
  description: 'DSH-native agent workflow SOP — plan, run, verify, release',

  base: '/planrun/',
  cleanUrls: true,
  lastUpdated: true,
  ignoreDeadLinks: true,

  srcExclude: ['_redirects/**'],

  head: sharedHead,

  locales: {
    en: {
      label: 'English',
      lang: 'en-US',
      link: '/en/',
      title: 'PlanRun',
      description: 'DSH-native agent workflow SOP — plan, run, verify, release',
      themeConfig: {
        ...sharedTheme,
        logoLink: '/en/',
        nav: [
          { text: 'Install', link: '/en/install' },
          { text: 'Quickstart', link: '/en/quickstart' },
          { text: 'Reference', link: '/en/mapping-from-super-cursor' },
          versionNav,
        ],
        sidebar: docSidebar('en'),
        footer: {
          message: 'MIT License',
          copyright: 'PlanRun — adapted from Super Cursor for DeepSeek Harness',
        },
        editLink: {
          pattern: 'https://github.com/wangqiqi/planrun/edit/main/docs/:path',
          text: 'Edit this page on GitHub',
        },
      },
    },
    zh: {
      label: '简体中文',
      lang: 'zh-CN',
      link: '/zh/',
      title: 'PlanRun',
      description: 'DeepSeek Harness 原生 Agent 工作流 SOP',
      themeConfig: {
        ...sharedTheme,
        logoLink: '/zh/',
        nav: [
          { text: '安装', link: '/zh/install' },
          { text: '快速开始', link: '/zh/quickstart' },
          { text: '参考', link: '/zh/mapping-from-super-cursor' },
          versionNav,
        ],
        sidebar: docSidebar('zh'),
        footer: {
          message: 'MIT License',
          copyright: 'PlanRun — 源自 Super Cursor，适配 DeepSeek Harness',
        },
        editLink: {
          pattern: 'https://github.com/wangqiqi/planrun/edit/main/docs/:path',
          text: '在 GitHub 上编辑此页',
        },
      },
    },
  },

  markdown: {
    theme: {
      light: 'github-light',
      dark: 'github-dark',
    },
  },
})

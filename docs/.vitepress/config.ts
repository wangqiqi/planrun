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

const enSidebar: DefaultTheme.SidebarItem[] = [
  {
    text: 'Getting started',
    items: [
      { text: 'Install', link: '/en/install' },
      { text: 'Quickstart', link: '/en/quickstart' },
      { text: 'Dogfood', link: '/en/dogfood' },
      { text: 'Publish & install', link: '/en/publish' },
    ],
  },
  {
    text: 'Workflow',
    items: [
      { text: 'Discipline', link: '/en/discipline' },
      { text: 'Workflow guard', link: '/en/workflow-guard' },
      { text: 'Hooks map', link: '/en/workflow-hooks-map' },
      { text: 'Subagents', link: '/en/subagents' },
    ],
  },
  {
    text: 'Reference',
    items: [
      { text: 'Super Cursor mapping', link: '/en/mapping-from-super-cursor' },
      { text: 'Naming & packages', link: '/en/naming' },
    ],
  },
]

const zhSidebar: DefaultTheme.SidebarItem[] = [
  {
    text: '入门',
    items: [
      { text: '安装', link: '/zh/install' },
      { text: '快速开始', link: '/zh/quickstart' },
    ],
  },
  {
    text: '工作流（English）',
    items: [
      { text: '纪律摘要', link: '/en/discipline' },
      { text: 'Workflow guard', link: '/en/workflow-guard' },
      { text: 'Hooks 映射', link: '/en/workflow-hooks-map' },
      { text: 'Subagents', link: '/en/subagents' },
    ],
  },
  {
    text: '参考（English）',
    items: [
      { text: 'Super Cursor 映射', link: '/en/mapping-from-super-cursor' },
      { text: '命名与包坐标', link: '/en/naming' },
      { text: 'Dogfood', link: '/en/dogfood' },
      { text: '发布与用户安装', link: '/en/publish' },
    ],
  },
]

export default defineConfig({
  title: 'PlanRun',
  description: 'DSH-native agent workflow SOP — plan, run, verify, release',

  base: '/planrun/',
  cleanUrls: true,
  lastUpdated: true,
  ignoreDeadLinks: true,

  head: sharedHead,

  locales: {
    root: {
      label: 'Language',
      lang: 'en-US',
      title: 'PlanRun',
      description: 'Choose documentation language',
      themeConfig: {
        logo: '/logo.svg',
        nav: [
          { text: 'English', link: '/en/' },
          { text: '简体中文', link: '/zh/' },
          versionNav,
        ],
        socialLinks: sharedSocial,
        footer: {
          message: 'MIT License',
          copyright: 'PlanRun',
        },
      },
    },
    en: {
      label: 'English',
      lang: 'en-US',
      link: '/en/',
      title: 'PlanRun',
      description: 'DSH-native agent workflow SOP — plan, run, verify, release',
      themeConfig: {
        logo: '/logo.svg',
        nav: [
          { text: 'Install', link: '/en/install' },
          { text: 'Quickstart', link: '/en/quickstart' },
          { text: 'Reference', link: '/en/mapping-from-super-cursor' },
          versionNav,
        ],
        sidebar: enSidebar,
        socialLinks: sharedSocial,
        footer: {
          message: 'MIT License',
          copyright: 'PlanRun — adapted from Super Cursor for DeepSeek Harness',
        },
        search: { provider: 'local' },
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
        logo: '/logo.svg',
        nav: [
          { text: '安装', link: '/zh/install' },
          { text: '快速开始', link: '/zh/quickstart' },
          { text: 'English docs', link: '/en/' },
          versionNav,
        ],
        sidebar: zhSidebar,
        socialLinks: sharedSocial,
        footer: {
          message: 'MIT License',
          copyright: 'PlanRun — 源自 Super Cursor，适配 DeepSeek Harness',
        },
        search: { provider: 'local' },
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

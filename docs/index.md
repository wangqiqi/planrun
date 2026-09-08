---
layout: false
title: PlanRun
---

<script setup>
import { onMounted } from 'vue'

onMounted(() => {
  const base = import.meta.env.BASE_URL
  const lang = navigator.language.toLowerCase().startsWith('zh') ? 'zh' : 'en'
  window.location.replace(`${base}${lang}/`)
})
</script>

<p style="padding:2rem;font-family:system-ui">Redirecting… <a href="./en/">English</a> · <a href="./zh/">简体中文</a></p>

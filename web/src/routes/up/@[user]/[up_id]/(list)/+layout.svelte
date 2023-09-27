<script context="module" lang="ts">
  const main_tabs = [
    { type: 'ch', href: '', icon: 'list', text: 'Chương tiết' },
    { type: 'gd', href: 'gd', icon: 'message', text: 'Thảo luận' },
    { type: 'up', href: 'up', icon: 'upload', text: 'Đăng tải' },
    { type: 'cf', href: 'cf', icon: 'tools', text: 'Quản lý' },
  ]
</script>

<script lang="ts">
  import { page } from '$app/stores'
  import Truncate from '$gui/atoms/Truncate.svelte'
  import Section from '$gui/sects/Section.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ustem } = data)

  $: dhtml = ustem.vintro
    .split('\n')
    .map((x) => `<p>${x}</p>`)
    .join('\n')
</script>

<article class="brief">
  <h1>{ustem.vname}</h1>

  <section class="intro">
    <Truncate html={dhtml} --line={3} />
  </section>
</article>

<Section tabs={main_tabs} _now={$page.data.ontab}>
  <slot />
</Section>

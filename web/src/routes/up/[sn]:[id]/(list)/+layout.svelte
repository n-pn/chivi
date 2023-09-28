<script context="module" lang="ts">
</script>

<script lang="ts">
  import { page } from '$app/stores'
  import Truncate from '$gui/atoms/Truncate.svelte'
  import Section from '$gui/sects/Section.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ustem, sroot } = data)

  $: dhtml = ustem.vintro
    .split('\n')
    .map((x) => `<p>${x}</p>`)
    .join('\n')

  $: tabs = [
    { type: 'ch', href: `${sroot}`, icon: 'list', text: 'Chương tiết' },
    { type: 'up', href: `${sroot}/up`, icon: 'upload', text: 'Đăng tải' },
    { type: 'cf', href: `${sroot}/cf`, icon: 'tools', text: 'Quản lý' },
    { type: 'gd', href: `${sroot}/gd`, icon: 'message', text: 'Thảo luận' },
  ]
</script>

<article class="brief">
  <h1>{ustem.vname}</h1>

  <section class="intro">
    <Truncate html={dhtml} --line={3} />
  </section>
</article>

<Section {tabs} _now={$page.data.ontab}>
  <slot />
</Section>

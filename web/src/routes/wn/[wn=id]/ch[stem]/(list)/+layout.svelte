<script lang="ts">
  import SeedList from './SeedList.svelte'

  import type { LayoutData } from './$types'
  import Section from '$gui/sects/Section.svelte'
  import { page } from '$app/stores'
  import { seed_path } from '$lib/kit_path'
  export let data: LayoutData

  $: sroot = seed_path(data.nvinfo.bslug, data.curr_seed.sname)

  $: tabs = [
    { type: 'ch', href: `${sroot}`, icon: 'list', text: 'Chương tiết' },
    { type: 'up', href: `${sroot}/up`, icon: 'upload', text: 'Đăng tải' },
    { type: 'cf', href: `${sroot}/cf`, icon: 'tools', text: 'Quản lý' },
    { type: 'lk', href: `${sroot}/lk`, icon: 'link', text: 'Liên kết' },
  ]
</script>

<SeedList {data} />

<Section {tabs} _now={$page.data.ontab}>
  <slot />
</Section>

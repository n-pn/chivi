<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import SeedList from './SeedList.svelte'

  import type { LayoutData } from './$types'
  import Section from '$gui/sects/Section.svelte'
  import { page } from '$app/stores'
  import { seed_path } from '$lib/kit_path'
  export let data: LayoutData

  $: sroot = seed_path(data.nvinfo.bslug, data.curr_seed.sname)
  $: can_edit = $_user.privi >= data.seed_data.edit_privi

  $: tabs = [
    { type: 'ch', href: `${sroot}`, icon: 'list', text: 'Chương tiết' },
    {
      type: 'up',
      href: `${sroot}/up`,
      icon: 'upload',
      text: 'Đăng tải',
      mute: !can_edit,
    },
    {
      type: 'cf',
      href: `${sroot}/cf`,
      icon: 'tools',
      text: 'Quản lý',
      mute: !can_edit,
    },
  ]
</script>

<SeedList {data} />

<Section {tabs} _now={$page.data.ontab}>
  <slot />
</Section>

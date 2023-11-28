<script lang="ts">
  import { page } from '$app/stores'

  // import { get_user } from '$lib/stores'
  // const _user = get_user()

  import { crumbs } from '$gui/global/Bcrumb.svelte'

  import SeedList from './SeedList.svelte'
  import Section from '$gui/sects/Section.svelte'

  import type { LayoutData } from './$types'
  export let data: LayoutData

  $: ({ crepo } = data)

  $: sroot = `/rd/${data.crepo.sroot}`

  $: tabs = [
    { type: 'ch', href: sroot, icon: 'list', text: 'Chương tiết' },
    {
      type: 'ul',
      href: `${sroot}/ul`,
      icon: 'upload',
      text: 'Đăng tải',
    },
    {
      type: 'cf',
      href: `${sroot}/cf`,
      icon: 'tools',
      text: 'Quản lý',
    },
  ]

  $: $crumbs = [
    { text: `[${crepo.vname || crepo.sroot}]`, href: `/ts/${crepo.sroot}` },
    { text: 'Chương tiết mục lục' },
  ]
</script>

<Section {tabs} _now={$page.data.ontab}>
  <slot />
</Section>

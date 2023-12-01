<script lang="ts">
  import { page } from '$app/stores'

  // import { get_user } from '$lib/stores'
  // const _user = get_user()

  import { crumbs } from '$gui/global/Bcrumb.svelte'

  import Section from '$gui/sects/Section.svelte'

  import type { LayoutData } from './$types'
  export let data: LayoutData

  $: ({ crepo } = data)

  $: $crumbs = [
    { text: `[${crepo.vname || crepo.sroot}]`, href: data.sroot },
    { text: 'Chương tiết mục lục' },
  ]

  $: tabs = [
    { type: 'ch', href: data.sroot, icon: 'list', text: 'Chương tiết' },
    {
      type: 'ul',
      href: `${data.sroot}/+text`,
      icon: 'upload',
      text: 'Thêm text',
    },
  ]
</script>

<Section {tabs} _now={$page.data.ontab}>
  <slot />
</Section>

<script lang="ts">
  import { page } from '$app/stores'

  // import { get_user } from '$lib/stores'
  // const _user = get_user()

  import Section from '$gui/sects/Section.svelte'
  import UserMemo from '$gui/shared/wnovel/UserMemo.svelte'

  import type { LayoutData } from './$types'
  export let data: LayoutData

  $: ({ crepo, rmemo } = data)

  $: tabs = [
    { type: 'ch', href: data.sroot, icon: 'list', text: 'Mục lục' },
    {
      type: '+text',
      href: `${data.sroot}/+text`,
      icon: 'upload',
      text: 'Thêm text',
    },
  ]
</script>

<UserMemo {crepo} {rmemo} />

<Section {tabs} _now={$page.data.ontab}><slot /></Section>

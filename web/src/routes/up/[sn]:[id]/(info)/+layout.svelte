<script lang="ts">
  import { page } from '$app/stores'

  import Section from '$gui/sects/Section.svelte'
  import UserMemo from '$gui/shared/wnovel/UserMemo.svelte'

  import UpstemFull from '$gui/parts/upstem/UpstemFull.svelte'

  import type { LayoutData } from './$types'
  export let data: LayoutData

  $: ({ ustem, sroot, crepo, rmemo } = data)

  $: tabs = [
    { type: 'ch', href: `${sroot}`, icon: 'list', text: 'Mục lục' },
    { type: 'dl', href: `${sroot}/dl`, icon: 'download', text: 'Tải xuống' },
    { type: 'gd', href: `${sroot}/gd`, icon: 'message', text: 'Thảo luận' },
    { type: 'st', href: `${sroot}/st`, icon: 'activity', text: 'Thay đổi' },
  ]
</script>

<UpstemFull {ustem} binfo={data.binfo || null} />

<UserMemo {crepo} {rmemo} conf_path={`/up/+proj?id=${ustem.id}`} />

<Section {tabs} _now={$page.data.ontab || 'ch'}>
  <slot />
</Section>

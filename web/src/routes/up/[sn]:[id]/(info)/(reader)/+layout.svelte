<script lang="ts">
  import { page } from '$app/stores'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import Section from '$gui/sects/Section.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ustem, sroot } = data)

  $: tabs = [
    { type: 'ch', href: `${sroot}`, icon: 'list', text: 'Chương tiết' },
    { type: 'dl', href: `${sroot}/dl`, icon: 'download', text: 'Tải xuống' },
    { type: 'gd', href: `${sroot}/gd`, icon: 'message', text: 'Thảo luận' },
    { type: 'st', href: `${sroot}/st`, icon: 'activity', text: 'Thay đổi' },
  ]
</script>

<Section {tabs} _now={$page.data.ontab}>
  <slot />
</Section>

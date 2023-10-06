<script lang="ts">
  import { page } from '$app/stores'
  import Section from '$gui/sects/Section.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: sroot = data.sroot + '/su'

  $: tabs = [
    { type: 'cf', href: `${sroot}/`, icon: 'settings', text: 'Thiết đặt' },
    { type: 'rm', href: `${sroot}/redo`, icon: 'eraser', text: 'Tẩy xóa' },
    { type: 'lg', href: `${sroot}/xlog`, icon: 'lock-open', text: 'Mở khóa' },
  ]
</script>

<Section {tabs} _now={$page.data.ontab}>
  <slot />
</Section>

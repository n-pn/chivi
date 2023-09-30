<script lang="ts">
  import { page } from '$app/stores'
  import Section from '$gui/sects/Section.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: sroot = data.sroot + '/ul'

  $: tabs = [
    { type: 'zh', href: `${sroot}/`, icon: 'upload', text: 'Text gốc' },
    { type: 'tl', href: `${sroot}/tran`, icon: 'language', text: 'Bản dịch' },
    { type: 'md', href: `${sroot}/data`, icon: 'tree', text: 'Ngữ pháp' },
    { type: 'vd', href: `${sroot}/term`, icon: 'package', text: 'Từ điển' },
  ]
</script>

<Section {tabs} _now={$page.data.ontab}>
  <slot />
</Section>

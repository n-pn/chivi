<script lang="ts">
  import { crumbs } from '$gui/global/Bcrumb.svelte'
  import Section from '$gui/sects/Section.svelte'

  $: $crumbs = [{ text: 'Dịch nhanh', href: `/qt` }]

  const tabs = [
    { type: 'index', href: '/qt', icon: 'bolt', text: 'Dịch câu' },
    {
      type: 'multi',
      href: '/qt/multi',
      icon: 'article',
      text: 'Dịch đoạn văn',
    },
    {
      type: 'batch',
      href: '/qt/batch',
      icon: 'language',
      text: 'Dịch văn bản',
    },
  ]
</script>

<Section {tabs}>
  <slot />
</Section>

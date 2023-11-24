<script lang="ts">
  import { crumbs } from '$gui/global/Bcrumb.svelte'
  import Section from '$gui/sects/Section.svelte'

  $: $crumbs = [{ text: 'Dịch nhanh', href: `/qt` }]

  const tabs = [
    { type: 'sent', href: '/qt', icon: 'bolt', text: 'Dịch câu' },
    { type: 'post', href: '/qt/multi', icon: 'article', text: 'Dịch bài' },
  ]
</script>

<Section {tabs}>
  <slot />
</Section>

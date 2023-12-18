<script lang="ts">
  import WnNavMenu from '../../WnNavMenu.svelte'

  import Section from '$gui/sects/Section.svelte'
  import { crumbs } from '$gui/global/Bcrumb.svelte'

  const tabs = [
    { type: 'index', href: '/wn/crits', icon: 'stars', text: 'Đánh giá' },
    {
      type: 'liked',
      href: '/wn/crits/liked',
      icon: 'heart',
      text: 'Ưa thích',
    },
  ]

  $: $crumbs = [
    { text: 'Thư viện truyện chữ', href: `/wn` },
    { text: 'Đánh giá truyện', href: `/wn/crits` },
  ]
</script>

<WnNavMenu tab="/wn/crits" />

<Section {tabs}>
  <slot />
</Section>

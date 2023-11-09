<script lang="ts">
  import WnNavMenu from '../WnNavMenu.svelte'

  import Section from '$gui/sects/Section.svelte'
  import { crumbs } from '$gui/global/Bcrumb.svelte'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  $: privi = $_user.privi
  const sroot = '/wn/crits'

  const tabs = [
    { type: 'home', href: sroot, icon: 'stars', text: 'Đánh giá' },
    {
      type: 'like',
      href: sroot + `/liked`,
      icon: 'heart',
      text: 'Ưa thích',
      mute: privi < 0,
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

<slot />

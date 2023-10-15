<script lang="ts">
  import Section from '$gui/sects/Section.svelte'
  import { crumbs } from '$gui/global/Bcrumb.svelte'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  $: privi = $_user.privi
  const sroot = '/wn/lists'

  const tabs = [
    { type: 'home', href: sroot, icon: 'bookmarks', text: 'Thư đơn' },
    {
      type: 'like',
      href: sroot + `/liked`,
      icon: 'heart',
      text: 'Ưa thích',
      mute: privi < 0,
    },
    {
      type: 'mine',
      href: sroot + `/owned`,
      icon: 'ballpen',
      text: 'Của tôi',
      mute: privi < 0,
    },
    {
      type: '+new',
      href: sroot + `/+list`,
      icon: 'circle-plus',
      text: 'Tạo mới',
      mute: privi < 0,
    },
  ]

  $: $crumbs = [
    { text: 'Thư viện truyện chữ', href: `/wn` },
    { text: 'Thư đơn', href: `/wn/lists` },
  ]
</script>

<Section {tabs}>
  <slot />
</Section>

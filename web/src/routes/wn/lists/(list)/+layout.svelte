<script lang="ts">
  import Section from '$gui/sects/Section.svelte'
  import { crumbs } from '$gui/global/Bcrumb.svelte'

  const tabs = [
    { type: 'index', href: '/wn/lists', icon: 'list', text: 'Danh sách' },

    {
      type: 'owned',
      href: `/wn/lists/owned`,
      icon: 'ballpen',
      text: 'Của tôi',
    },
    {
      type: '+new',
      href: `/wn/lists/+list`,
      icon: 'circle-plus',
      text: 'Tạo mới',
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

<script lang="ts">
  import Section from '$gui/sects/Section.svelte'

  const tabs = [
    { type: '', href: '/uc', icon: 'users', text: 'Tổng hợp' },
    { type: 'crits', href: '/uc/crits', icon: 'stars', text: 'Đánh giá' },
    { type: 'lists', href: '/uc/lists', icon: 'bookmarks', text: 'Thư đơn' },
  ]
</script>

<Section {tabs}><slot /></Section>

<script lang="ts">
  import Section from '$gui/sects/Section.svelte'

  const tabs = [
    { type: '', href: '/br', icon: 'stars', text: 'Tổng hợp' },
    { type: 'users', href: '/br/users', icon: 'users', text: 'Người dùng' },
    {
      type: 'ysapp',
      href: '/br/ysapp',
      icon: 'letter-y',
      text: 'Ưu thư võng',
    },
  ]
</script>

<Section {tabs}><slot /></Section>

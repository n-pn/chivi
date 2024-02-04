<script lang="ts">
  import Section from '$gui/sects/Section.svelte'

  const tabs = [
    { type: 'index', href: '/uc/lists', icon: 'list', text: 'Danh sách' },

    {
      type: 'owned',
      href: `/uc/lists/owned`,
      icon: 'ballpen',
      text: 'Của tôi',
    },
    {
      type: '+new',
      href: `/uc/lists/+list`,
      icon: 'circle-plus',
      text: 'Tạo mới',
    },
  ]
</script>

<Section {tabs}><slot /></Section>

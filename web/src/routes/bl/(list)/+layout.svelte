<script lang="ts">
  import Section from '$gui/sects/Section.svelte'

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
</script>

<Section {tabs}><slot /></Section>

<script lang="ts">
  import { page } from '$app/stores'
  import { crumbs } from '$gui/global/Bcrumb.svelte'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import Section from '$gui/sects/Section.svelte'

  $: privi = $_user.privi

  const tabs = [
    { type: 'home', href: `/rm`, icon: 'world', text: 'Danh sách' },
    {
      type: 'like',
      href: `/rm/liked`,
      icon: 'star',
      text: 'Đã đánh dấu',
      mute: privi < 0,
    },
    {
      type: '+new',
      href: `/rm/+stem`,
      icon: 'square-plus',
      text: 'Thêm mới',
      mute: privi < 1,
    },
  ]

  $: $crumbs = [{ text: 'Nguồn liên kết nhúng', href: '/rm' }]
</script>

<Section {tabs}>
  <slot />
</Section>

<footer>Hướng dẫn: TODO!</footer>

<style lang="scss">
  footer {
    @include flex-ca;
    padding: 0.75rem;
    font-style: italic;
  }
</style>

<script lang="ts">
  import { page } from '$app/stores'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import Section from '$gui/sects/Section.svelte'

  $: privi = $_user.privi

  const tabs = [
    { type: 'home', href: `/rm`, icon: 'world', text: 'Danh sách' },
    {
      type: 'like',
      href: `/rm/liked`,
      icon: 'heart',
      text: 'Ưa thích',
      mute: true,
    },
    {
      type: '+new',
      href: `/rm/+stem`,
      icon: 'file-plus',
      text: 'Tạo mới',
      mute: privi < 1,
    },
  ]
</script>

<Section {tabs} _now={$page.data.ontab}>
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

<script lang="ts">
  import { page } from '$app/stores'
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { crumbs } from '$gui/global/Bcrumb.svelte'

  import Section from '$gui/sects/Section.svelte'

  $: privi = $_user.privi
  const tabs = [
    { type: 'home', href: `/up`, icon: 'album', text: 'Danh sách' },
    {
      type: 'like',
      href: `/up/liked`,
      icon: 'heart',
      text: 'Ưa thích',
      mute: privi < 0,
    },
    {
      type: 'mine',
      href: `/up/owned`,
      icon: 'at',
      text: 'Của bạn',
      mute: privi < 0,
    },
    {
      type: '+new',
      href: `/up/+proj`,
      icon: 'file-plus',
      text: 'Tạo mới',
      mute: privi < 1,
    },
  ]

  $: $crumbs = [{ text: 'Sưu tầm cá nhân', href: `/up` }]
</script>

<Section {tabs} _now={$page.data.ontab}>
  <slot />
</Section>

<footer>...</footer>

<style lang="scss">
  footer {
    height: 2rem;
    @include flex-ca;
    // padding: 0.75rem;
    // font-style: italic;
  }
</style>

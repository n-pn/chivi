<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import Section from '$gui/sects/Section.svelte'

  $: privi = $_user.privi
  const tabs = [
    { type: '', href: `/up`, icon: 'album', text: 'Danh sách' },
    {
      type: 'owned',
      href: `/up/owned`,
      icon: 'ballpen',
      text: 'Của bạn',
      mute: privi < 0,
    },
    {
      type: '+proj',
      href: `/up/+proj`,
      icon: 'file-plus',
      text: 'Tạo mới',
      mute: privi < 1,
    },
  ]
</script>

<Section {tabs}>
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

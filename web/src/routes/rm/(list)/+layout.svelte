<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import Section from '$gui/sects/Section.svelte'

  $: privi = $_user.privi

  const tabs = [
    { type: 'index', href: `/rm`, icon: 'world', text: 'Danh sách' },

    {
      type: '+new',
      href: `/rm/+stem`,
      icon: 'square-plus',
      text: 'Thêm mới',
      mute: privi < 1,
    },
  ]
</script>

<Section {tabs}><slot /></Section>

<style lang="scss">
  footer {
    @include flex-ca;
    padding: 0.75rem;
    font-style: italic;
  }
</style>

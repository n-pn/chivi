<script lang="ts">
  import { page } from '$app/stores'

  import Section from '$gui/sects/Section.svelte'

  const tabs = [
    { type: 'list', href: `/up`, icon: 'list', text: 'Danh sách' },
    { type: 'edit', href: `/up/+proj`, icon: 'file-plus', text: 'Tạo mới' },
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

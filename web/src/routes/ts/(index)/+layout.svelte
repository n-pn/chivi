<script lang="ts">
  import { page } from '$app/stores'
  import SIcon from '$gui/atoms/SIcon.svelte'

  import Section from '$gui/sects/Section.svelte'

  $: tabs = [
    { type: 'index', href: '/ts', icon: 'list', text: 'Khám phá' },
    {
      type: 'track',
      href: '/ts/track',
      icon: 'notebook',
      text: 'Đang theo dõi',
    },
    {
      type: 'rdlog',
      href: '/ts/rdlog',
      icon: 'history',
      text: 'Lịch sử đọc',
    },
  ]
  const links = [
    ['/wn', 'books', 'Thư viện chung'],
    ['/up', 'album', 'Sưu tầm riêng'],
    ['/rm', 'world', 'Liên kết nhúng'],
  ]
</script>

<nav class="nav-list">
  {#each links as [href, icon, text]}
    <a {href} class="nav-link">
      <SIcon class="u-show-pm" name={icon} />
      <span>{text}</span>
    </a>
  {/each}
</nav>

<Section {tabs} _now={$page.data.ontab}><slot /></Section>

<style lang="scss">
  .nav-list {
    margin: 1.5rem 0 0.75rem;
  }
</style>

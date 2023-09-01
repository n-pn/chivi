<script lang="ts">
  import { page } from '$app/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  const links = [
    ['/books', 'books', 'Tủ truyện'],
    ['/crits', 'stars', 'Đánh giá'],
    ['/lists', 'bookmarks', 'Thư đơn'],
  ]

  export let user = $page.data.viuser.uname
  export let curr = '/'
</script>

<nav class="nav-list">
  {#each links as [href, icon, text]}
    <a href="/@{user}{href}" class="nav-link" class:_active={curr == href}>
      <SIcon class="show-ts" name={icon} />
      <span>{text}</span>
    </a>
  {/each}
</nav>

<style lang="scss">
  .nav-list {
    margin: 1rem 0;
  }
</style>

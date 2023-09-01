<script lang="ts">
  import WncritList from '$gui/parts/review/WncritList.svelte'
  import NavLink from '../NavLink.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ viuser, vi, sort = 'utime' } = data)
</script>

<NavLink curr="/crits" />

<article class="article island">
  <h2 class="title">Tổng hợp đánh giá truyện của @{viuser.uname}</h2>

  <WncritList {vi} _sort={sort} show_book={true} view_head={false} />
</article>

<style lang="scss">
  .title {
    margin-top: 0.5rem;
    margin-bottom: 1.5rem;
    @include margin-x(var(--gutter));
  }
</style>

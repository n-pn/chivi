<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import WninfoList from '$gui/parts/wninfo/WninfoList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ books } = data)

  const links = [
    ['/gd', 'message', 'Diễn đàn'],
    ['/wn', 'books', 'Truyện chữ'],
    ['/wn/crits', 'stars', 'Đánh giá'],
    ['/wn/lists', 'bookmarks', 'Thư đơn'],
    ['/sp/qtran', 'bolt', 'Dịch nhanh'],
  ]
</script>

<nav class="nav-list">
  {#each links as [href, icon, text]}
    <a {href} class="nav-link">
      <SIcon class="u-show-pl" name={icon} />
      <span>{text}</span>
    </a>
  {/each}
</nav>

<section class="list">
  <header class="head">
    <h3 class="text">Truyện vừa xem</h3>
    <a class="link" href="/wn">Xem tất cả</a>
  </header>

  <WninfoList books={books.recent} />
</section>

<section class="list">
  <header class="head">
    <h3 class="text">Truyện mới cập nhật</h3>
    <a class="link" href="/wn?order=update">Xem tất cả</a>
  </header>
  <WninfoList books={books.update} />
</section>

<section class="list">
  <header class="head">
    <h3 class="text">Tổng hợp cho điểm</h3>
    <a class="link" href="/wn?order=weight">Xem tất cả</a>
  </header>

  <WninfoList books={books.weight} />
</section>

<!-- <section class="list">
  <header class="head">
    <h3 class="text">Đánh giá mới nhất</h3>
    <a class="link" href="/wn/crits">Xem tất cả</a>
  </header>

  <div class="ycrit-list">
    {#each data.ycrits as crit}
      {@const book = data.books[crit.wn_id]}
      <YscritCard {crit} {book} />
    {/each}
  </div>
</section>

<section class="list">
  <header class="head">
    <h3 class="text">Thư đơn mới nhất</h3>
    <a class="link" href="/wn/lists">Xem tất cả</a>
  </header>

  <div class="ylist-list">
    {#each data.ylists as list}
      <YslistCard {list} />
    {/each}
  </div>
</section> -->
<style lang="scss">
  .nav-link {
    margin-top: 1.5rem;
  }

  .list {
    margin-top: 1rem;
    margin-bottom: 0.75rem;
  }

  .head {
    display: flex;
    align-items: baseline;
    margin-bottom: 0.75rem;
  }

  .text {
    flex: 1;
  }

  .link {
    @include fgcolor(tert);
    font-style: italic;
    &:hover {
      @include fgcolor(primary, 5);
    }
  }
</style>

<script lang="ts">
  import NvinfoList from '$gui/parts/nvinfo/NvinfoList.svelte'
  // import YscritCard from '$gui/parts/review/YscritCard.svelte'
  // import YslistCard from '$gui/parts/review/YslistCard.svelte'

  import type { PageData } from './$types'
  export let data: PageData
</script>

<section class="list">
  <header class="head">
    <h3 class="text">Truyện vừa xem</h3>
    <a class="link" href="/wn">Xem tất cả</a>
  </header>

  <NvinfoList books={data.books.recent} />
</section>

<section class="list">
  <header class="head">
    <h3 class="text">Truyện mới cập nhật</h3>
    <a class="link" href="/wn?order=update">Xem tất cả</a>
  </header>
  <NvinfoList books={data.books.update} />
</section>

<section class="list">
  <header class="head">
    <h3 class="text">Tổng hợp cho điểm</h3>
    <a class="link" href="/wn?order=weight">Xem tất cả</a>
  </header>

  <NvinfoList books={data.books.weight} />
</section>

<!-- <section class="list">
  <header class="head">
    <h3 class="text">Đánh giá mới nhất</h3>
    <a class="link" href="/crits">Xem tất cả</a>
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
    <a class="link" href="/lists">Xem tất cả</a>
  </header>

  <div class="ylist-list">
    {#each data.ylists as list}
      <YslistCard {list} />
    {/each}
  </div>
</section> -->
<style lang="scss">
  .list {
    margin-top: 1.5rem;
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

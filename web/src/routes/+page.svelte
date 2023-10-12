<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import WninfoList from '$gui/parts/wninfo/WninfoList.svelte'

  import RmstemCard from '$gui/parts/rmstem/RmstemCard.svelte'
  import UpstemCard from '$gui/parts/upstem/UpstemCard.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ books } = data)

  const links = [
    ['/gd', 'message', 'Diễn đàn'],
    ['/wn', 'books', 'Truyện chữ'],
    ['/up', 'album', 'Sưu tầm'],
    ['/rm', 'world', 'Nhúng ngoài'],
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
<article class="article island">
  <section class="list">
    <header class="head">
      <h3 class="text">Thư viện truyện chữ</h3>
      <a class="link" href="/wn">Xem tất cả</a>
    </header>

    <WninfoList {books} />
  </section>

  <section class="list">
    <header class="head">
      <h3 class="text">Sưu tầm cá nhân</h3>
      <a class="link" href="/up">Xem tất cả</a>
    </header>
    {#each data.ustems as ustem}
      <UpstemCard {ustem} />
    {:else}
      <div class="u-empty-sm">Danh sách trống</div>
    {/each}
  </section>

  <section class="list">
    <header class="head">
      <h3 class="text">Liên kết nhúng ngoài</h3>
      <a class="link" href="/rm">Xem tất cả</a>
    </header>
    {#each data.rstems as rstem}
      <RmstemCard {rstem} />
    {:else}
      <div class="u-empty-sm">Danh sách trống</div>
    {/each}
  </section>
</article>

<!--
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
</section> -->

<style lang="scss">
  .nav-list {
    margin-bottom: 0.75rem;
  }

  .list {
    margin: 0.75rem 0;
    padding-bottom: 1.5rem;

    &:not(:last-child) {
      @include border(--bd-soft, $loc: bottom);
    }
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

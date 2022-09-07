<script context="module" lang="ts">
  export async function load({ stuff }) {
    const books = await stuff.api.call('/api/ranks/brief')
    const { ycrits, ylists } = await stuff.api.call('/_ys')

    const topbar = {
      right: [
        ['Dịch nhanh', 'bolt', { href: '/qtran', show: 'tm' }],
        ['Đánh giá', 'stars', { href: '/crits', show: 'tm' }],
      ],
      search: '',
    }

    return { props: { ...books, ycrits, ylists }, stuff: { topbar } }
  }
</script>

<script lang="ts">
  import NvinfoList from '$gui/parts/nvinfo/NvinfoList.svelte'
  import YscritCard from '$gui/parts/yousuu/YscritCard.svelte'
  import YslistCard from '$gui/parts/yousuu/YslistCard.svelte'

  export let recent: CV.Nvinfo[] = []
  export let update: CV.Nvinfo[] = []
  export let weight: CV.Nvinfo[] = []
  export let ycrits: CV.Yscrit[] = []
  export let ylists: CV.Yslist[] = []
</script>

<svelte:head>
  <title>Chivi - Truyện tàu dịch máy</title>
</svelte:head>

<section class="list">
  <header class="head">
    <h3 class="text">Truyện vừa xem</h3>
    <a class="link" href="/books">Xem tất cả</a>
  </header>

  <NvinfoList books={recent} />
</section>

<section class="list">
  <header class="head">
    <h3 class="text">Truyện mới cập nhật</h3>
    <a class="link" href="/books?order=update">Xem tất cả</a>
  </header>
  <NvinfoList books={update} />
</section>

<section class="list">
  <header class="head">
    <h3 class="text">Tổng hợp cho điểm</h3>
    <a class="link" href="/books?order=weight">Xem tất cả</a>
  </header>

  <NvinfoList books={weight} />
</section>

<section class="list">
  <header class="head">
    <h3 class="text">Đánh giá mới nhất</h3>
    <a class="link" href="/crits">Xem tất cả</a>
  </header>

  <div class="ycrit-list">
    {#each ycrits as crit}
      <YscritCard {crit} />
    {/each}
  </div>
</section>

<section class="list">
  <header class="head">
    <h3 class="text">Thư đơn mới nhất</h3>
    <a class="link" href="/lists">Xem tất cả</a>
  </header>

  <div class="ylist-list">
    {#each ylists as list}
      <YslistCard {list} />
    {/each}
  </div>
</section>

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

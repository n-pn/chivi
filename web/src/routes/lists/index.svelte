<script context="module" lang="ts">
  import { page } from '$app/stores'

  export async function load({ fetch, url: { searchParams } }) {
    const api_url = `/api/yslists?${searchParams.toString()}&lm=10`
    const api_res = await fetch(api_url)
    return await api_res.json()
  }

  const sorts = { score: 'Nổi bật', likes: 'Ưa thích', utime: 'Đổi mới' }
</script>

<script lang="ts">
  import { topbar } from '$lib/stores'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import YslistCard from '$gui/parts/yslist/YslistCard.svelte'

  export let lists = []
  export let pgidx = 1
  export let pgmax = 1

  $: pager = new Pager($page.url, { _s: 'score', pg: 1 })
  $: _sort = pager.get('_s')

  $: topbar.set({
    left: [['Thư đơn', 'bookmarks', { href: '/lists' }]],
    right: [['Đánh giá', 'stars', { href: '/crits', show: 'tm' }]],
  })
</script>

<svelte:head>
  <title>Thư đơn - Chivi</title>
</svelte:head>

<article class="article">
  <div class="sorts">
    <span class="h2 -label">Thư đơn</span>
    {#each Object.entries(sorts) as [sort, name]}
      <a
        href={pager.gen_url({ _s: sort, pg: 1 })}
        class="-sort"
        class:_active={sort == _sort}>{name}</a>
    {/each}
  </div>

  <div class="lists">
    {#each lists as list}
      <YslistCard {list} />
    {/each}

    <footer class="pagi">
      <Mpager {pager} {pgidx} {pgmax} />
    </footer>
  </div>
</article>

<style lang="scss">
  .article {
    @include margin-y(var(--gutter));
    > * {
      @include padding-x(var(--gutter-large));
    }
  }

  .sorts {
    line-height: 2rem;
    height: 2rem;
    @include flex($gap: 0.5rem);
    @include border(--bd-main, $loc: bottom);

    .-label {
      flex: 1;
      // font-weight: 500;
      // @include ftsize(xl);
    }

    .-sort {
      @include fgcolor(tert);
      padding: 0 0.125rem;
      height: 2rem;

      &._active {
        border-bottom: 2px solid color(primary, 5);
        @include fgcolor(primary, 5);
      }
    }
  }

  .pagi {
    margin: 0.75rem 0;
  }
</style>

<script context="module" lang="ts">
  import { page } from '$app/stores'

  export async function load({ fetch, url: { searchParams } }) {
    const api_url = `/api/yscrits?${searchParams.toString()}&lm=10`
    const api_res = await fetch(api_url)
    return await api_res.json()
  }

  const sorts = { utime: 'Gần nhất', score: 'Nổi bật' }
</script>

<script lang="ts">
  import { topbar } from '$lib/stores'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import YscritCard from '$gui/sects/yscrit/YscritCard.svelte'
  export let crits = []
  export let pgidx = 1
  export let pgmax = 1

  $: pager = new Pager($page.url, { sort: 'utime', pg: 1 })
  $: _sort = pager.get('sort')

  $: topbar.set({ left: [['Đánh giá', 'stars', { href: '/crits' }]] })
</script>

<svelte:head>
  <title>Đánh giá - Chivi</title>
</svelte:head>

<div class="sorts" id="sorts">
  <span class="h3 -label">Đánh giá</span>
  {#each Object.entries(sorts) as [sort, name]}
    <a
      href={pager.gen_url({ sort, pg: 1 })}
      class="-sort"
      class:_active={sort == _sort}>{name}</a>
  {/each}
</div>

<div class="crits">
  {#each crits as crit}
    <YscritCard {crit} view_all={crit.vhtml.length < 640} />
  {/each}

  <footer class="pagi">
    <Mpager {pager} {pgidx} {pgmax} />
  </footer>
</div>

<style lang="scss">
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
</style>

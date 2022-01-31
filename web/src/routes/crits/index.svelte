<script context="module">
  import { page } from '$app/stores'
  import { data as appbar } from '$sects/Appbar.svelte'

  export async function load({ fetch, url: { searchParams } }) {
    const res = await fetch(`/api/crits?${searchParams.toString()}&take=10`)

    appbar.set({ left: [['Đánh giá', 'stars', '/crits']] })
    return { props: await res.json() }
  }

  const sorts = { mtime: 'Gần nhất', stars: 'Cho điểm', likes: 'Ưa thích' }
</script>

<script>
  import Mpager, { Pager } from '$molds/Mpager.svelte'
  import Yscrit from '$parts/Yscrit.svelte'

  export let crits = []
  export let pgidx = 1
  export let pgmax = 1

  $: pager = new Pager($page.url, { sort: 'mtime', page: 1 })
  $: _sort = pager.get('sort')
</script>

<svelte:head>
  <title>Đánh giá - Chivi</title>
</svelte:head>

<div class="sorts" id="sorts">
  <span class="h3 -label">Đánh giá</span>
  {#each Object.entries(sorts) as [sort, name]}
    <a
      href={pager.make_url({ sort, page: 1 })}
      class="-sort"
      class:_active={sort == _sort}>{name}</a>
  {/each}
</div>

<div class="crits">
  {#each crits as crit}
    <Yscrit {crit} view_all={crit.vhtml.length < 640} />
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

<script context="module">
  export async function load({ fetch, stuff, url }) {
    const page = +url.searchParams.get('pg') || 1
    const sort = url.searchParams.get('sort') || 'stars'

    const qs = `pg=${page}&lm=10&sort=${sort}`
    const res = await fetch(`/api/crits?book=${stuff.nvinfo.id}&${qs}`)

    console.log(res)

    const data = await res.json()
    if (res.ok) data.props._sort = sort

    return data
  }

  const sorts = {
    stars: 'Cho điểm',
    likes: 'Ưa thích',
    mtime: 'Gần nhất',
  }
</script>

<script>
  import { page } from '$app/stores'

  import Mpager, { Pager } from '$molds/Mpager.svelte'
  import Yscrit from '$parts/Yscrit.svelte'
  import BookPage from './_layout/BookPage.svelte'

  export let crits = []
  export let pgidx = 1
  export let pgmax = 1
  export let _sort

  $: pager = new Pager($page.url, { sort: 'stars', pg: 1 })
</script>

<BookPage nvtab="crits">
  <article class="m-article">
    <div class="sorts" id="sorts">
      <span class="h3 -label">Đánh giá</span>
      {#each Object.entries(sorts) as [sort, name]}
        <a
          href={pager.make_url({ sort, pg: 1 })}
          class="-sort"
          class:_active={sort == _sort}>{name}</a>
      {/each}
    </div>

    <div class="crits">
      {#each crits as crit}
        <Yscrit {crit} show_book={false} view_all={crit.vhtml.length < 640} />
      {/each}

      <footer class="pagi">
        {#if crits.length > 0}
          <Mpager {pager} {pgidx} {pgmax} />
        {/if}
      </footer>
    </div>
  </article>
</BookPage>

<style lang="scss">
  article {
    @include bps(margin-left, 0rem, 0.1rem, 1.5rem, 2rem);
    @include bps(margin-right, 0rem, 0.1rem, 1.5rem, 2rem);
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
</style>

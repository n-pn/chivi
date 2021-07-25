<script context="module">
  export async function load({ fetch, page: { query } }) {
    const res = await fetch(`/api/crits?${query.toString()}`)
    return { props: { ...(await res.json()) } }
  }

  const sorts = {
    mtime: 'Gần nhất',
    stars: 'Cho điểm',
    likes: 'Ưa thích',
  }

  const _navi = { replace: true, scrollto: '#sorts' }
</script>

<script>
  import { page } from '$app/stores'

  import Mpager, { Pager, navigate } from '$molds/Mpager.svelte'
  import Yscrit from '$parts/Yscrit.svelte'
  import Vessel from '$sects/Vessel.svelte'

  export let crits = []
  export let pgidx = 1
  export let pgmax = 1

  $: pager = new Pager($page.path, $page.query, { sort: 'mtime', page: 1 })
  $: _sort = $page.query.get('sort') || 'mtime'
</script>

<Vessel>
  <article>
    <div class="sorts" id="sorts">
      <span class="h3 -label">Đánh giá</span>
      {#each Object.entries(sorts) as [sort, name]}
        <a
          href={pager.url({ sort, page: 1 })}
          class="-sort"
          use:navigate={_navi}
          class:_active={sort == _sort}>{name}</a>
      {/each}
    </div>

    <div class="crits">
      {#each crits as crit}
        <Yscrit {crit} view_all={crit.vhtml.length < 1000} />
      {/each}

      <footer class="pagi">
        {#if crits.length > 0}
          <Mpager {pager} {pgidx} {pgmax} {_navi} />
        {/if}
      </footer>
    </div>
  </article>
</Vessel>

<style lang="scss">
  article {
    @include fluid(margin-left, 0rem, 0.1rem, 1.5rem, 2rem);
    @include fluid(margin-right, 0rem, 0.1rem, 1.5rem, 2rem);
    padding: var(--gutter);
  }

  .sorts {
    line-height: 2rem;
    height: 2rem;
    @include flex($gap: 0.5rem);
    @include border(--bd-main, $sides: bottom);

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

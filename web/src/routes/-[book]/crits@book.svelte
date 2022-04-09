<script context="module" lang="ts">
  export async function load({ fetch, stuff, url }) {
    const pg = url.searchParams.get('pg') || 1
    const _s = url.searchParams.get('sort') || 'score'

    const qs = `pg=${pg}&lm=10&sort=${_s}`
    const res = await fetch(`/api/crits?book=${stuff.nvinfo.id}&${qs}`)

    const data = await res.json()
    if (res.ok) data.props._sort = _s

    return data
  }

  const sorts = {
    score: 'Tổng hợp',
    stars: 'Cho điểm',
    likes: 'Ưa thích',
    mtime: 'Gần nhất',
  }
</script>

<script lang="ts">
  import { page } from '$app/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Gmenu from '$gui/molds/Gmenu.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import YscritCard from '$gui/sects/yscrit/YscritCard.svelte'

  export let crits: CV.Yscrit[] = []
  export let pgidx = 1
  export let pgmax = 1
  export let _sort: string

  $: pager = new Pager($page.url, { sort: 'score', pg: 1 })
</script>

<article class="m-article">
  <div class="sorts">
    <h3 class="h3 -label">Đánh giá</h3>

    <Gmenu
      class="gmenu"
      lbl="Sắp xếp"
      loc="bottom"
      dir="right"
      --menu-width="8rem">
      <button class="m-btn _fill _sm sort-btn" slot="trigger">
        <SIcon name="arrows-sort" />
        <span>{sorts[_sort]}</span>
      </button>

      <svelte:fragment slot="content">
        {#each Object.entries(sorts) as [sort, name]}
          {@const actived = sort == _sort}
          <a
            href={pager.gen_url({ sort, pg: 1 })}
            class="gmenu-item"
            class:_active={actived}>
            <span>{name}</span>
            {#if actived}
              <span class="-right"><SIcon name="check" /></span>
            {/if}
          </a>
        {/each}
      </svelte:fragment>
    </Gmenu>
  </div>

  <div class="crits">
    {#each crits as crit}
      <YscritCard {crit} show_book={false} view_all={crit.vhtml.length < 640} />
    {/each}

    <footer class="pagi">
      {#if crits.length > 0}
        <Mpager {pager} {pgidx} {pgmax} />
      {/if}
    </footer>
  </div>
</article>

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

    > .-label {
      display: block;
      flex: 1;
      font-weight: 500;
      @include ftsize(xl);
    }
  }
</style>

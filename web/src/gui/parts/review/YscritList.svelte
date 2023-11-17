<script lang="ts" context="module">
  import { page } from '$app/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import YscritCard from './YscritCard.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  const sort_trans = { score: 'Tổng hợp', likes: 'Ưa thích', utime: 'Gần nhất' }
</script>

<script lang="ts">
  export let crits: CV.Yscrit[] = []
  export let books: Record<number, CV.Crbook> = {}
  export let users: Record<number, CV.Ysuser> = {}
  export let lists: Record<number, CV.Yslist> = {}

  export let pgidx = 1
  export let pgmax = 1
  export let _sort = 'score'

  export let show_book = true
  export let show_list = true

  $: pager = new Pager($page.url, { sort: _sort, smin: 0, smax: 6, pg: 1 })

  $: opts = {
    sort: $page.url.searchParams.get('sort') || _sort,
    smin: +$page.url.searchParams.get('smin') || 1,
    smax: +$page.url.searchParams.get('smax') || 5,
  }
</script>

<div class="filter">
  <div class="sorts">
    <span class="label">Sắp xếp:</span>
    {#each Object.entries(sort_trans) as [sort, name]}
      {@const href = pager.gen_url({ sort, smin: 1, smax: 5, pg: 1 })}
      <a {href} class="m-chip _sort" class:_active={sort == opts.sort}>
        <span>{name}</span>
      </a>
    {/each}
  </div>

  <div class="stars">
    <span class="label">Số sao:</span>

    {#each [1, 2, 3, 4, 5] as star}
      {@const _active = star >= opts.smin && star <= opts.smax}
      {@const smin = _active || star < opts.smin ? star : opts.smin}
      {@const smax = _active || star > opts.smax ? star : opts.smax}
      {@const href = pager.gen_url({ sort: opts.sort, smin, smax, pg: 1 })}

      <a {href} class="m-star" class:_active>
        <span>{star}</span>
        <SIcon name="star" iset="icons" />
      </a>
    {/each}
  </div>
</div>

<div class="crits">
  {#each crits as crit}
    {@const view_all = crit.vhtml.length < 600}
    {@const book = books[crit.book_id]}
    {@const user = users[crit.user_id]}
    {@const list = lists[crit.list_id]}

    {#key crit.id}
      <YscritCard
        {crit}
        {user}
        {book}
        {list}
        {show_book}
        {show_list}
        {view_all} />
    {/key}
  {/each}

  <footer class="pagi">
    <Mpager {pager} {pgidx} {pgmax} />
  </footer>
</div>

<style lang="scss">
  .crits,
  .filter {
    @include bps(margin-left, 0rem, $tm: 0.75rem, $tl: 1.5rem);
    @include bps(margin-right, 0rem, $tm: 0.75rem, $tl: 1.5rem);
  }

  .filter {
    display: flex;
    margin-top: 0.25rem;
    @include bps(flex-direction, column, $ts: row);

    .label {
      line-height: 1.75rem;
      @include fgcolor(mute);
    }
  }

  .sorts {
    @include flex-cx($gap: 0.5rem);
    @include bp-min(ts) {
      align-items: left;
    }
  }

  .stars {
    @include flex-cx;
    margin-top: 0.5rem;
    @include bp-min(ts) {
      align-items: right;
      margin-top: 0;
      margin-left: auto;
    }
  }

  .m-star {
    display: inline-flex;
    align-items: center;
    @include fgcolor(mute);
    margin-left: 0.75rem;

    &._active {
      color: rgb(247, 186, 42);
      @include fgcolor(secd);
    }

    span {
      margin-right: 0.125rem;
    }
  }
</style>

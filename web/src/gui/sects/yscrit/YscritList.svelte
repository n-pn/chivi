<script lang="ts" context="module">
  const sorts = { score: 'Tổng hợp', likes: 'Ưa thích', utime: 'Gần nhất' }
</script>

<script lang="ts">
  import { page } from '$app/stores'
  import { SIcon } from '$gui'

  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import YscritCard from '$gui/sects/yscrit/YscritCard.svelte'

  export let crits: CV.Yscrit[] = []
  export let pgidx = 1
  export let pgmax = 1
  export let _sort = 'score'

  export let show_book = true
  export let show_list = true

  $: pager = new Pager($page.url, { _s: _sort, pg: 1 })

  $: _s = $page.url.searchParams.get('_s') || _sort
  $: gt = $page.url.searchParams.get('gt') || 1
  $: lt = $page.url.searchParams.get('lt') || 5
</script>

<div class="filter">
  <div class="sorts">
    <span class="label">Sắp xếp:</span>
    {#each Object.entries(sorts) as [sort, name]}
      {@const actived = sort == _s}
      <a
        href={pager.gen_url({ _s: sort, gt: null, lt: null, pg: 1 })}
        class="m-chip"
        class:_active={actived}>
        <span>{name}</span>
      </a>
    {/each}
  </div>

  <div class="stars">
    <span class="label">Số sao:</span>

    {#each [1, 2, 3, 4, 5] as star}
      {@const _active = star >= gt && star <= lt}
      {@const _gt = _active || star < gt ? star : gt}
      {@const _lt = _active || star > lt ? star : lt}
      {@const href = pager.gen_url({ _s, gt: _gt, lt: _lt, pg: 1 })}
      <a {href} class="m-star" class:_active>
        <span>{star}</span>
        <SIcon name="star" iset="sprite" />
      </a>
    {/each}
  </div>
</div>

<div class="crits">
  {#each crits as crit}
    <YscritCard
      {crit}
      {show_book}
      {show_list}
      view_all={crit.vhtml.length < 640} />
  {/each}

  <footer class="pagi">
    <Mpager {pager} {pgidx} {pgmax} />
  </footer>
</div>

<style lang="scss">
  .crits {
    @include bps(margin-left, 0rem, $tm: 0.75rem, $tl: 1.5rem);
    @include bps(margin-right, 0rem, $tm: 0.75rem, $tl: 1.5rem);
  }

  .filter {
    display: flex;
    margin-top: 0.25rem;
    @include bps(margin-left, 0rem, $tm: 0.75rem, $tl: 1.5rem);
    @include bps(margin-right, 0rem, $tm: 0.75rem, $tl: 1.5rem);
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

  .m-chip {
    height: 1.75rem;
    line-height: 1.75rem;

    &._active {
      --color: #{color(primary, 5)};
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

<script context="module">
  export async function load({ fetch, page: { query } }) {
    const url = `/api/dicts?${query.toString()}`
    const res = await fetch(url)
    return { props: await res.json() }
  }
</script>

<script>
  import { page } from '$app/stores'

  import SIcon from '$atoms/SIcon.svelte'
  import Mpager, { Pager } from '$molds/Mpager.svelte'
  import Vessel from '$sects/Vessel.svelte'

  export let cores = []
  export let books = []

  export let total = 1
  export let pgidx = 1
  export let pgmax = 1
</script>

<svelte:head>
  <title>Từ điển - Chivi</title>
</svelte:head>

<Vessel>
  <svelte:fragment slot="header-left">
    <span class="header-item _active">
      <SIcon name="box" />
      <span class="header-text">Từ điển</span>
    </span>
  </svelte:fragment>

  <article class="m-article">
    <h1>Từ điển</h1>

    <h2>Hệ thống</h2>

    <div class="dicts">
      {#each cores as [dname, label, dsize]}
        <a class="-dict" href="/dicts/{dname}">
          <div class="-name">{label}</div>
          <div class="-meta">
            <div class="-type">Hệ thống</div>
            <div class="-size">Số từ: {dsize}</div>
          </div>
        </a>
      {/each}
    </div>

    <h2>Theo bộ ({total})</h2>

    <div class="dicts">
      {#each books as [dname, label, dsize]}
        <a class="-dict" href="/dicts/{dname}">
          <div class="-name">{label}</div>
          <div class="-meta">
            <div class="-type">Bộ truyện</div>
            <div class="-size">Số từ: {dsize}</div>
          </div>
        </a>
      {/each}
    </div>

    <footer class="foot">
      <Mpager pager={new Pager($page.path, $page.query)} {pgidx} {pgmax} />
    </footer>
  </article>
</Vessel>

<style lang="scss">
  .dicts {
    @include grid(minmax(10rem, 1fr), $gap: var(--gutter-sm));
  }

  .-dict {
    padding: 0.5rem;
    position: relative;
    // height: 5rem;

    @include bdradi();
    @include shadow(1);

    @include bgcolor(tert);

    &:hover {
      @include bgcolor(secd);
      & > .-name {
        @include fgcolor(primary, 5);
      }
    }
  }

  .-name {
    font-weight: 500;
    // text-transform: capitalize;
    font-size: rem(14px);
    line-height: 1.5rem;
    @include clamp($width: null);
    @include fgcolor(secd);
  }

  .-meta {
    // margin-top: 0.25rem;
    display: flex;
    font-size: rem(14px);
    font-style: italic;
    @include fgcolor(tert);
  }

  .-type {
    margin-right: 0.5rem;
  }

  .-size {
    margin-left: auto;
  }
</style>

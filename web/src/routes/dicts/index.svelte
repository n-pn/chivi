<script context="module">
  export async function load({ fetch, page: { query } }) {
    const page = +query.get('page') || 1

    const url = `/api/dicts?page=${page}`
    const res = await fetch(url)
    return { props: await res.json() }
  }
</script>

<script>
  import { page } from '$app/stores'

  import Vessel from '$lib/layouts/Vessel.svelte'
  import CPagi from '$lib/blocks/CPagi.svelte'
  import SIcon from '$lib/blocks/SIcon.svelte'

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
      <span class="header-text _show-md">Từ điển</span>
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
      <CPagi path="/dicts" opts={$page.query} {pgidx} {pgmax} />
    </footer>
  </article>
</Vessel>

<style lang="scss">
  article {
    margin: 1rem 0;
    @include shadow();
    @include radius();
    padding: 1rem;
    background: #fff;
    @include fgcolor(neutral, 8);
  }

  .dicts {
    display: grid;
    grid-gap: 0.5rem;
    grid-template-columns: repeat(auto-fill, minmax(10rem, 1fr));
  }

  .-dict {
    padding: 0.5rem;
    position: relative;
    // height: 5rem;

    @include radius();
    @include shadow();

    &:hover {
      @include bgcolor(primary, 1);
      & > .-name {
        @include fgcolor(primary, 6);
      }
    }
  }

  .-name {
    font-weight: 500;
    // text-transform: capitalize;
    font-size: rem(14px);
    line-height: 1.5rem;
    @include truncate(null);
    @include fgcolor(neutral, 7);
  }

  .-meta {
    // margin-top: 0.25rem;
    display: flex;
    font-size: rem(14px);
    font-style: italic;
    @include fgcolor(neutral, 6);
  }

  .-type {
    margin-right: 0.5rem;
  }

  .-size {
    margin-left: auto;
  }
</style>

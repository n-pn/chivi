<script context="module">
  import { page } from '$app/stores'
  import { data as appbar } from '$sects/Appbar.svelte'

  export async function load({ fetch, url }) {
    appbar.set({ left: [['Từ điển', 'package']] })

    const api_url = `/api/dicts${url.search}`
    const api_res = await fetch(api_url)
    return await api_res.json()
  }
</script>

<script>
  import Footer from '$sects/Footer.svelte'
  import Mpager, { Pager } from '$molds/Mpager.svelte'

  export let cores = []
  export let books = []

  export let total = 1
  export let pgidx = 1
  export let pgmax = 1
</script>

<svelte:head>
  <title>Từ điển - Chivi</title>
</svelte:head>

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
</article>

<Footer>
  <Mpager pager={new Pager($page.url)} {pgidx} {pgmax} />
</Footer>

<style lang="scss">
  .dicts {
    @include grid(minmax(12.5rem, 1fr), $gap: var(--gutter-pl));
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

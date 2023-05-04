<script lang="ts">
  import { page } from '$app/stores'
  import { Footer, Mpager } from '$gui'
  import { Pager } from '$gui/molds/Mpager.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ cores = [], books = [] } = data)
</script>

<article class="article m-article">
  <h1>Từ điển</h1>

  <h2>Hệ thống</h2>

  <div class="dicts">
    {#each cores as [dname, label, dsize]}
      <a class="-dict" href="/mt/dicts/{dname}">
        <div class="-name">{label}</div>
        <div class="-meta">
          <div class="-type">Hệ thống</div>
          <div class="-size">Số từ: {dsize}</div>
        </div>
      </a>
    {/each}
  </div>

  <h2>Theo bộ <span class="u-badge">{data.total}</span></h2>

  <div class="dicts">
    {#each books as [dname, label, dsize]}
      <a class="-dict" href="/mt/dicts/{dname}">
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
  <Mpager pager={new Pager($page.url)} pgidx={data.pgidx} pgmax={data.pgmax} />
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

    @include bgcolor(secd);

    &:hover {
      @include bgcolor(main);
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

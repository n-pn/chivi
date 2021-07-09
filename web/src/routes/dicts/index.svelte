<script context="module">
  export async function load({ fetch, page: { query } }) {
    const page = +query.get('page') || 1

    const url = `/api/dicts?page=${page}`
    const res = await fetch(url)

    const { system, unique } = await res.json()
    return { props: { system, unique, page } }
  }
</script>

<script>
  import Vessel from '$lib/layouts/Vessel.svelte'
  import SIcon from '$lib/blocks/SIcon.svelte'
  export let system = []
  export let unique = []
  export let page = 1
</script>

<Vessel>
  <article class="m-article">
    <h1>Từ điển</h1>

    <h2>Hệ thống</h2>

    <div class="dicts">
      {#each system as [dname, label, dsize]}
        <a class="-dict" href="/dicts/{dname}">
          <div class="-name">{label}</div>
          <div class="-meta">
            <div class="-type">Hệ thống</div>
            <div class="-size">Số từ: {dsize}</div>
          </div>
        </a>
      {/each}
    </div>

    <h2>Các bộ sách</h2>

    <div class="dicts">
      {#each unique as [dname, label, dsize]}
        <a class="-dict" href="/dicts/{dname}">
          <div class="-name">{label}</div>
          <div class="-meta">
            <div class="-type">Bộ truyện</div>
            <div class="-size">Số từ: {dsize}</div>
          </div>
        </a>
      {/each}
    </div>

    <footer class="pagi">
      {#if page > 1}
        <a class="m-button" href="/dicts?page={page - 1}"
          ><SIcon name="chevron-left" />
          <span class="-txt">Trước</span>
        </a>
      {:else}
        <div class="m-button _disable">
          <SIcon name="chevron-left" />
          <span class="-txt">Trước</span>
        </div>
      {/if}

      {#if unique.length > 39}
        <a class="m-button _primary" href="/dicts?page={page + 1}">
          <span class="-txt">Kế tiếp</span>
          <SIcon name="chevron-right" />
        </a>
      {:else}
        <div class="m-button _disable">
          <span class="-txt">Kế tiếp</span>
          <SIcon name="chevron-right" />
        </div>
      {/if}
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

  .pagi {
    display: flex;
    justify-content: center;

    .m-button + .m-button {
      // width: 5rem;
      // text-align: center;
      margin-left: 0.5rem;
    }
  }
</style>

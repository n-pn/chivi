<script context="module">
  export async function load({ page: { query }, fetch }) {
    const page = +query.get('page') || 1

    let url = `/api/cvbooks`
    url += `?${query.toString()}&take=24&page=${page}`

    const res = await fetch(url)

    if (res.ok) {
      const data = await res.json()

      return {
        props: { ...data, opts: parse_params(query) },
      }
    }

    return {
      status: res.status,
      error: new Error(await res.text()),
    }
  }

  function parse_params(query, params = {}) {
    params.order = query.get('order') || 'access'
    if (query.has('genre')) params.genre = query.get('genre')
    if (query.has('sname')) params.sname = query.get('sname')
    if (query.has('page')) params.page = +query.get('page')

    return params
  }

  const order_names = {
    access: 'Vừa xem',
    update: 'Đổi mới',
    voters: 'Đánh giá',
    weight: 'Tổng hợp',
  }
</script>

<script>
  import { page } from '$app/stores'
  import SIcon from '$atoms/SIcon.svelte'
  import Nvlist from '$parts/Nvlist.svelte'
  import Vessel from '$sects/Vessel.svelte'
  import Mpager, { Pager } from '$molds/Mpager.svelte'

  export let books = []
  export let pgidx = 1
  export let pgmax = 1

  export let opts = { order: 'access' }
  $: pager = new Pager($page.path, $page.query, { order: 'access' })
</script>

<svelte:head>
  <title>Chivi - Truyện tàu dịch máy</title>
</svelte:head>

<Vessel>
  <svelte:fragment slot="header-left">
    <form class="header-field" action="/search" method="get">
      <input type="search" name="q" placeholder="Tìm truyện" />
      <SIcon name="search" />
    </form>
  </svelte:fragment>

  <a slot="header-right" href="/qtran" class="header-item">
    <SIcon name="zap" />
    <span class="header-text _show-md">Dịch nhanh</span>
  </a>

  <div class="order">
    {#each Object.entries(order_names) as [type, label]}
      <a
        href={pager.url({ page: 1, order: type })}
        class="-type"
        class:_active={opts.order === type}>
        <span>{label}</span>
      </a>
    {/each}
  </div>

  {#if books.length > 0}
    <Nvlist {books} />
  {:else}
    <div class="empty">Danh sách trống</div>
  {/if}

  <svelte:fragment slot="footer">
    <Mpager {pager} {pgidx} {pgmax} />
  </svelte:fragment>
</Vessel>

<style lang="scss">
  :global(#svelte) {
    height: 100%;
  }

  .order {
    @include flex($center: horz, $gap: 0.375rem);

    overflow: auto;
    margin: 1rem 0 0.5rem;
    font-weight: 500;
    text-transform: uppercase;

    @include fluid(font-size, 12px, 13px, 14px);
    @include fluid(line-height, 1.5rem, 1.75rem, 2rem);

    .-type {
      padding: 0 0.75em;
      @include clamp($width: null);
      @include fgcolor(neutral, 6);

      @include border(neutral, 3);
      border-radius: 0.5rem;

      &._active,
      &:hover {
        @include fgcolor(primary, 6);
        @include bdcolor(primary, 5);
      }

      @include tm-dark {
        @include fgcolor(neutral, 4);
        @include bdcolor(neutral, 7);

        &._active,
        &:hover {
          @include fgcolor(primary, 4);
        }
      }
    }
  }

  .empty {
    display: flex;
    min-height: 50vh;
    align-items: center;
    justify-content: center;
    font-style: italic;
    @include fgcolor(neutral, 6);
  }
</style>

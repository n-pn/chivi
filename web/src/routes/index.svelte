<script context="module">
  export async function load({ page: { query }, fetch }) {
    const page = +query.get('page') || 1

    const qs = `?${query.toString()}&take=24&page=${page}`
    const res = await fetch(`/api/books${qs}`)

    if (!res.ok) return { status: res.status, error: await res.text() }
    return { props: { ...(await res.json()), opts: parse_params(query) } }
  }

  function parse_params(query, params = {}) {
    params.order = query.get('order') || 'bumped'

    if (query.has('genre')) params.genre = query.get('genre')
    if (query.has('sname')) params.sname = query.get('sname')
    if (query.has('page')) params.page = +query.get('page')

    return params
  }

  const order_names = {
    bumped: 'Vừa xem',
    update: 'Đổi mới',
    rating: 'Đánh giá',
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

  export let opts = { order: 'bumped' }
  $: pager = new Pager($page.path, $page.query, { order: 'bumped' })
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
    @include flex($center: horz, $gap: 0.5rem);

    margin: 1rem 0;

    @include fluid(font-size, rem(13px), rem(14px));
    @include fluid(line-height, 1.75rem, 2rem);

    .-type {
      padding: 0 0.75em;
      font-weight: 500;
      text-transform: uppercase;
      @include clamp($width: null);
      @include fgcolor(tert);

      @include linesd(--bd-main);
      @include bdradi();

      &._active,
      &:hover {
        @include fgcolor(primary, 6);
        @include linesd(primary, 5, $ndef: false);
      }

      @include tm-dark {
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

<script context="module">
  const take = 24

  export async function load({ page: { query }, fetch }) {
    const page = +query.get('page') || 1
    let skip = (page - 1) * take
    if (skip < 1) skip = 0

    let url = `/api/books`
    url += `?${query.toString()}&take=24&skip=${skip}`

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
  export let pgmax = 1

  export let opts = { order: 'access' }
  $: pager = new Pager($page.path, $page.query)

  let searching = false

  function handleKeypress(evt) {
    if (searching) return
    if (!evt.alt) return

    switch (evt.keyCode) {
      case 72:
        evt.preventDefault()
        change_page(1)
        break

      case 76:
        evt.preventDefault()
        change_page(pgmax)
        break

      case 37:
      case 74:
        if (!evt.altKey) {
          evt.preventDefault()
          change_page(page - 1)
        }
        break

      case 39:
      case 75:
        if (!evt.altKey) {
          evt.preventDefault()
          change_page(page + 1)
        }
        break

      default:
        break
    }
  }

  function change_page(new_page = 2) {
    if (new_page >= 1 && new_page <= pgmax) {
      _goto_(gen_page_url(new_page, query))
    }
  }
</script>

<svelte:head>
  <title>Chivi - Truyện tàu dịch máy</title>
</svelte:head>

<svelte:window on:keydown={handleKeypress} />

<Vessel>
  <svelte:fragment slot="header-left">
    <form class="header-field" action="/search" method="get">
      <input
        type="search"
        name="q"
        placeholder="Tìm kiếm"
        on:focus={() => (searching = true)}
        on:onfocusout={() => (searching = false)} />
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
        href={pager.url_for({ page: 1, order: type })}
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
    <Mpager {pager} pgidx={opts.page} {pgmax} />
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

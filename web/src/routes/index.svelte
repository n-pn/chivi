<script context="module">
  const take = 24

  export async function load({ page: { query }, fetch }) {
    const page = +query.get('page') || 1
    let skip = (page - 1) * take
    if (skip < 1) skip = 0

    let url = `/api/books`
    const opts = parse_params(query)

    query.set('skip', skip)
    query.set('take', 24)
    url += `?${query.toString()}`

    const res = await fetch(url)

    if (res.ok) {
      const { books, total } = await res.json()

      return {
        props: { books, total, page, opts },
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

    return params
  }

  function gen_page_url(page = 1, opts = {}) {
    const query = new URLSearchParams()

    if (page > 1) query.set('page', page)
    if (opts.order != 'access') query.set('order', opts.order)
    if (opts.genre) query.set('genre', opts.genre)
    if (opts.sname) query.set('sname', opts.sname)

    const output = query.toString()
    return output ? `/?${output}` : '/'
  }

  const order_names = {
    access: 'Vừa xem',
    update: 'Đổi mới',
    voters: 'Đánh giá',
    weight: 'Tổng hợp',
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import Nvlist from '$parts/Nvlist.svelte'
  import Vessel from '$sects/Vessel.svelte'
  import paginate_range from '$utils/paginate_range.js'

  export let books = []
  export let total = 0

  export let page = 1
  export let opts = { order: 'access' }

  $: page_max = Math.floor((total - 1) / 20) + 1
  $: page_ary = paginate_range(page, page_max)

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
        change_page(page_max)
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
    if (new_page >= 1 && new_page <= page_max) {
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
        href={gen_page_url(1, { ...opts, order: type })}
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

  <div class="pagi" slot="footer">
    <a
      href={gen_page_url(+page - 1, opts)}
      class="page m-button"
      class:_disable={page == 1}>
      <SIcon name="chevron-left" />
      <span>Trước</span>
    </a>

    {#each page_ary as [index, level]}
      <a
        href={gen_page_url(index, opts)}
        class="page m-button"
        class:_primary={page == index}
        class:_disable={page == index}
        data-level={level}>
        <span>{index}</span>
      </a>
    {/each}

    <a
      href={gen_page_url(page + 1, opts)}
      class="page m-button _solid _primary"
      class:_disable={page == page_max}>
      <span>Kế tiếp</span>
      <SIcon name="chevron-right" />
    </a>
  </div>
</Vessel>

<style lang="scss">
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
      @include fgcolor(gray, 6);

      @include border();
      border-radius: 0.5rem;

      &._active,
      &:hover {
        @include fgcolor(blue, 6);
        @include bdcolor(color-var(blue, 5));
      }

      @include tm-dark {
        @include fgcolor(gray, 4);
        @include bdcolor(gray, 7);

        &._active,
        &:hover {
          @include fgcolor(blue, 4);
        }
      }
    }
  }

  .pagi {
    padding: 0.5rem 0;
    @include flex($center: horz, $gap: 0.375rem);
  }

  // .page {
  //   display: inline-flex;

  //   > span {
  //     margin-top: rem(1px);
  //   }

  //   &[data-level] {
  //     display: none;
  //   }

  //   &[data-level='0'] {
  //     display: inline-block;
  //   }

  //   &[data-level='1'] {
  //     @include fluid(display, $sm: inline-block);
  //   }

  //   &[data-level='2'] {
  //     @include fluid(display, $md: inline-block);
  //   }

  //   &[data-level='3'],
  //   &[data-level='4'],
  //   &[data-level='5'] {
  //     @include fluid(display, $lg: inline-block);
  //   }

  //   @include tm-dark {
  //     @include fgcolor(gray, 2);
  //     @include bgcolor(gray, 7);

  //     &._primary {
  //       @include bgcolor(blue, 7);
  //     }
  //   }
  // }

  .empty {
    display: flex;
    min-height: 50vh;
    align-items: center;
    justify-content: center;
    font-style: italic;
    @include fgcolor(gray, 6);
  }
</style>

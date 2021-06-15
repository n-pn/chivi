<script context="module">
  const take = 24

  export async function preload({ query }) {
    const page = +(query.page || 1)
    let skip = (page - 1) * take
    if (skip < 1) skip = 0

    let url = `/api/books?skip=${skip}&take=24`
    const opts = parse_params(query)
    if (opts != {}) url += `&${merge_params(opts)}`

    const res = await this.fetch(url)
    const { books, total } = await res.json()
    return { books, total, page, opts }
  }

  function parse_params({ order, genre, sname }, params = {}) {
    params.order = order || 'access'

    if (genre) params.genre = genre
    if (sname) params.sname = sname

    return params
  }

  function merge_params(opts) {
    return Object.entries(opts)
      .map(([k, v]) => `${k}=${v}`)
      .join('&')
  }

  function gen_page_url(page = 1, opts = {}) {
    if (page > 1) opts.page = page
    if (opts.order == 'access') delete opts.order

    const query = merge_params(opts)
    return query ? `/?${query}` : '/'
  }

  const order_names = {
    access: 'Vừa xem',
    update: 'Đổi mới',
    voters: 'Đánh giá',
    weight: 'Tổng hợp',
  }
</script>

<script>
  import SIcon from '$lib/blocks/SIcon'
  import Nvlist from '$lib/widgets/Nvlist'
  import Vessel from '$lib/layouts/Vessel'
  import paginate_range from '$utils/paginate_range'

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
  <title>Chivi - Công cụ dịch truyện từ Tiếng Trung sang Tiếng Việt</title>
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
    @include flex($center: content);
    @include flex-gap($gap: 0.375rem, $child: ':global(*)');

    overflow: auto;
    margin: 1rem 0 0.5rem;
    font-weight: 500;
    text-transform: uppercase;

    @include props(font-size, 12px, 13px, 14px);
    @include props(line-height, 1.5rem, 1.75rem, 2rem);

    .-type {
      padding: 0 0.75em;
      @include truncate(null);
      @include fgcolor(neutral, 6);

      @include border();
      border-radius: 0.5rem;

      &._active,
      &:hover {
        @include fgcolor(primary, 6);
        @include bdcolor($color: primary, $shade: 5);
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

  .pagi {
    padding: 0.5rem 0;
    @include flex($center: content);
    @include flex-gap($gap: 0.375rem, $child: ':global(*)');
  }

  .page {
    display: inline-flex;

    > span {
      margin-top: rem(1px);
    }

    &[data-level] {
      display: none;
    }

    &[data-level='0'] {
      display: inline-block;
    }

    &[data-level='1'] {
      @include props(display, $sm: inline-block);
    }

    &[data-level='2'] {
      @include props(display, $md: inline-block);
    }

    &[data-level='3'],
    &[data-level='4'],
    &[data-level='5'] {
      @include props(display, $lg: inline-block);
    }

    @include tm-dark {
      @include fgcolor(neutral, 2);
      @include bgcolor(neutral, 7);

      &._primary {
        @include bgcolor(primary, 7);
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

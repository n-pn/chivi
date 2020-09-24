<script context="module">
  export async function preload({ query }) {
    const page = +(query.page || 1)
    let url = `/_books?page=${page}`

    if (query.order) url += `&order=${query.order}`
    if (query.genre) url += `&genre=${query.genre}`
    if (query.anchor) url += `&anchor=${query.anchor}`

    const res = await this.fetch(url)
    const data = await res.json()
    return { page, ...data }
  }

  function makePageUrl(page = 1, query = {}) {
    const opts = {}
    if (page > 1) opts.page = page
    if (query.order !== 'access') opts.order = query.order
    if (query.genre) opts.genre = query.genre
    // if (query.anchor) opts.anchor = query.anchor

    const params = Object.entries(opts)
      .map(([k, v]) => `${k}=${v}`)
      .join('&')

    if (params) return `/?${params}`
    return '/'
  }

  const order_names = {
    access: 'Vừa xem',
    update: 'Đổi mới',
    rating: 'Đánh giá',
    weight: 'Tổng hợp',
  }
</script>

<script>
  import paginate_range from '$utils/paginate_range'

  import SvgIcon from '$atoms/SvgIcon.svelte'
  import BookList from '$melds/BookList.svelte'

  import Vessel from '$parts/Vessel'

  export let items = []
  export let total = 0
  export let query = {}
  export let page = 1

  $: page_max = Math.floor((total - 1) / 20) + 1
  $: page_ary = paginate_range(page, page_max)

  let searching = false

  function handleKeypress(evt) {
    if (searching) return

    switch (evt.keyCode) {
      case 72:
        evt.preventDefault()
        changePage(1)
        break

      case 76:
        evt.preventDefault()
        changePage(page_max)
        break

      case 37:
      case 74:
        if (!evt.altKey) {
          evt.preventDefault()
          changePage(page - 1)
        }
        break

      case 39:
      case 75:
        if (!evt.altKey) {
          evt.preventDefault()
          changePage(page + 1)
        }
        break

      default:
        break
    }
  }

  function changePage(newPage = 2) {
    if (newPage >= 1 && newPage <= page_max) {
      _goto(makePageUrl(newPage, query))
    }
  }
</script>

<svelte:head>
  <title>Chivi - Công cụ dịch truyện từ Tiếng Trung sang Tiếng Việt</title>
</svelte:head>

<svelte:window on:keydown={handleKeypress} />

<Vessel>
  <form slot="header-left" class="header-field" action="/search" method="get">
    <input
      type="search"
      name="kw"
      placeholder="Tìm kiếm"
      on:focus={() => (searching = true)}
      on:onfocusout={() => (searching = false)} />
    <SvgIcon name="search" />
  </form>

  <a slot="header-right" class="header-item" href="/translate">
    <SvgIcon name="zap" />
    <span class="header-text _show-md">Dịch nhanh</span>
  </a>

  {#if items.length == 0}
    <div class="empty">Danh sách trống</div>
  {:else}
    <div class="order">
      {#each Object.entries(order_names) as [type, label]}
        <a
          class="-type"
          class:_active={query.order === type}
          href={makePageUrl(1, { ...query, order: type })}>
          <span>{label}</span>
        </a>
      {/each}
    </div>

    <BookList books={items} />

    <div class="pagi">
      <a
        class="page m-button _line"
        class:_disable={page == 1}
        href={makePageUrl(+page - 1, query)}>
        <SvgIcon name="chevron-left" />
        <span>Trước</span>
      </a>

      {#each page_ary as [index, level]}
        <a
          class="page m-button _line"
          class:_primary={page == index}
          class:_disable={page == index}
          data-level={level}
          href={makePageUrl(index, query)}>
          <span>{index}</span>
        </a>
      {/each}

      <a
        class="page m-button _solid _primary"
        class:_disable={page == page_max}
        href={makePageUrl(page + 1, query)}>
        <span>Kế tiếp</span>
        <SvgIcon name="chevron-right" />
      </a>
    </div>
  {/if}
</Vessel>

<style lang="scss">
  .order {
    @include flex($gap: 0.375rem);
    overflow: auto;
    justify-content: center;

    margin: 0.75rem 0;
    line-height: 2rem;

    .-type {
      text-transform: uppercase;
      padding: 0 0.5rem;
      font-weight: 500;
      @include truncate(null);

      @include fgcolor(neutral, 7);
      @include font-size(2);
      @include border();
      @include radius();
      &._active {
        @include fgcolor(primary, 5);
        @include bdcolor($color: primary, $shade: 5);
      }
    }
  }

  $footer-height: 4rem;

  // :global(.footer) {
  //   position: sticky;
  //   bottom: 0;
  //   left: 0;
  //   width: 100%;
  //   transition: transform 0.1s ease-in-out;
  //   @include bgcolor(rgba(color(neutral, 1), 0.8));

  //   :global(.main._clear) & {
  //     transform: translateY($footer-height);
  //     background-color: transparent;
  //     margin-bottom: 0;
  //   }
  // }

  .pagi {
    margin: 0.75rem 0;
    @include flex($gap: 0.375rem);
    justify-content: center;
  }

  .page {
    display: inline-flex;
    > span {
      margin-top: rem(1px);
    }

    & + & {
      margin-left: 0.375rem;
    }

    &[data-level] {
      display: none;
    }

    &[data-level='0'] {
      display: inline-block;
    }

    &[data-level='1'] {
      @include screen-min(sm) {
        display: inline-block;
      }
    }

    &[data-level='2'] {
      @include screen-min(md) {
        display: inline-block;
      }
    }

    &[data-level='3'],
    &[data-level='4'],
    &[data-level='5'] {
      @include screen-min(lg) {
        display: inline-block;
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

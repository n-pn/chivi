<script context="module">
  import { anchor_rel } from '$src/stores.js'
  import paginate_range from '$utils/paginate_range'

  import SvgIcon from '$atoms/SvgIcon.svelte'
  import BookList from '$melds/BookList.svelte'

  import Vessel from '$parts/Vessel'

  export async function preload({ query }) {
    const page = +(query.page || 1)
    let url = `/api/books?page=${page}`

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
      _goto_(makePageUrl(newPage, query))
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

  <a
    slot="header-right"
    href="/translate"
    class="header-item"
    rel={$anchor_rel}>
    <SvgIcon name="zap" />
    <span class="header-text _show-md">Dịch nhanh</span>
  </a>

  <div class="order">
    {#each Object.entries(order_names) as [type, label]}
      <a
        href={makePageUrl(1, { ...query, order: type })}
        class="-type"
        class:_active={query.order === type}
        rel={$anchor_rel}>
        <span>{label}</span>
      </a>
    {/each}
  </div>

  {#if items.length > 0}
    <BookList books={items} />
  {:else}
    <div class="empty">Danh sách trống</div>
  {/if}

  <div class="pagi" slot="footer">
    <a
      href={makePageUrl(+page - 1, query)}
      class="page m-button"
      class:_disable={page == 1}
      rel={$anchor_rel}>
      <SvgIcon name="chevron-left" />
      <span>Trước</span>
    </a>

    {#each page_ary as [index, level]}
      <a
        href={makePageUrl(index, query)}
        class="page m-button"
        class:_primary={page == index}
        class:_disable={page == index}
        rel={$anchor_rel}
        data-level={level}>
        <span>{index}</span>
      </a>
    {/each}

    <a
      href={makePageUrl(page + 1, query)}
      class="page m-button _solid _primary"
      class:_disable={page == page_max}
      rel={$anchor_rel}>
      <span>Kế tiếp</span>
      <SvgIcon name="chevron-right" />
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
      @include radius(9);

      &._active {
        @include fgcolor(primary, 6);
        @include bdcolor($color: primary, $shade: 5);
      }
    }
  }

  $footer-height: 4rem;

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

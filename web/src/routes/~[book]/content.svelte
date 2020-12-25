<script context="module">
  export async function preload({ params, query }) {
    const bslug = params.book
    const desc = query.order == 'desc'

    const res = await this.fetch(`/api/books/${bslug}`)
    const data = await res.json()

    if (!res.ok) return this.error(res.status, data.msg)

    let { book, mark } = data
    const ubid = book.ubid

    const seed = query.seed || book.seed_names[0] || ''
    const page = +(query.page || 1)

    const opts = { seed, page, desc, mode: 0 }
    const { chaps, total } = await fetch_data(this.fetch, ubid, opts)
    return { book, mark, chaps, total, seed, page, desc }
  }

  const limit = 30

  async function fetch_data(api, ubid, opts) {
    const page = opts.page || 1
    let offset = (page - 1) * limit
    if (offset < 0) offset = 0

    let url = `/api/chaps/${ubid}/${opts.seed}?limit=${limit}&offset=${offset}`
    if (opts.desc) url += `&order=desc`
    if (opts.mode && opts.mode > 0) url += `&mode=${opts.mode}`

    const res = await api(url)
    const data = await res.json()

    try {
      if (res.ok) return data
      else throw data.msg
    } catch (err) {
      throw err.message
    }
  }
</script>

<script>
  import SvgIcon from '$atoms/SvgIcon'
  import RelTime from '$atoms/RelTime'
  import paginate_range from '$utils/paginate_range'
  // import AdBanner from '$atoms/AdBanner'

  import { self_power, anchor_rel } from '$src/stores'

  import Serial from './_serial'
  import ChapList from '$melds/ChapList'

  export let book
  export let mark = ''

  export let seed
  export let page = 1
  export let desc = false

  export let chaps = []
  export let total = 0

  $: has_seeds = book.seed_names.length > 0

  $: pmax = Math.floor((total - 1) / limit) + 1
  $: page_list = paginate_range(page, pmax, 7)

  let scroll_top

  let _load = false

  async function reload(evt, opts = {}) {
    evt.preventDefault()
    const url = new URL(window.location)

    if (opts.page) {
      let new_page = opts.page
      if (new_page < 1) new_page = 1
      if (new_page > pmax) new_page = pmax

      page = new_page
      url.searchParams.set('page', page)
    } else {
      opts.page = page
    }

    if (opts.seed) {
      seed = opts.seed
      url.searchParams.set('seed', seed)
    } else {
      opts.seed = seed
    }

    if (opts.desc) {
      desc = true
      url.searchParams.set('order', 'desc')
    } else {
      desc = false
      url.searchParams.set('order', 'asc')
    }

    if (opts.mode) {
      if (opts.mode > $self_power) opts.mode = $self_power
    } else {
      opts.mode = 0
    }

    _load = true
    const res = await fetch_data(fetch, book.ubid, opts)
    chaps = res.chaps
    total = res.total

    scroll_top.scrollIntoView({ behavior: 'smooth', block: 'start' })
    window.history.pushState({}, '', url)
    _load = false
  }

  function handleKeypress(evt) {
    if ($self_power < 1) return

    switch (evt.keyCode) {
      case 72:
        reload(evt, { page: 1 })
        break

      case 76:
        reload(evt, { page: pmax })
        break

      case 37:
      case 74:
        if (!evt.altKey) reload(evt, { page: page - 1 })

        break

      case 39:
      case 75:
        if (!evt.altKey) reload(evt, { page: page + 1 })

        break

      default:
        break
    }
  }

  function page_url(seed, page) {
    let url = `/~${book.slug}/content?seed=${seed}`
    if (page > 1) url += `&page=${page}`
    if (desc) url += '&order=desc'
    return url
  }
</script>

<svelte:window on:keydown={handleKeypress} />

<Serial {book} {mark} atab="content">
  {#if has_seeds}
    <!-- <AdBanner /> -->

    <div class="seeds" bind:this={scroll_top}>
      <div class="-left">
        <div class="-hint">Nguồn:</div>

        <div class="seed-menu">
          <div class="-text">
            <span class="-label">{seed}</span>
            <span class="-count">({total} chương)</span>
          </div>

          <div class="-menu">
            {#each book.seed_names as name}
              <a
                class="-item"
                class:_active={seed === name}
                href={page_url(name, 1)}
                on:click={(e) => reload(e, { seed: name, page: 1 })}
                rel={$anchor_rel}>
                <span class="-name">{name}</span>
                <span class="-time">
                  <RelTime time={book.seed_mftimes[name]} seed={name} />
                </span>
              </a>
            {/each}
          </div>
        </div>
      </div>

      <div class="-right">
        <button
          class="m-button _text"
          on:click={(e) => reload(e, { page: 1, desc: true, mode: 2 })}>
          <SvgIcon name={_load ? 'loader' : 'clock'} spin={_load} />
          <span><RelTime time={book.seed_mftimes[seed]} {seed} /></span>
        </button>

        <button
          class="m-button _text"
          on:click={(e) => reload(e, { desc: !desc })}>
          <SvgIcon name={desc ? 'arrow-down' : 'arrow-up'} />
          <span class="-hide">Sắp xếp</span>
        </button>
      </div>
    </div>

    <div class="chaps">
      <ChapList bslug={book.slug} sname={seed} {chaps} />

      {#if pmax > 1}
        <nav class="pagi">
          <a
            href={page_url(seed, 1)}
            class="page m-button"
            class:_disable={page == 1}
            on:click={(e) => reload(e, { page: 1 })}>
            <SvgIcon name="chevrons-left" />
          </a>

          <a
            href={page_url(seed, page - 1)}
            class="page m-button"
            class:_disable={page < 2}
            on:click={(e) => reload(e, { page: page - 1 })}>
            <SvgIcon name="chevron-left" />
          </a>

          {#each page_list as [curr, level]}
            <a
              href={page_url(seed, curr)}
              class="page m-button"
              class:_primary={page == curr}
              class:_disable={page == curr}
              data-level={level}
              on:click={(e) => reload(e, { page: curr })}>
              <span>{curr}</span>
            </a>
          {/each}

          <a
            href={page_url(seed, page + 1)}
            class="page m-button"
            class:_disable={page + 1 >= pmax}
            on:click={(e) => reload(e, { page: page + 1 })}>
            <SvgIcon name="chevron-right" />
          </a>

          <a
            href={page_url(seed, pmax)}
            class="page m-button"
            class:_disable={page == pmax}
            on:click={(e) => reload(e, { page: page + 1 })}>
            <SvgIcon name="chevrons-right" />
          </a>
        </nav>
      {/if}
    </div>
  {:else}
    <div class="empty">Không có nội dung.</div>
  {/if}
</Serial>

<style lang="scss">
  .seeds {
    margin: 0.75rem 0 1.25rem;
    display: flex;

    .-left {
      display: flex;
      margin-right: 0.5rem;
    }

    .-hint {
      display: none;
      @include screen-min(md) {
        display: inline-block;
      }

      height: 2.25rem;
      line-height: 2.25rem;
      text-transform: uppercase;
      margin-right: 0.5rem;
      font-weight: 500;
      @include font-size(2);
      @include fgcolor(neutral, 7);
    }

    .-right {
      margin-left: auto;
      @include flex();
      @include flex-gap($gap: 0.5rem, $child: ':global(*)');
    }

    .m-button {
      @include border();
      > span {
        @include truncate(null);
        max-width: 25vw;
      }
    }
  }

  .seed-menu {
    position: relative;
    .-text {
      cursor: pointer;
      display: inline-block;
      height: 2.25rem;

      padding: 0 0.5rem;
      font-weight: 500;
      line-height: 2.25rem;
      text-transform: uppercase;
      @include border();
      @include radius();

      @include font-size(2);
      @include fgcolor(neutral, 7);
    }

    .-count {
      display: none;
      @include screen-min(md) {
        margin-left: 0.25rem;
        display: inline-block;
        @include fgcolor(neutral, 6);
      }
    }

    &:hover {
      .-menu {
        display: block;
      }

      .-text {
        @include bgcolor(neutral, 2);
      }
    }

    .-menu {
      display: none;
      // prettier-ignore

      position: absolute;
      top: 2.25rem;
      left: 0;
      min-width: 12rem;
      padding: 0.5rem 0;

      @include bgcolor(white);
      @include radius();
      @include shadow(2);
    }

    .-item {
      cursor: pointer;
      display: flex;
      padding: 0 0.75rem;

      line-height: 2.25rem;
      @include border($sides: top);
      &:last-child {
        @include border($sides: bottom);
      }

      @include font-size(2);
      @include fgcolor(neutral, 7);

      &._active {
        @include fgcolor(primary, 5);
      }

      &:hover {
        @include bgcolor(neutral, 2);
      }

      .-name {
        font-weight: 500;
        text-transform: uppercase;
      }

      .-time {
        margin-left: auto;
        @include fgcolor(neutral, 5);
      }
    }
  }

  .empty {
    min-height: 50vh;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    font-style: italic;
    @include font-size(4);
    @include fgcolor(neutral, 5);
  }

  .pagi {
    margin-top: 0.75rem;
    @include flex($center: content);
    @include flex-gap(0.375rem, $child: '.page');
  }

  .page {
    &._disable {
      cursor: text;
    }

    &[data-level='0'] {
      display: inline-block;
    }

    &[data-level='1'] {
      @include props(display, none, $sm: inline-block);
    }

    &[data-level='2'] {
      @include props(display, none, $md: inline-block);
    }

    &[data-level='3'],
    &[data-level='4'] {
      @include props(display, none, $lg: inline-block);
    }
  }
</style>

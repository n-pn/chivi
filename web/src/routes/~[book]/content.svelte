<script context="module">
  export async function preload({ params, query }) {
    const bslug = params.book

    const res = await this.fetch(`/api/books/${bslug}`)
    const data = await res.json()

    if (!res.ok) return this.error(res.status, data.msg)

    let { book, mark } = data

    const seed = query.seed || book.seed_names[0] || ''
    const page = +(query.page || 1)

    const res2 = await fetch_data(this.fetch, book.ubid, seed, page, 0)
    return { book, mark, seed, page, chaps: res2.chaps, total: res2.total }
  }

  const limit = 30

  async function fetch_data(api, ubid, seed, page = 1, mode = 0) {
    let offset = (page - 1) * limit
    if (offset < 0) offset = 0

    const url = `/api/chaps/${ubid}/${seed}?mode=${mode}&limit=${limit}&offset=${offset}`
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

  export let chaps = []
  export let total = []

  $: has_seeds = book.seed_names.length > 0

  $: pmax = Math.floor((total - 1) / limit) + 1
  $: page_list = paginate_range(page, pmax, 7)

  let _load = false

  async function refresh_chaps(new_seed, mode = 0) {
    seed = new_seed
    if (mode == 0) return

    _load = true
    const res = await fetch_data(fetch, book.ubid, seed, page, mode)

    chaps = res.chaps
    total = res.total
    _load = false
  }

  function page_url(page) {
    return `/~${book.slug}/content?seed=${seed}&page=${page}`
  }

  let scroll_top
  function change_page(evt, new_page) {
    evt.preventDefault()

    if (new_page < 1) new_page = 1
    if (new_page > pmax) new_page = pmax
    if (new_page == page) return

    page = new_page

    refresh_chaps(seed, $self_power > 1)
    scroll_top.scrollIntoView({ behavior: 'smooth', block: 'start' })

    const url = new URL(window.location)
    url.searchParams.set('page', page)
    window.history.pushState({}, '', url)
  }

  function handleKeypress(evt) {
    if ($self_power < 1) return

    switch (evt.keyCode) {
      case 72:
        change_page(evt, 1)
        break

      case 76:
        change_page(evt, total)
        break

      case 37:
      case 74:
        if (!evt.altKey) change_page(evt, page - 1)

        break

      case 39:
      case 75:
        if (!evt.altKey) change_page(evt, page + 1)

        break

      default:
        break
    }
  }
</script>

<svelte:window on:keydown={handleKeypress} />

<Serial {book} {mark} atab="content">
  {#if has_seeds}
    <!-- <AdBanner /> -->

    <div class="seeds">
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
                href="/~{book.slug}/chlist?seed={name}"
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
          on:click={() => refresh_chaps(seed, $self_power > 2 ? 2 : 1)}>
          <SvgIcon name={_load ? 'loader' : 'clock'} spin={_load} />
          <span><RelTime time={book.seed_mftimes[seed]} {seed} /></span>
        </button>
      </div>
    </div>

    <div class="chaps" bind:this={scroll_top}>
      <ChapList bslug={book.slug} sname={seed} {chaps} />

      {#if pmax > 1}
        <nav class="pagi">
          <a
            href={page_url(1)}
            class="page m-button _line"
            class:_disable={page == 1}
            on:click={(e) => change_page(e, 1)}>
            <SvgIcon name="chevrons-left" />
          </a>

          <a
            href={page_url(page - 1)}
            class="page m-button _line"
            class:_disable={page < 2}
            on:click={(e) => change_page(e, page - 1)}>
            <SvgIcon name="chevron-left" />
          </a>

          {#each page_list as [curr, level]}
            <a
              href={page_url(curr)}
              class="page m-button _line"
              class:_disable={page == curr}
              data-level={level}
              on:click={(e) => change_page(e, curr)}>
              <span>{curr}</span>
            </a>
          {/each}

          <a
            href={page_url(page + 1)}
            class="page m-button _line"
            class:_disable={page + 1 >= pmax}
            on:click={(e) => change_page(e, page + 1)}>
            <SvgIcon name="chevron-right" />
          </a>

          <a
            href={page_url(pmax)}
            class="page m-button _line"
            class:_disable={page == pmax}
            on:click={(e) => change_page(e, pmax)}>
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

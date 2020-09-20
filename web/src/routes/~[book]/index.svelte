<script context="module">
  import { mark_types, mark_names, mark_icons } from '$utils/constants'

  export async function preload({ params, query }) {
    const bslug = params.book

    const res = await this.fetch(`/_books/${bslug}`)
    const data = await res.json()

    if (res.status == 200) {
      let { book } = data
      const seed = query.seed || book.seed_names[0] || ''

      const tab = query.tab || 'overview'
      const page = +(query.page || 1)
      const chlists = {}

      if (tab === 'content' && seed !== '') {
        const chaps = await fetch_chaps(this.fetch, bslug, seed, 0)
        book = update_last_chap(book, seed, chaps.chlist, chaps.mftime)
        chlists[seed] = chaps.chlist
      }

      return { book, mark: data.mark, seed: seed, tab, page, chlists }
    }

    this.error(res.status, data.msg)
  }

  export function update_last_chap(book_info, sname, chlist, mftime) {
    if (chlist.length == 0) return book_info
    const latest = chlist[chlist.length - 1]

    book_info.seed_latests[sname] = latest
    book_info.seed_mftimes[sname] = mftime
    if (book_info.mftime < mftime) book_info.mftime = mftime

    return book_info
  }

  export async function fetch_chaps(api, bslug, sname, mode = 0) {
    const url = `/_chaps/${bslug}/${sname}?mode=${mode}`

    try {
      const res = await api(url)
      const data = await res.json()

      if (res.status == 200) return data
      else throw data.msg
    } catch (err) {
      throw err.message
    }
  }
</script>

<script>
  import AIcon from '$atoms/AIcon'
  import ATime from '$atoms/ATime'

  import Vessel from '$parts/Vessel'
  import ChapList from '$melds/ChapList'

  import Outline from './_outline'

  import { self_uname, self_power } from '$src/stores'

  export let book
  export let mark = ''
  export let seed

  export let chlists = {}
  export let page = 1

  export let tab = 'overview'
  export let desc = true

  let chlist = []
  $: chlist = chlists[seed] || []
  $: hasContent = book.seed_names.length > 0

  $: if (tab == 'content') change_seed(seed, 0)

  let _loading = false

  async function change_seed(source, mode = 0) {
    seed = source
    if (mode == 0 && chlists[seed]) return

    _loading = true
    const { chlist, mftime } = await fetch_chaps(fetch, book.slug, seed, mode)
    _loading = false

    chlists[seed] = chlist

    chlists = chlists // trigger update
    book = update_last_chap(book, seed, chlist, mftime)
  }

  function change_tab(evt, new_tab) {
    // TODO: scrolling?
    evt.preventDefault()
    tab = new_tab
  }

  function last_chap_link(seed) {
    const latest = book.seed_latests[seed]
    if (!latest) return `/~${book.slug}?seed=${seed}&refresh=true`
    return `/~${book.slug}/${latest.url_slug}-${seed}-${latest.scid}`
  }

  function last_chap_text(seed) {
    const latest = book.seed_latests[seed]
    if (!latest) return '...'
    return latest.vi_title
  }

  async function mark_book(new_mark) {
    if (mark == new_mark) mark = ''
    else mark = new_mark

    await fetch(`/_self/book_mark/${book.ubid}?mark=${mark}`, { method: 'PUT' })
  }
</script>

<Vessel>
  <a slot="header-left" href="/~{book.slug}" class="header-item _active">
    <AIcon name="book-open" />
    <span class="header-text _title">{book.vi_title}</span>
  </a>

  <span slot="header-right" class="header-item _menu">
    <AIcon name={mark ? mark_icons[mark] : 'bookmark'} />
    <span
      class="header-text _show-md">{mark ? mark_names[mark] : 'Đánh dấu'}</span>

    {#if $self_power > 0}
      <div class="header-menu">
        {#each mark_types as type}
          <div class="-item" on:click={() => mark_book(type)}>
            <AIcon name={mark_icons[type]} />
            <span>{mark_names[type]}</span>

            {#if mark == type}
              <span class="_right">
                <AIcon name="check" />
              </span>
            {/if}
          </div>
        {/each}
      </div>
    {/if}
  </span>

  <Outline {book} />

  <section class="meta">
    <header class="meta-header">
      <a
        class="-tab"
        class:_active={tab == 'overview'}
        href="/~{book.slug}?tab=overview"
        on:click={(evt) => change_tab(evt, 'overview')}>
        Tổng quan
      </a>

      <a
        class="-tab"
        class:_active={tab == 'content'}
        href="/~{book.slug}?tab=content&seed={seed}"
        on:click={(evt) => change_tab(evt, 'content')}>
        Mục lục
      </a>

      <a
        class="-tab"
        class:_active={tab == 'reviews'}
        href="/~{book.slug}?tab=reviews"
        on:click={(evt) => change_tab(evt, 'reviews')}>
        Bình luận
      </a>
    </header>

    <div class="meta-tab" class:_active={tab == 'overview'}>
      <div class="summary">
        <h2>Giới thiệu:</h2>
        {#each book.vi_intro.split('\n') as line}
          <p>{line}</p>
        {/each}
      </div>

      {#if hasContent}
        <h2>Chương tiết:</h2>

        <table class="latests">
          <thead>
            <tr>
              <th class="latest-seed">Nguồn</th>
              <th class="latest-chap">Chương mới nhất</th>
              <th class="latest-time">Cập nhật</th>
            </tr>
          </thead>

          <tbody>
            {#each book.seed_names as name}
              <tr>
                <td class="latest-seed">
                  <span class="latest-text">{name}</span>
                </td>
                <td class="latest-chap">
                  <a class="latest-link" href={last_chap_link(name)}>
                    {last_chap_text(name)}
                  </a>
                </td>
                <td class="latest-time">
                  <span
                    class="latest-text _update"
                    on:click={() => change_seed(name, 1)}>
                    {#if seed == name && _loading}
                      <AIcon name="loader" spin={_loading} />
                    {:else}
                      <span><ATime
                          time={book.seed_mftimes[name]}
                          seed={name} /></span>
                    {/if}
                  </span>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      {/if}
    </div>

    <div class="meta-tab" class:_active={tab == 'content'}>
      {#if hasContent}
        <div class="sources">
          <div class="-left">
            <div class="-hint">Nguồn:</div>

            <div class="seed-menu">
              <div class="-text">
                <span class="-label">{seed}</span>
                <span class="-count">({chlist.length} chương)</span>
              </div>

              <div class="-menu">
                {#each book.seed_names as name}
                  <a
                    class="-item"
                    class:_active={seed === name}
                    href="/~{book.slug}?tab=content&seed={name}"
                    on:click|preventDefault={() => change_seed(name, 0)}
                    rel="nofollow">
                    <span class="-name">{name}</span>
                    <span class="-time">
                      <ATime time={book.seed_mftimes[name]} seed={name} />
                    </span>
                  </a>
                {/each}
              </div>
            </div>
          </div>

          <div class="-right">
            <button
              class="m-button _text"
              on:click={() => change_seed(seed, $self_power > 2 ? 2 : 1)}>
              <AIcon name={_loading ? 'loader' : 'clock'} spin={_loading} />
              <span><ATime time={book.seed_mftimes[seed]} {seed} /></span>
            </button>

            <button class="m-button _text" on:click={() => (desc = !desc)}>
              <AIcon name={desc ? 'arrow-down' : 'arrow-up'} />
              <span class="-hide">Sắp xếp</span>
            </button>
          </div>
        </div>

        <ChapList
          bslug={book.slug}
          sname={seed}
          chaps={chlist}
          focus={page}
          reverse={desc} />
      {:else}
        <div class="empty">Không có nội dung</div>
      {/if}
    </div>

    <div class="meta-tab" class:_active={tab == 'reviews'}>
      <div class="empty">Đang hoàn thiện :(</div>
    </div>
  </section>
</Vessel>

<style lang="scss">
  .genre > a {
    @include fgcolor(neutral, 6);
    @include hover {
      @include fgcolor(primary, 6);
    }
  }

  .summary {
    p {
      margin: 0.75rem 0;
      word-wrap: break-word;
      @include fgcolor(neutral, 7);

      $font-sizes: screen-vals(rem(15px), rem(16px), rem(17px));
      @include apply(font-size, $font-sizes);
    }
  }

  .sources {
    margin: 0.75rem 0 1.25rem;
    display: flex;

    .-left {
      display: flex;
      margin-right: 0.5rem;
    }

    .-hint {
      // display: none;
      // @include screen-min(sm) {
      //   display: inline-block;
      // }

      height: 2.25rem;
      line-height: 2.25rem;
      text-transform: uppercase;
      margin-right: 0.5rem;
      font-weight: 500;
      @include font-size(2);
      @include fgcolor(neutral, 7);
    }

    .-hide {
      display: none;
      @include screen-min(sm) {
        display: inline-block;
      }
    }

    .-right {
      @include flex($gap: 0.5rem);
      margin-left: auto;
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
      @include screen-min(sm) {
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

  .meta {
    background-color: #fff;
    margin: 0.75rem -0.75rem;
    padding: 0 0.75rem;
    border-radius: 0.75rem;
    @include shadow(2);
    @include screen-min(md) {
      margin-left: 0;
      margin-right: 0;
      padding-left: 1.5rem;
      padding-right: 1.5rem;
    }
  }

  $meta-height: 3rem;
  .meta-header {
    height: $meta-height;
    display: flex;
    @include border($sides: bottom, $color: neutral, $shade: 3);

    .-tab {
      height: $meta-height;
      line-height: $meta-height;
      width: 50%;
      font-weight: 500;
      text-align: center;
      text-transform: uppercase;

      @include font-size(2);
      @include screen-min(sm) {
        @include font-size(3);
      }

      @include fgcolor(neutral, 6);
      &._active {
        @include fgcolor(primary, 6);
        @include border(
          $sides: bottom,
          $color: primary,
          $shade: 5,
          $width: 2px
        );
      }
    }
  }

  .meta-tab {
    display: none;
    &._active {
      padding: 0.75rem 0;
      display: block;
      min-height: 50vh;
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

  .latests {
    width: 100%;
    max-width: 100%;
    margin-bottom: 0.75rem;

    tr {
      width: 100%;
      @include border($sides: bottom);
      &:nth-child(even) {
        @include bgcolor(neutral, 1);
      }
    }

    thead,
    thead tr {
      background: transparent;
    }

    th {
      border: none;
      padding: 0.375rem 0.75rem;
      text-transform: uppercase;
      font-weight: 500;
      @include font-size(2);
      @include fgcolor(neutral, 6);
    }

    th,
    td {
      border: none;
      @include truncate(null);
    }

    td {
      padding: 0;
    }

    td.latest-seed {
      max-width: 5rem;
      text-transform: uppercase;
      font-weight: 500;
      @include font-size(1);
    }

    .latest-time {
      display: none;
      @include screen-min(sm) {
        display: table-cell;
        max-width: 8.5rem;
        text-align: right;
      }
    }
  }

  .latest-text {
    display: block;
    padding: 0.375rem 0.75rem;
    @include fgcolor(neutral, 6);

    .latest-time & {
      @include font-size(2);
      cursor: pointer;
      @include hover {
        @include fgcolor(primary, 5);
      }
      // @include fgcolor(neutral, 5);
    }
  }

  .latest-chap {
    width: 40vw;
    @include truncate(null);

    max-width: 60vw;
    @include screen-min(sm) {
      max-width: 50vw;
    }
    @include screen-min(lg) {
      max-width: 40vw;
    }
  }

  .latest-link {
    display: block;
    @include truncate(null);

    width: auto;
    padding: 0.375rem 0.75rem;

    font-style: normal;
    font-weight: 400;

    @include fgcolor(neutral, 8);

    &:visited {
      font-style: italic;
      @include fgcolor(neutral, 5);
    }

    @include hover {
      @include fgcolor(primary, 6);
    }
  }
</style>

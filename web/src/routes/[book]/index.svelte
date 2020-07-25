<script context="module">
  export async function preload({ params, query }) {
    const book_slug = params.book
    const url = `_load_book?slug=${book_slug}`
    const tab = query.tab || 'overview'
    const page = +(query.page || 1)

    const res = await this.fetch(url)
    const data = await res.json()

    if (res.status == 200) {
      let { book } = data

      const seed_name = query.seed || book.seed_names[0] || ''

      const chlists = {}
      if (tab === 'content' && seed_name !== '') {
        const { chlist, mftime } = await loadChlist(
          this.fetch,
          book_slug,
          seed_name,
          false
        )
        book = updateLatest(book, seed_name, chlist, mftime)
        chlists[seed_name] = chlist
      }

      return { book, seed: seed_name, tab, page, chlists }
    }

    this.error(res.status, data.msg)
  }

  export function updateLatest(book_info, seed_name, chlist, mftime) {
    if (chlist.length == 0) return book_info
    const latest = chlist[chlist.length - 1]

    book_info.seed_latests[seed_name] = latest
    book_info.seed_mftimes[seed_name] = mftime
    if (book_info.mftime < mftime) book_info.mftime = mftime

    return book_info
  }

  export async function loadChlist(api, book_slug, seed_name, reload = false) {
    const url = `_get_chaps?slug=${book_slug}&seed=${seed_name}&reload=${reload}`

    try {
      const res = await api(url)
      const data = await res.json()

      if (res.status == 200) return data
      else throw data.msg
    } catch (err) {
      throw err.message
    }
  }

  export function mapStatus(status) {
    switch (status) {
      case 0:
        return 'Còn tiếp'
      case 1:
        return 'Hoàn thành'
      case 2:
        return 'Thái giám'
      default:
        return 'Không rõ'
    }
  }

  export function prepareKeywords(book) {
    return [
      book.vi_title,
      book.hv_title,
      book.vi_author,
      ...book.vi_genres,
      ...book.vi_tags,
    ].join(',')
  }
</script>

<script>
  import MIcon from '$mould/MIcon.svelte'
  import ChapList from '$reused/ChapList.svelte'
  import BookCover from '$reused/BookCover.svelte'

  import Header from '$layout/Header.svelte'

  import relative_time from '$utils/relative_time'
  import paginate_range from '$utils/paginate_range'

  export let book
  export let seed

  export let chlists = {}
  export let page = 1

  export let tab = 'overview'
  export let desc = true

  let chlist = []
  $: chlist = chlists[seed] || []
  $: hasContent = book.seed_names.length > 0

  $: if (tab == 'content') switchSite(seed, false)

  $: book_url = `https://chivi.xyz/${book.slug}/`
  $: cover_url = `https://chivi.xyz/covers/${book.ubid}.jpg`
  $: update = new Date(book.mftime)
  $: status = mapStatus(book.status)
  $: keywords = prepareKeywords(book)

  let __loading = false

  async function switchSite(source, reload = false) {
    seed = source
    if (reload == false && chlists[seed]) return

    __loading = true
    const { chlist, mftime } = await loadChlist(fetch, book.slug, seed, reload)
    __loading = false

    chlists[seed] = chlist

    desc = true
    chlists = chlists // trigger update
    book = updateLatest(book, seed, chlist, mftime)
  }

  function changeTab(newTab) {
    tab = newTab
  }

  function latestLink(seed_name) {
    const latest = book.seed_latests[seed_name]
    if (!latest) return `${book.slug}?seed=${seed_name}&refresh=true`
    return `/${book.slug}/${latest.url_slug}-${seed_name}-${latest.scid}`
  }

  function latestText(seed_name) {
    const latest = book.seed_latests[seed_name]
    if (!latest) return '...'
    return latest.vi_title
  }
</script>

<style lang="scss">
  .info {
    // display: flex;
    @include clearfix;
  }

  .cover {
    float: left;
    @include apply(width, screen-vals(40%, 30%, 25%));
  }

  .link {
    // font-weight: 500;
    @include fgcolor(primary, 6);
  }

  .genre > a {
    @include fgcolor(neutral, 6);
    &:hover {
      @include fgcolor(primary, 6);
    }
  }

  .name {
    margin-bottom: 0.75rem;
    @include apply(float, screen-vals(left, right));
    @include apply(width, screen-vals(100%, 70%, 75%));
    @include apply(padding-left, screen-vals(0, 0.75rem));
  }

  .extra {
    float: right;
    padding-left: 0.75rem;

    @include apply(width, screen-vals(60%, 70%, 75%));

    .-row {
      margin-bottom: 0.5rem;
      @include flex($gap: 0);
      flex-wrap: wrap;
    }

    .-col {
      margin-right: 0.5rem;
    }

    &,
    time {
      @include fgcolor(neutral, 6);
    }

    :global(svg) {
      margin-top: -0.125rem;
    }
  }

  .title {
    font-weight: 300;
    // @include fgcolor(neutral, 7);
    $line-heights: screen-vals(1.5rem, 1.75rem, 2rem);
    @include apply(line-height, $line-heights);
    $font-sizes: screen-vals(rem(26px), rem(28px), rem(30px));
    @include apply(font-size, $font-sizes);

    .-sub {
      font-size: 90%;
      line-height: inherit;
      // font-weight: 400;
      // letter-spacing: 0.1em;
      // @include fgcolor(neutral, 7);
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

  .author {
    font-weight: 500;
    > a {
      @include fgcolor(neutral, 6);
      @include hover {
        @include fgcolor(primary, 6);
      }
    }
    // @include font-size(4);
    //
  }

  .info {
    padding-top: 0.75rem;
  }

  .caption {
    margin-bottom: 0.75rem;

    > .label {
      margin-right: 0.25rem;
    }

    .label,
    .count {
      display: none;
      @include screen-min(sm) {
        display: inline-block;
      }
    }
  }

  .__loading {
    @include fgcolor(neutral, 5);

    :global(svg) {
      animation-name: spin;
      animation-duration: 1000ms;
      animation-iteration-count: infinite;
      animation-timing-function: linear;
    }
  }

  @keyframes spin {
    from {
      transform: rotate(0deg);
    }
    to {
      transform: rotate(360deg);
    }
  }

  .sources {
    margin-bottom: 0.75rem;
    justify-content: center;
    overflow: auto;
    @include flex($gap: 0.5rem);
  }

  .source-item {
    cursor: pointer;
    padding: 0 0.5rem;
    font-weight: 500;
    line-height: 2rem;
    text-transform: uppercase;
    @include border();
    @include radius();

    @include font-size(2);
    @include fgcolor(neutral, 7);

    &._active {
      @include fgcolor(primary, 5);
      @include bdcolor($color: primary, $shade: 5);
    }
  }

  .count {
    @include fgcolor(neutral, 6);
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

  strong {
    font-weight: 500;
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
      &:hover {
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

    &:hover {
      @include fgcolor(primary, 6);
    }
  }
</style>

<svelte:head>
  <title>{book.vi_title} - Chivi</title>
  <meta name="keywords" content={keywords} />
  <meta name="description" content={book.vi_intro} />
  <meta property="og:type" content="novel" />
  <meta property="og:title" content={book.vi_title} />
  <meta property="og:description" content={book.vi_intro} />
  <meta property="og:image" content={cover_url} />
  <meta property="og:novel:category" content={book.vi_genre} />
  <meta property="og:novel:author" content={book.vi_author} />
  <meta property="og:novel:book_name" content={book.vi_title} />
  <meta property="og:novel:read_url" content={book_url} />
  <meta property="og:url" content={book_url} />
  <meta property="og:novel:status" content={status} />
  <meta property="og:novel:update_time" content={update.toISOString()} />
</svelte:head>

<Header>
  <a slot="left" href="/{book.slug}" class="header-item _active">
    <MIcon class="m-icon _book-open" name="book-open" />
    <span class="header-text _title">{book.vi_title}</span>
  </a>
</Header>

<div class="wrapper">
  <section class="info">
    <div class="name">
      <h1 class="title">
        <span class="-main">{book.vi_title}</span>
        <span class="-sub">({book.zh_title})</span>
      </h1>
    </div>

    <div class="cover">
      <BookCover ubid={book.ubid} curl={book.main_cover} text={book.vi_title} />
    </div>

    <div class="extra">
      <div class="-row">
        <span class="-col author">
          <MIcon class="m-icon" name="pen-tool" />
          <a href="search?kw={book.vi_author}&type=author">{book.vi_author}</a>
        </span>

        {#each book.vi_genres as genre}
          <span class="-col genre">
            <MIcon class="m-icon _bookmark" name="bookmark" />
            <a href="/?genre={genre}">{genre}</a>
          </span>
        {/each}
      </div>

      <div class="-row">
        <span class="-col status">
          <MIcon class="m-icon" name="activity" />
          {status}
        </span>
        <span class="-col mftime">
          <MIcon class="m-icon" name="clock" />
          <time datetime={update}>{relative_time(book.mftime)}</time>
        </span>
      </div>

      <div class="-row">
        <span class="-col">
          Đánh giá:
          <strong>{book.voters < 10 ? '--' : book.rating}</strong>
          /10
        </span>
        <span class="-col">({book.voters} lượt đánh giá)</span>
      </div>

      {#if book.origin_url !== ''}
        <div class="-row">
          <span class="-col">Liên kết:</span>
          <a
            class="-col link"
            href={book.origin_url}
            rel="nofollow noreferer"
            target="_blank">
            Trang gốc
          </a>

          {#if book.yousuu_bid !== ''}
            <a
              class="-col link"
              href="https://www.yousuu.com/book/{book.yousuu_bid}"
              rel="nofollow noreferer"
              target="_blank">
              Ưu thư võng
            </a>
          {/if}
        </div>
      {/if}
    </div>
  </section>

  <section class="meta">
    <header class="meta-header">
      <a
        class="-tab"
        class:_active={tab == 'overview'}
        href="/{book.slug}?tab=overview"
        on:click|preventDefault={() => changeTab('overview')}>
        Tổng quan
      </a>

      <a
        class="-tab"
        class:_active={tab == 'content'}
        href="/{book.slug}?tab=content&seed={seed}"
        on:click|preventDefault={() => changeTab('content')}>
        Mục lục
      </a>

      <a
        class="-tab"
        class:_active={tab == 'reviews'}
        href="/{book.slug}?tab=reviews"
        on:click|preventDefault={() => changeTab('reviews')}>
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
                  <a class="latest-link" href={latestLink(name)}>
                    {latestText(name)}
                  </a>
                </td>
                <td class="latest-time">
                  <span
                    class="latest-text _update"
                    class:__loading={seed == name && __loading}
                    on:click={() => switchSite(name, true)}>
                    {#if seed == name && __loading}
                      <MIcon class="m-icon" name="loader" />
                    {:else}
                      <span>{relative_time(book.seed_mftimes[name])}</span>
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
        <div class="sources" data-active={seed}>
          {#each book.seed_names as name}
            <a
              class="source-item"
              class:_active={seed === name}
              href="/{book.slug}?seed={name}"
              on:click|preventDefault={() => switchSite(name, false)}
              rel="nofollow">
              {name}
            </a>
          {/each}
        </div>

        <h3 class="caption _recent u-cf">
          <span class="label u-fl">Nguồn:</span>
          <span class="count u-fl">{seed}</span>

          <button
            class="m-button _text u-fr"
            class:__loading
            on:click={() => switchSite(seed, true)}>
            {#if __loading}
              <MIcon class="m-icon" name="loader" />
            {:else}
              <MIcon class="m-icon" name="clock" />
            {/if}
            <span>{relative_time(book.seed_mftimes[seed])}</span>
          </button>

          <button class="m-button _text u-fr" on:click={() => (desc = !desc)}>
            {#if desc}
              <MIcon class="m-icon" name="arrow-down" />
            {:else}
              <MIcon class="m-icon" name="arrow-up" />
            {/if}
            <span>{chlist.length} chương</span>
          </button>
        </h3>

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

</div>

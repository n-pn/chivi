<script context="module">
  export async function preload({ params, query }) {
    const slug = params.book
    const url = `api/books/${slug}`
    const tab = query.tab || 'overview'
    const page = +(query.page || 1)

    const res = await this.fetch(url)
    const data = await res.json()

    if (res.status == 200) {
      const { book } = data
      const site = query.site || book.cr_site_df || ''

      let lists = {}
      if (tab === 'content' && site !== '') {
        const { chlist } = await loadContent(this.fetch, slug, site)
        book = updateLatest(book, site, chlist)
        lists[site] = chlist
      }

      return { book, site, tab, page, lists }
    }

    this.error(res.status, data.msg)
  }

  export function updateLatest(book, site, list) {
    if (list.length == 0) return book

    const lastest = list[list.length - 1]
    if (lastest) {
      book.cr_latests[site] = {
        csid: lastest.csid,
        name: lastest.vi_title,
        slug: lastest.title_slug,
      }
    }

    return book
  }

  export async function loadContent(api, slug, site, reload = false) {
    const url = `api/books/${slug}/${site}?reload=${reload}`

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
      book.vi_genre,
      ...book.vi_tags,
    ].join(',')
  }
</script>

<script>
  import MIcon from '$mould/MIcon.svelte'
  import Layout from '$layout/Layout.svelte'
  import ChapList from '$reused/ChapList.svelte'

  import relative_time from '$utils/relative_time'
  import paginate_range from '$utils/paginate_range'

  export let book
  export let site
  export let page = 1
  export let lists = {}

  export let tab = 'overview'
  export let latest = true

  let chaps = []
  $: chaps = lists[site] || []

  $: sources = Object.keys(book.cr_anchors)
  $: hasContent = sources.length > 0

  $: if (tab == 'content') changeSite(site, false)

  $: book_url = `https://chivi.xyz/${book.slug}/`
  $: cover_url = `https://chivi.xyz/covers/${book.uuid}.jpg`
  $: update = new Date(book.mftime)
  $: status = mapStatus(book.status)
  $: keywords = prepareKeywords(book)

  let reloading = false

  async function changeSite(source, reload = false) {
    site = source
    latest = true

    if (reload == false && lists[site]) return
    reloading = true

    const data = await loadContent(fetch, book.slug, site, reload)
    lists[site] = data.chlist
    lists = lists // trigger update

    const mftime = data.mftime
    if (book.mftime < mftime) book.mftime = mftime
    if (book.cr_mftimes[site] < mftime) book.cr_mftimes[site] = mftime

    book = updateLatest(book, site, data.chlist)
    reloading = false
  }

  function changeTab(newTab) {
    tab = newTab
  }

  function latestLink(site) {
    const latest = book.cr_latests[site]
    if (!latest) return `${book.slug}?site=${site}&refresh=true`
    return `/${book.slug}/${latest.slug}-${site}-${latest.csid}`
  }

  function latestText(site) {
    const latest = book.cr_latests[site]
    if (!latest) return '< bấm vào đây để cập nhật >'
    return latest.name
  }
</script>

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

<Layout>
  <a href="/" class="header-item" slot="header-left">
    <img src="/logo.svg" alt="logo" />
  </a>

  <a href="/{book.slug}" class="header-item _active _title" slot="header-left">
    <span>{book.vi_title}</span>
  </a>

  <section class="info">
    <div class="name">
      <h1 class="title">
        {book.vi_title}
        <span class="subtitle">({book.zh_title})</span>
      </h1>
    </div>

    <picture class="cover">
      <source srcset="/images/{book.uuid}.webp" type="image/webp" />
      <source srcset="/covers/{book.uuid}.jpg" type="image/jpeg" />
      <img src="/covers/{book.uuid}.jpg" alt={book.vi_title} loading="lazy" />
    </picture>

    <div class="extra">
      <div>
        <span class="author">
          <MIcon class="m-icon" name="pen-tool" />
          <a href="search?kw={book.vi_author}">{book.vi_author}</a>
        </span>

        <span class="author">
          <MIcon class="m-icon" name="pen-tool" />
          <a href="search?kw={book.zh_author}">{book.zh_author}</a>
        </span>
      </div>

      <div>
        <span class="genre">
          <MIcon class="m-icon" name="book" />
          {book.vi_genre}
        </span>
        <span class="status">
          <MIcon class="m-icon" name="activity" />
          {status}
        </span>
        <span class="mftime">
          <MIcon class="m-icon" name="clock" />
          <time datetime={update}>{relative_time(book.mftime)}</time>
        </span>
      </div>

      <div>
        <span>
          Đánh giá:
          <strong>{book.votes < 10 ? '--' : book.score}</strong>
          /10
        </span>
        <span>({book.votes} lượt đánh giá)</span>
      </div>

      {#if book.origin !== ''}
        <div>
          <span>Liên kết:</span>
          <a
            class="link"
            href={book.origin}
            rel="nofollow noreferer"
            target="_blank">
            Trang nguồn
          </a>

          {#if book.yousuu !== ''}
            <a
              class="link"
              href="https://www.yousuu.com/book/{book.yousuu}"
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
        class="meta-header-tab"
        class:_active={tab == 'overview'}
        href="/{book.slug}?tab=overview"
        on:click|preventDefault={() => changeTab('overview')}>
        Tổng quan
      </a>
      <a
        class="meta-header-tab"
        class:_active={tab == 'content'}
        href="/{book.slug}?tab=content"
        on:click|preventDefault={() => changeTab('content')}>
        Mục lục
      </a>
      <a
        class="meta-header-tab"
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
        <h2>Mới nhất:</h2>
        <table class="latests">
          <thead>
            <tr>
              <th class="latest-site">Nguồn</th>
              <th class="latest-chap">Chương cuối</th>
              <th class="latest-time">Đổi mới</th>
            </tr>
          </thead>

          <tbody>
            {#each sources as source}
              <tr>
                <td class="latest-site">
                  <span class="latest-text">{source}</span>
                </td>
                <td class="latest-chap">
                  <a class="latest-link" href={latestLink(source)}>
                    {latestText(source)}
                  </a>
                </td>
                <td class="latest-time">
                  <span
                    class="latest-text _update"
                    class:_reload={site == source && reloading}
                    on:click={() => changeSite(source, true)}>
                    {#if site == source && reloading}
                      <MIcon class="m-icon" name="loader" />
                    {:else}
                      <time>{relative_time(book.cr_mftimes[source])}</time>
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
        <div class="sources" data-active={site}>
          {#each sources as source}
            <a
              class="source-item"
              class:_active={site === source}
              href="/{book.slug}?site={source}"
              on:click|preventDefault={() => changeSite(source, false)}
              rel="nofollow">
              {source}
            </a>
          {/each}
        </div>

        <h3 class="caption _recent u-cf" data-site={site}>
          <!-- <MIcon class="m-icon u-fl" name="list" /> -->
          <span class="label u-fl">Mục lục:</span>
          <span class="count u-fl">({chaps.length} chương)</span>

          <button
            class="m-button _text u-fr"
            class:_reload={reloading}
            on:click={() => changeSite(site, true)}>
            {#if reloading}
              <MIcon class="m-icon" name="loader" />
            {:else}
              <MIcon class="m-icon" name="clock" />
            {/if}
            <span>{relative_time(book.cr_mftimes[site])}</span>
          </button>

          <button
            class="m-button _text u-fr"
            on:click={() => (latest = !latest)}>
            {#if latest}
              <MIcon class="m-icon" name="arrow-down" />
            {:else}
              <MIcon class="m-icon" name="arrow-up" />
            {/if}
            <span>Sắp xếp</span>
          </button>

        </h3>

        <ChapList
          bslug={book.slug}
          sname={site}
          {chaps}
          focus={page}
          reverse={latest} />
      {:else}
        <div class="empty">Không có nội dung</div>
      {/if}
    </div>

    <div class="meta-tab" class:_active={tab == 'reviews'}>
      <div class="empty">Đang hoàn thiện :(</div>
    </div>
  </section>

</Layout>

<style lang="scss">
  .info {
    // display: flex;
    @include clearfix;
  }

  .cover {
    float: left;
    @include apply(width, screen-vals(40%, 30%, 25%));

    > img {
      width: 100%;
      @include radius();
    }
  }

  .link {
    // font-weight: 500;
    @include fgcolor(primary, 6);
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

    > div {
      @include clearfix;
      margin-bottom: 0.25rem;
      > * {
        float: left;
        margin-right: 0.5rem;
      }
    }

    &,
    time {
      @include fgcolor(neutral, 6);
    }

    :global(svg) {
      margin-top: -0.125rem;
    }
  }

  // h2 {
  //   @include fgcolor(neutral, 6);
  // }

  .title {
    // margin-top: 0.75rem;
    // margin: 0.25rem 0;

    $font-sizes: screen-vals(rem(26px), rem(28px), rem(30px));
    $line-heights: screen-vals(1.5rem, 1.75rem, 2rem);

    @include apply(font-size, $font-sizes);
    @include apply(line-height, $line-heights);
  }

  .summary {
    @include fgcolor(neutral, 7);
    p {
      $font-sizes: screen-vals(rem(15px), rem(16px), rem(17px));
      @include apply(font-size, $font-sizes);
    }
    p + p {
      margin-top: 0.75rem;
    }

    // p {
    //   margin: 0.75rem;
    //   margin-top: 0;
    // }
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

  .subtitle {
    // letter-spacing: 0.1em;
    // font-weight: 400;
    font-size: 85%;
    // @include fgcolor(neutral, 6);
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

  ._reload {
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
    @include border($sides: bottom, $color: color(neutral, 3));
    height: $meta-height;
    display: flex;
  }

  .meta-header-tab {
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
      @include border($sides: bottom, $color: color(primary, 5), $width: 2px);
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

    td.latest-site {
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
      // @include fgcolor(neutral, 5);
    }
  }

  .latest-chap {
    width: 35rem;

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
    @include truncate();

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

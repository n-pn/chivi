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

      let chlist = []
      if (tab === 'content' && site !== '') {
        const data = await loadContent(this.fetch, slug, site)
        chlist = data.chlist
      }

      return { book, site, tab, page, chlist }
    }

    this.error(res.status, data.msg)
  }

  export async function loadContent(api, slug, site, reload = false) {
    const key = `${slug}|${site}`

    // if (!reload) {
    //   const data = cachedContent[key]
    //   if (data) return data
    // }

    let url = `api/books/${slug}/${site}?reload=${reload}`
    try {
      const res = await api(url)
      const data = await res.json()

      if (res.status == 200) return data
      else throw data.msg
    } catch (err) {
      throw err.message
    }
  }

  export function translateStatus(status) {
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

  export function mapVolumes(list) {
    if (!list) return {}

    let volumes = {}
    for (const chap of list) {
      volumes[chap.vi_volume] = volumes[chap.vi_volume] || []
      volumes[chap.vi_volume].push(chap)
    }
    return volumes
  }

  export function mapContent(list, page = 1) {
    const limit = 50
    let offset = (page - 1) * limit
    if (offset < 0) offset = 0
    return list.slice(offset, offset + limit)
  }

  export function mapLatests(list, size = 6) {
    if (!list) return []
    if (list.length <= size) return list

    const start = list.length - 1
    let stop = start - size + 1
    if (stop < 0) stop = 0

    const output = []
    for (let i = start; i >= stop; i--) output.push(list[i])
    return output
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
  export let chlist = []

  export let tab = 'overview'
  let activeTab = tab

  $: sources = Object.keys(book.cr_anchors)
  $: hasContent = sources.length > 0

  $: changeSite(site, false)
  $: latest = mapLatests(chlist)

  $: book_url = `https://chivi.xyz/${book.slug}/`
  $: cover_url = `https://chivi.xyz/covers/${book.uuid}.jpg`
  $: update = new Date(book.mftime)
  $: status = translateStatus(book.status)
  $: keywords = prepareKeywords(book)

  let reloading = false

  async function changeSite(source, reload = false) {
    if (site == source && reload == false && chlist.length > 0) return

    site = source
    reloading = true

    const data = await loadContent(fetch, book.slug, site, reload)
    chlist = data.chlist

    const mftime = data.mftime
    if (book.mftime < mftime) book.mftime = mftime
    if (book.cr_mftimes[site] < mftime) book.cr_mftimes[site] = mftime

    book = book
    reloading = false
  }

  function changeTab(newTab) {
    activeTab = newTab
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
          {book.vi_author}
        </span>

        <span class="author">
          <MIcon class="m-icon" name="pen-tool" />
          <span>{book.zh_author}</span>
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
        class:_active={activeTab == 'overview'}
        href="/{book.slug}?tab=overview"
        on:click|preventDefault={() => changeTab('overview')}>
        Tổng quan
      </a>
      <a
        class="meta-header-tab"
        class:_active={activeTab == 'content'}
        href="/{book.slug}?tab=content"
        on:click|preventDefault={() => changeTab('content')}>
        Mục lục
      </a>
      <a
        class="meta-header-tab"
        class:_active={activeTab == 'reviews'}
        href="/{book.slug}?tab=reviews"
        on:click|preventDefault={() => changeTab('reviews')}>
        Bình luận
      </a>
    </header>

    <div class="meta-tab" class:_active={activeTab == 'overview'}>
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
              <th class="latest-chap">Chương mới nhất</th>
              <th class="latest-time">Thời gian đổi mới</th>
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
                  <span class="latest-text">
                    {relative_time(book.cr_mftimes[source])}
                  </span>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      {/if}
    </div>

    <div class="meta-tab" class:_active={activeTab == 'content'}>
      {#if hasContent}
        <div class="meta-sites" data-active={site}>
          {#each sources as source}
            <a
              class="meta-site"
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
          <span class="label u-fl">Mới nhất:</span>

          <button
            class="m-button _text u-fr"
            class:_reload={reloading}
            on:click={() => changeSite(site, true)}>
            {#if reloading}
              <MIcon class="m-icon" name="loader" />
            {:else}
              <span>{relative_time(book.cr_mftimes[site])}</span>
            {/if}
          </button>
        </h3>

        <ChapList bslug={book.slug} sname={site} chaps={latest} focus={page} />

        <h3 class="caption _content u-cf">
          <span class="label u-fl">Mục lục:</span>
          <span class="count u-fl">({chlist.length} chương)</span>
        </h3>

        <ChapList bslug={book.slug} sname={site} chaps={chlist} focus={page} />
      {:else}
        <div class="empty">Không có nội dung</div>
      {/if}
    </div>

    <div class="meta-tab" class:_active={activeTab == 'reviews'}>
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
    @include props(width, attrs(40%, 30%, 25%));

    > img {
      width: 100%;
      @include radius();
    }
  }

  .link {
    // font-weight: 500;
    @include fgcolor(color(primary, 6));
  }

  .name {
    margin-bottom: 0.75rem;
    @include props(float, attrs(left, right));
    @include props(width, attrs(100%, 70%, 75%));
    @include props(padding-left, attrs(0, 0.75rem));
  }

  .extra {
    float: right;
    padding-left: 0.75rem;

    @include props(width, attrs(60%, 70%, 75%));

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
      @include fgcolor(color(neutral, 6));
    }

    :global(svg) {
      margin-top: -0.125rem;
    }
  }

  // h2 {
  //   @include fgcolor(color(neutral, 6));
  // }

  .title {
    // margin-top: 0.75rem;
    // margin: 0.25rem 0;

    $font-sizes: attrs(rem(26px), rem(28px), rem(30px));
    $line-heights: attrs(1.5rem, 1.75rem, 2rem);

    @include props(font-size, $font-sizes);
    @include props(line-height, $line-heights);
  }

  .summary {
    @include fgcolor(color(neutral, 7));
    p {
      $font-sizes: attrs(rem(15px), rem(16px), rem(17px));
      @include props(font-size, $font-sizes);
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
    // @include font-size(4);
    // @include fgcolor(color(neutral, 6));
  }

  .subtitle {
    // letter-spacing: 0.1em;
    // font-weight: 400;
    font-size: 85%;
    // @include fgcolor(color(neutral, 6));
  }

  .info {
    padding-top: 0.75rem;
  }

  .caption {
    margin-bottom: 0.75rem;
    // @include fgcolor(color(neutral, 6));
    // > :global(.m-icon) {
    //   margin-top: 0.375rem;
    // }

    &._content {
      margin-top: 0.75rem;
    }

    > .label {
      margin-right: 0.25rem;
    }

    > .count {
      display: none;
      @include screen-min(sm) {
        display: inline-block;
      }
    }
  }

  .m-button._reload {
    @include fgcolor(color(neutral, 5));

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

  .meta-sites {
    display: block;
    // margin-bottom: 0.75rem;
    justify-content: center;
    @include flex($gap: 0.5rem);
  }

  .meta-site {
    cursor: pointer;
    padding: 0 0.5rem;
    font-weight: 500;
    line-height: 2rem;
    text-transform: uppercase;
    @include border();
    @include radius();

    @include font-size(2);
    @include fgcolor(color(neutral, 7));

    &._active {
      @include fgcolor(color(primary, 5));
      @include border-color($value: color(primary, 5));
    }
  }

  .count {
    @include fgcolor(color(neutral, 6));
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
    @include border($pos: bottom, $color: color(neutral, 3));
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

    @include fgcolor(color(neutral, 6));
    &._active {
      @include fgcolor(color(primary, 6));
      @include border($pos: bottom, $color: color(primary, 5), $width: 2px);
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
    @include fgcolor(color(neutral, 5));
  }

  strong {
    font-weight: 500;
  }

  .latests {
    width: 100%;
    max-width: 100%;

    tr {
      width: 100%;
      @include border($pos: bottom);
      &:nth-child(even) {
        @include bgcolor(color(neutral, 1));
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
      @include font-size(1);
      @include fgcolor(color(neutral, 6));
    }

    th,
    td {
      border: none;
      @include truncate(null);
    }

    td {
      padding: 0;
    }

    .latest-site {
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
    @include fgcolor(color(neutral, 6));

    .latest-time & {
      @include font-size(2);
      // @include fgcolor(color(neutral, 5));
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
    padding: 0.375rem 0.75rem;
    font-weight: 400;
    font-style: italic;
    width: auto;
    @include truncate();

    @include fgcolor(color(neutral, 6));
    &:hover {
      @include fgcolor(color(primary, 6));
    }
  }
</style>

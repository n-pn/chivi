<script context="module">
  export async function preload({ params, query }) {
    const slug = params.book
    const site = query.site

    let url = `api/books/${slug}`
    if (site) url += `/${site}`

    try {
      const res = await this.fetch(url)
      const data = await res.json()

      if (res.status == 200) return data

      this.error(res.status, data.msg)
    } catch (err) {
      this.error(500, err.message)
    }
  }

  export function relative_time(time) {
    const span = (new Date().getTime() - time) / 1000

    if (span < 60) return '< 1 phút trước'
    if (span < 60 * 60) return `${Math.round(span / 60)} phút trước`
    if (span < 60 * 60 * 24) return `${Math.round(span / 3600)} giờ trước`

    return new Date(time).toISOString().split('T')[0]
  }

  export function book_status(status) {
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

  export function map_volumes(chlist) {
    let volumes = {}
    for (const chap of chlist) {
      volumes[chap.vi_volume] = volumes[chap.vi_volume] || []
      volumes[chap.vi_volume].push(chap)
    }
    return volumes
  }

  export function get_latests(chlist) {
    const start = chlist.length - 1
    let stop = start - 5
    if (stop < 0) stop = 0

    const res = []
    for (let i = start; i >= stop; i--) {
      res.push(chlist[i])
    }

    return res
  }
</script>

<script>
  import MIcon from '$mould/shared/MIcon.svelte'
  import Header from '$mould/layout/Header.svelte'
  import LinkBtn from '$mould/layout/header/LinkBtn.svelte'
  import Wrapper from '$mould/layout/Wrapper.svelte'

  export let book
  export let site
  export let bsid
  export let chlist = []

  $: volumes = map_volumes(chlist)
  $: latests = get_latests(chlist)
</script>

<style type="text/scss">
  .info {
    display: flex;
  }

  .cover {
    margin-right: auto;
    width: 30%;
    img {
      width: 100%;
      @include radius();
    }
  }

  .intro {
    padding-left: 0.75rem;
    margin-left: auto;
    width: 70%;
  }

  .summary {
    @include color(neutral, 7);
  }

  .metadata {
    margin-top: 0.5rem;
    &,
    time {
      @include color(neutral, 5);
    }

    * + * {
      margin-left: 0.5rem;
    }

    :global([m-icon]) {
      margin-top: -0.125rem;
    }
  }

  h2 {
    margin-top: 0.75rem;
  }

  h3 {
    margin-top: 0.75rem;
    padding-left: 0.75rem;
  }

  .chap-list {
    margin-top: 0.25rem;
    // margin: .75rem auto;
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(20rem, 1fr));
    grid-gap: 0 0.5rem;
  }

  .chap-item {
    &:nth-child(odd) {
      background-color: #fff;
    }

    @include border($side: bottom);
    &:first-child {
      @include border($side: top);
    }

    @include screen-min(sm) {
      &:nth-child(2) {
        @include border($side: top);
      }
      &:nth-child(4n),
      &:nth-child(4n + 1) {
        background-color: #fff;
      }

      &:nth-child(4n + 2),
      &:nth-child(4n + 3) {
        background-color: color(neutral, 1);
      }
    }
  }

  .chap-link {
    display: block;
    @include color(neutral, 7);

    padding: 0.5rem 0.75rem;

    @include hover {
      @include color(primary, 5);
    }
    // time {
    //   @include color(neutral, 5);
    // }
  }

  .title {
    margin-bottom: 0;
  }

  .subtitle {
    margin-top: 0.25rem;
    letter-spacing: 0.1em;
    // font-weight: 300;
    @include color(neutral, 7);
  }

  .chap-title {
    @include truncate();
  }

  .info,
  .summary,
  .content {
    padding-left: 0.75rem;
    padding-right: 0.75rem;
  }

  .info {
    padding-top: 0.75rem;
  }

  .tabs {
    display: block;
    margin: 0.75rem;
    padding-top: 0.375rem;
    // display: flex;
    // height: 2rem;
    @include border($side: top);
    line-height: 2rem;

    @include clearfix;

    > span {
      float: left;
      margin-top: 0.375rem;
      @include font-size(5);
      font-weight: 500;
      // min-width: 6rem;
    }
  }

  .site {
    float: left;
    text-transform: uppercase;
    margin-left: 0.375rem;
    margin-top: 0.375rem;
    padding: 0 0.5rem;
    font-weight: 500;
    cursor: pointer;
    @include color(neutral, 7);
    @include font-size(2);

    @include border();
    @include radius();
    &._active {
      border-color: color(primary, 5);
      @include color(primary, 5);
    }
  }

  .label {
    @include color(neutral, 6);
  }
</style>

<svelte:head>
  <title>{book.vi_title} - Chivi</title>
  <meta
    name="keywords"
    content="{book.vi_title},{book.zh_title},{book.vi_author},{book.zh_author}" />
  <meta name="description" content={book.vi_intro} />
  <meta property="og:type" content="novel" />
  <meta property="og:title" content={book.vi_title} />
  <meta property="og:description" content={book.vi_intro} />
  <meta property="og:image" content={book.covers[0]} />
  <meta property="og:novel:category" content={book.vi_genre} />
  <meta property="og:novel:author" content={book.vi_author} />
  <meta property="og:novel:book_name" content={book.vi_title} />
  <meta
    property="og:novel:read_url"
    content="http://chivi.xyz/{book.vi_slug}/" />
  <meta property="og:url" content="http://chivi.xyz/{book.vi_slug}/" />
  <meta property="og:novel:status" content={book_status(book.status)} />
  <meta
    property="og:novel:update_time"
    content={new Date(book.updated_at).toISOString()} />
  <meta property="og:novel:latest_chapter_name" content={latests[0].vi_title} />
  <meta
    property="og:novel:latest_chapter_url"
    content="https://chivi.xyz/{book.vi_slug}/{latests[0].url_slug}-{site}-{latests[0].csid}.html" />
</svelte:head>

<Header>
  <div class="left">
    <LinkBtn href="/">
      <img src="/logo.svg" alt="logo" />
    </LinkBtn>

    <LinkBtn href="/{book.vi_slug}" class="active">
      <span>{book.vi_title}</span>
    </LinkBtn>
  </div>
</Header>

<Wrapper>
  <div class="info">
    <picture class="cover">
      {#each book.covers as cover}
        <source srcset={cover} />
      {/each}
      <img src="img/nocover.png" alt={book.vi_title} />
    </picture>

    <div class="intro">
      <h1 class="title">{book.vi_title} - {book.vi_author}</h1>
      <h2 class="subtitle">{book.zh_title} — {book.zh_author}</h2>
      <div class="metadata">
        <span class="genre">
          <MIcon m-icon="book" />
          {book.vi_genre}
        </span>

        <span class="chap_count">
          <MIcon m-icon="list" />
          {book.chap_count} chương
        </span>

        <span class="status">
          <MIcon m-icon="activity" />
          {book_status(book.status)}
        </span>

        <time class="updated_at" datetime={new Date(book.updated_at)}>
          <MIcon m-icon="clock" />
          {relative_time(book.updated_at)}
        </time>

      </div>

    </div>
  </div>

  <div class="summary">
    <h2>Giới thiệu:</h2>
    {#each book.vi_intro.split('\n') as line}
      <p>{line}</p>
    {/each}
  </div>

  <div class="tabs">
    <span>Chọn nguồn:</span>
    {#each Object.keys(book.crawl_links) as crawl}
      <a
        class="site"
        class:_active={site == crawl}
        href="/{book.vi_slug}?site={crawl}">
        {crawl}
      </a>
    {/each}
  </div>

  <h2 class="content" data-site={site} data-bsid={bsid}>
    Mục lục
    <span class="label">({chlist.length} chương)</span>
  </h2>

  <h3>
    Mới nhất
    <span class="label">({latests.length} chương)</span>
  </h3>
  <div class="chap-list">
    {#each latests as chap}
      <div class="chap-item">
        <a
          class="chap-link"
          href="/{book.vi_slug}/{chap.url_slug}-{site}-{chap.csid}">
          <div class="chap-title">{chap.vi_title}</div>
        </a>
      </div>
    {/each}
  </div>

  {#each Object.entries(volumes) as [label, chlist]}
    <h3>
      {label}
      <span class="label">({chlist.length} chương)</span>
    </h3>
    <div class="chap-list">
      {#each chlist as chap}
        <div class="chap-item">
          <a
            class="chap-link"
            href="/{book.vi_slug}/{chap.url_slug}-{site}-{chap.csid}">
            <div class="chap-title">{chap.vi_title}</div>
          </a>
        </div>
      {/each}
    </div>
  {/each}
</Wrapper>

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
  import MIcon from '$mould/MIcon.svelte'
  import Header from '$layout/Header.svelte'

  export let book
  export let site
  export let bsid
  export let chlist = []

  import { onMount } from 'svelte'
  import { lookup_active } from '$src/stores.js'
  onMount(() => lookup_active.set(false))

  $: volumes = map_volumes(chlist)
  $: latests = get_latests(chlist)
</script>

<style type="text/scss">
  .info {
    // display: flex;
    @include clearfix;
  }

  .cover {
    float: left;
    @include props(width, attrs(40%, 30%));

    > img {
      width: 100%;
      @include radius();
    }
  }

  .name {
    margin-bottom: 0.75rem;
    @include props(float, attrs(left, right));
    @include props(width, attrs(100%, 70%));
    @include props(padding-left, attrs(0, 0.75rem));
  }

  .extra {
    float: right;
    padding-left: 0.75rem;

    @include props(width, attrs(60%, 70%));

    > div {
      @include clearfix;
      margin-bottom: 0.25rem;
      > * {
        float: left;

        & + * {
          margin-left: 0.5rem;
        }
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

  .summary {
    @include fgcolor(color(neutral, 7));
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
    &:last-child {
      margin-bottom: 0.75rem;
    }
    // margin: .75rem auto;
    @include grid($size: minmax(20rem, 1fr), $gap: 0 0.5rem);
  }

  .chap-item {
    &:nth-child(odd) {
      background-color: #fff;
    }

    @include border($pos: bottom);
    &:first-child {
      @include border($pos: top);
    }

    @include screen-min(sm) {
      &:nth-child(2) {
        @include border($pos: top);
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
    @include fgcolor(color(neutral, 7));

    padding: 0.5rem 0.75rem;

    @include hover {
      @include fgcolor(color(primary, 5));
    }
    // time {
    //   @include fgcolor(color(neutral, 5));
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

  .chap-title {
    @include truncate();
  }

  .info,
  .summary,
  .content {
    @include padding(left-right, 0.75rem);
  }

  .info {
    padding-top: 0.75rem;
  }

  .tabs {
    display: block;
    margin: 0.75rem;
    // padding-top: 0.375rem;
    line-height: 2rem;
    @include border($pos: top);

    @include clearfix;

    > span {
      float: left;
      margin-top: 0.5rem;
      font-weight: 500;
      @include font-size(5);
      // min-width: 6rem;
    }
  }

  .site {
    float: left;
    text-transform: uppercase;
    margin-left: 0.5rem;
    margin-top: 0.5rem;
    padding: 0 0.5rem;
    font-weight: 500;
    cursor: pointer;
    @include fgcolor(color(neutral, 7));
    @include font-size(2);

    @include border();
    @include radius();
    &._active {
      @include fgcolor(color(primary, 5));
      @include border-color($value: color(primary, 5));
    }
  }

  .label {
    @include fgcolor(color(neutral, 6));
  }

  strong {
    font-weight: 500;
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
    <a href="/" class="header-item">
      <img src="/logo.svg" alt="logo" />
    </a>

    <a href="/{book.vi_slug}" class="header-item _active">
      <span>{book.vi_title}</span>
    </a>
  </div>
</Header>

<div class="wrapper">
  <div class="info">
    <div class="name">
      <h1 class="title">
        {book.vi_title}
        <span class="subtitle">({book.zh_title})</span>
      </h1>
    </div>

    <picture class="cover">
      {#each book.covers as cover}
        <source srcset={cover} />
      {/each}
      <img src="img/nocover.png" alt={book.vi_title} />
    </picture>

    <div class="extra">
      <div>
        <span class="author">
          <MIcon class="m-icon" name="pen-tool" />
          {book.vi_author}
          <span>({book.zh_author})</span>
        </span>
      </div>
      <div>

        <span class="genre">
          <MIcon class="m-icon" name="book" />
          {book.vi_genre}
        </span>
        <span class="status">
          <MIcon class="m-icon" name="activity" />
          {book_status(book.status)}
        </span>
        <time class="updated_at" datetime={new Date(book.updated_at)}>
          <MIcon class="m-icon" name="clock" />
          {relative_time(book.updated_at)}
        </time>
      </div>
      <!--
      <div>
        <span class="prefer_site">
          <MIcon class="m-icon" name="link" />
          {book.prefer_site}
        </span>
        <span class="chap_count">
          <MIcon class="m-icon" name="list" />
          {book.chap_count} chương
        </span>
      </div> -->

      <div>
        <div>
          Đánh giá:
          <strong>{book.score}</strong>
          /10 ({book.votes} lượt đánh giá)
        </div>
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

</div>

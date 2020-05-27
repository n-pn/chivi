<script context="module">
  export async function preload({ params, query }) {
    const slug = params.book

    let url = `api/books/${slug}`
    const refresh = query.refresh == 'true'

    try {
      const res = await this.fetch(url)
      const data = await res.json()

      if (res.status != 200) this.error(res.status, data.msg)
      else {
        const { book } = data
        const site = query.site || book.cr_site_df

        let list = []
        if (site != '') {
          const list_data = await load_list(
            this.fetch,
            book.slug,
            site,
            refresh
          )
          if (list_data.status == 200) list = list_data.list
        }
        return { book, site, list }
      }
    } catch (err) {
      this.error(500, err.message)
    }
  }

  export async function load_list(api, slug, site, refresh = false) {
    let url = `api/books/${slug}/${site}?refresh=${refresh}`
    try {
      const res = await api(url)
      const data = await res.json()

      if (res.status == 200)
        return { status: 200, list: data.list, bsid: data.bsid }
      else return { status: res.status, message: data.msg }
    } catch (err) {
      return { status: 500, message: err.message }
    }
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

  export function map_volumes(list) {
    let volumes = {}
    for (const chap of list) {
      volumes[chap.vi_volume] = volumes[chap.vi_volume] || []
      volumes[chap.vi_volume].push(chap)
    }
    return volumes
  }

  export function get_latests(list) {
    const start = list.length - 1
    let stop = start - 5
    if (stop < 0) stop = 0

    const res = []
    for (let i = start; i >= stop; i--) {
      res.push(list[i])
    }

    return res
  }
</script>

<script>
  import MIcon from '$mould/MIcon.svelte'
  import Layout from '$layout/Layout.svelte'

  import ChapList from '$reused/ChapList.svelte'

  import { onMount } from 'svelte'
  import { lookup_active } from '$src/stores.js'

  import relative_time from '$utils/relative_time'

  export let book
  export let site
  export let list = []

  onMount(() => lookup_active.set(false))

  $: sites = Object.keys(book.cr_anchors)
  $: volumes = map_volumes(list)
  $: latests = get_latests(list)

  $: cover_url = `https://chivi.xyz/covers/${book.uuid}.jpg`
  $: updated_at = new Date(book.mftime * 1000)
  $: status = book_status(book.status)
  $: book_url = `https://chivi.xyz/${book.slug}/`
  $: keywords = [
    book.vi_title,
    book.zh_title,
    book.hv_title,
    book.vi_author,
    book.zh_author,
    book.vi_genre,
    book.zh_genre,
  ]

  let reloading = false
  async function updateList() {
    reloading = true
    const data = await load_list(fetch, book.slug, site, true)
    reloading = false
    if (data.status == 200) list = data.list
  }
</script>

<svelte:head>
  <title>{book.vi_title} - Chivi</title>
  <meta name="keywords" content={keywords.join(',')} />
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
  <meta property="og:novel:update_time" content={updated_at.toISOString()} />
</svelte:head>

<Layout>
  <a href="/" class="header-item" slot="header-left">
    <img src="/logo.svg" alt="logo" />
  </a>

  <a href="/{book.slug}" class="header-item _active" slot="header-left">
    <span>{book.vi_title}</span>
  </a>

  <div class="info">
    <div class="name">
      <h1 class="title">
        {book.vi_title}
        <span class="subtitle">({book.zh_title})</span>
      </h1>
    </div>

    <picture class="cover">
      <img src="/covers/{book.uuid}.jpg" alt={book.vi_title} />
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
          {status}
        </span>
        <span class="updated_at">
          <MIcon class="m-icon" name="clock" />
          <time datetime={updated_at}>{relative_time(book.mftime)}</time>
        </span>

      </div>

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

  {#if sites.length > 0}
    <div class="tabs">
      <span>Chọn nguồn:</span>
      {#each sites as crawl}
        <a
          class="site"
          class:_active={site == crawl}
          href="/{book.slug}?site={crawl}">
          {crawl}
        </a>
      {/each}
    </div>

    <h2 class="content u-cf" data-site={site}>
      <!-- <MIcon class="m-icon u-fl" name="list" /> -->
      <span class="label u-fl">Mục lục</span>
      <span class="count u-fl">({list.length} chương)</span>
      <button
        class="m-button _text u-fr"
        class:_reload={reloading}
        on:click={updateList}>
        {#if reloading}
          <MIcon class="m-icon" name="loader" />
        {:else}
          <span>Đổi mới: {relative_time(book.cr_mftimes[site])}</span>
        {/if}
      </button>
    </h2>

    <ChapList bslug={book.slug} label="Mới nhất" chaps={latests} />
    {#each Object.entries(volumes) as [label, chaps]}
      <ChapList bslug={book.slug} {label} {chaps} />
    {/each}
  {/if}

</Layout>

<style lang="scss">
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

  .content {
    // margin-left: 0.5rem;
    // @include fgcolor(color(neutral, 6));
    // > :global(.m-icon) {
    //   margin-top: 0.375rem;
    // }

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

  .tabs {
    display: block;
    margin: 0.75rem 0;
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

  .count {
    @include fgcolor(color(neutral, 6));
  }

  strong {
    font-weight: 500;
  }
</style>

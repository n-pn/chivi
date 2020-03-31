<script context="module">
  export async function preload({ params, query }) {
    const slug = params.book
    const site = query.site

    let url = `api/books/${slug}`
    if (site) url += `/${site}`

    try {
      const res = await this.fetch(url)
      const data = await res.json()
      return data
    } catch (err) {
      this.error(404, err.message)
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
</script>

<script>
  import MIcon from '$mould/shared/MIcon.svelte'
  import Header from '$mould/layout/Header.svelte'
  import LinkBtn from '$mould/layout/header/LinkBtn.svelte'
  import Wrapper from '$mould/layout/Wrapper.svelte'

  export let book
  export let site
  export let chlist = []

  let volumes = {}
  $: {
    for (const chap of chlist) {
      volumes[chap.vi_volume] = volumes[chap.vi_volume] || []
      volumes[chap.vi_volume].push(chap)
    }
  }
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

    // min-width: 10rem;
    // @include screen-min(md) {
    //   min-width: 12rem;
    // }

    // @include screen-min(lg) {
    //   min-width: 14rem;
    // }
    // @include screen-min(xl) {
    //   min-width: 16rem;
    // }
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
    // text-transform: uppercase;
    // font-weight: 500;
    // @include font-size(3);
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
  h2,
  .summary {
    padding-left: 0.75rem;
    padding-right: 0.75rem;
  }

  .info {
    padding-top: 0.75rem;
  }
</style>

<svelte:head>
  <title>{book.vi_title} - Chivi</title>
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
      <h2 class="subtitle">{book.zh_title} - {book.zh_author}</h2>
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

  <h2>Giới thiệu:</h2>
  <div class="summary">
    {#each book.vi_intro.split('\n') as line}
      <p>{line}</p>
    {/each}
  </div>

  <h2>Danh sách chương:</h2>
  {#each Object.entries(volumes) as [label, chlist]}
    <h3>{label} ({chlist.length} chương)</h3>
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

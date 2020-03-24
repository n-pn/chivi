<script context="module">
  export async function preload({ params }) {
    const slug = params.book

    const url = `api/books/${slug}`
    console.log(encodeURI(url))

    const res = await this.fetch(url)
    const data = await res.json()

    if (!!data.entry) {
      return data
    } else {
      this.error(404, 'Book not found!')
    }
  }

  export function relative_time(time) {
    const span = (new Date().getTime() - time) / 1000

    if (span < 60) return '< 1 phút trước'
    if (span < 60 * 60) return `${span / 60} phút trước`
    if (span < 60 * 60 * 24) return `${span / 3600} giờ trước`

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
  export let entry
  export let chaps = []

  let volumes = {}
  $: {
    for (const chap of chaps) {
      volumes[chap.vi_volume] = volumes[chap.vi_volume] || []
      volumes[chap.vi_volume].push(chap)
    }
  }

  import MIcon from '$mould/MIcon.svelte'
</script>

<style type="text/scss">
  .bread {
    line-height: 2.5em;
    // @include responsive-gap();
    padding-left: 0;
    padding-right: 0;
    @include font-size(2);
    @include screen-min(lg) {
      @include font-size(3);
    }
  }

  .crumb {
    padding: 0;
    margin: 0;
    &,
    a {
      @include color(neutral, 5);
    }

    @include hover {
      a {
        cursor: pointer;
        @include color(primary, 5);
      }
    }
    &:after {
      margin-left: 0.25rem;
      @include color(neutral, 4);
      content: '>';
    }
    &:last-child:after {
      display: none;
    }
  }

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
    padding-left: 1rem;
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
    margin-top: 1rem;
  }

  h3 {
    margin-top: 1rem;
    padding-left: 0.75rem;
  }

  .chap-list {
    margin-top: 0.5rem;
    // margin: 1rem auto;
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(16.5rem, 1fr));
    grid-gap: 0 0.5rem;
  }

  .chap-item {
    &:nth-child(odd) {
      background-color: #fff;
    }
    @include screen-min(sm) {
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
    @include border($side: bottom);
    padding: 0.25rem 0.75rem;

    @include hover {
      @include color(primary, 5);
    }
    time {
      @include color(neutral, 5);
    }
  }

  .chap-title {
    @include truncate();
  }
</style>

<svelte:head>
  <title>{entry.vi_title} -- Chivi</title>
</svelte:head>

<div class="bread">
  <span class="crumb">
    <a class="crumb-link" href="/">Home</a>
  </span>
  <span class="crumb">
    <a class="crumb-link" href="/?genre={entry.vi_genre}">{entry.vi_genre}</a>
  </span>
  <span class="crumb">{entry.vi_title}</span>

</div>

<div class="info">
  <picture class="cover">
    {#each entry.covers as cover}
      <source srcset={cover} />
    {/each}
    <img src="img/nocover.png" alt={entry.vi_title} />
  </picture>

  <div class="intro">
    <h1 class="title">{entry.vi_title} - {entry.vi_author}</h1>
    <div class="metadata">
      <span class="genre">
        <MIcon m-icon="book" />
        {entry.vi_genre}
      </span>

      <span class="chap_count">
        <MIcon m-icon="list" />
        {entry.chap_count} chương
      </span>

      <span class="status">
        <MIcon m-icon="activity" />
        {book_status(entry.status)}
      </span>

      <time class="updated_at" datetime={new Date(entry.updated_at)}>
        <MIcon m-icon="clock" />
        {relative_time(entry.updated_at)}
      </time>

    </div>

  </div>
</div>

<h2>Giới thiệu:</h2>
<div class="summary">
  {#each entry.vi_intro.split('\n') as line}
    <p>{line}</p>
  {/each}
</div>

<h2>Danh sách chương:</h2>
{#each Object.entries(volumes) as [label, chaps]}
  <h3>{label} ({chaps.length} chương)</h3>
  <div class="chap-list">
    {#each chaps as chap}
      <div class="chap-item">
        <a class="chap-link" href="/{entry.vi_slug}/{chap.uid}-{chap.url_slug}">
          <div class="chap-title">{chap.vi_title}</div>
          <time class="chap-time" datetime={new Date(chap.updated_at)}>
            {relative_time(chap.created_at)}
          </time>

        </a>

      </div>
    {/each}
  </div>
{/each}

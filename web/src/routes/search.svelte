<script context="module">
  export async function preload({ query }) {
    const kw = query.kw
    query = kw.replace(/\+|-/g, ' ')

    if (kw) {
      const url = `api/search?kw=${kw}`
      const res = await this.fetch(url)
      const items = await res.json()
      return { items, query }
    } else {
      return { items: [], query }
    }
  }
</script>

<script>
  import MIcon from '$mould/MIcon.svelte'
  import Header from '$layout/Header.svelte'

  export let items = []
  export let query = ''
</script>

<svelte:head>
  <title>Tìm kiếm - Chivi</title>
</svelte:head>

<Header>
  <div class="left">
    <a href="/" class="header-item _logo">
      <img src="/logo.svg" alt="logo" />
    </a>

    <input
      type="search"
      name="kw"
      class="header-item _input _active"
      placeholder="Tìm kiếm"
      value={query}
      on:focus={evt => evt.stopPropagation()} />

  </div>
</Header>

<div class="wrapper">
  <h1 class="label">
    Tìm được {items.length}{items.length == 8 ? '+' : ''} kết quả cho "{query}"
    :
  </h1>

  <div class="list">
    {#each items as book}
      <a class="book" href={book.slug}>
        <picture class="cover">
          <img src="/covers/{book.uuid}.jpg" alt={book.vi_title} />
        </picture>

        <div class="name">
          <h2 class="title">
            {book.vi_title}
            <span class="subtitle">({book.zh_title})</span>
          </h2>
        </div>

        <div class="extra">
          <div>
            <span class="author">
              {book.vi_author}
              <span>({book.zh_author})</span>
            </span>
          </div>

          <div>
            <span>
              Đánh giá:
              <strong>{book.score}</strong>
              /10
            </span>
          </div>
        </div>
      </a>
    {/each}
  </div>
</div>

<style lang="scss">
  .list {
    // width: 35rem;
    max-width: 100%;

    padding: 0.75rem;
    margin: 0 auto;

    @include grid($gap: 0.75rem, $size: minmax(18rem, 1fr));
  }

  .book {
    display: block;
    padding: 0.5rem;

    @include bgcolor(white);
    @include radius();
    @include shadow(1);

    @include clearfix;
    @include hover {
      @include shadow(2);
      .title {
        @include fgcolor(color(primary, 5));
      }
    }
  }

  .title {
    // font-weight: 300;
    @include font-size(5);
    line-height: 1.75rem;
    @include fgcolor(color(neutral, 7));
  }

  strong {
    font-weight: 500;
  }

  .cover {
    float: left;
    @include radius();
    @include props(width, attrs(30%, 30%));

    position: relative;
    overflow: hidden;

    @include clearfix;

    &:before {
      content: '';
      display: block;
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 0;
      padding-top: (4/3) * 100%;
      @include bgcolor(color(primary, 7));
      z-index: -1;
    }

    > img {
      width: 100%;
      height: 100%;
      @include radius();
    }
  }

  .name {
    float: right;
    margin-bottom: 0.375rem;
    padding-left: 0.5rem;
    @include props(width, attrs(70%, 70%));
  }

  .extra {
    float: right;
    padding-left: 0.5rem;

    @include props(width, attrs(70%, 70%));

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

    & {
      @include fgcolor(color(neutral, 6));
    }

    :global(svg) {
      margin-top: -0.125rem;
    }
  }

  .label {
    text-align: center;

    @include props(margin-top, attrs(1rem, 1.5rem, 2rem));
    @include props(margin-bottom, attrs(0rem, 0.5rem, 1rem));
    @include props(font-size, attrs(font-size(5), font-size(6), font-size(7)));
    @include props(line-height, attrs(1.5rem, 1.75rem, 2rem));
    @include fgcolor(color(neutral, 6));
  }
</style>

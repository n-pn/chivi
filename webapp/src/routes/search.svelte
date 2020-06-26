<script context="module">
  export async function preload({ query }) {
    const word = (query.kw || '').replace(/\+|-/g, ' ')
    const page = +(query.pg || '1')

    if (word) {
      const url = `api/search?word=${word}&page=${page}`
      const res = await this.fetch(url)
      const { total, items } = await res.json()
      return { total, items, word, page }
    } else {
      return { total: 0, items: [], word, page: 1 }
    }
  }
</script>

<script>
  import MIcon from '$mould/MIcon.svelte'
  import Layout from '$layout/Layout.svelte'

  export let word = ''
  export let page = 1

  export let items = []
  export let total = 0

  const limit = 8
  $: offset = (page - 1) * limit
  $: pmax = Math.round((total - 1) / limit) + 1
</script>

<svelte:head>
  <title>Tìm kiếm - Chivi</title>
</svelte:head>

<Layout searchKey={word}>
  <h1 class="label">
    Hiển thị kết quả {offset + 1}~{offset + items.length}/{total} cho từ khoá "{word}"
    :
  </h1>

  <div class="list" data-page={page}>
    {#each items as book}
      <a class="book" href={book.slug} rel="prefetch">
        <picture class="cover">
          <source srcset="/images/{book.uuid}.webp" type="image/webp" />
          <source srcset="/covers/{book.uuid}.jpg" type="image/jpeg" />
          <img src="/covers/{book.uuid}.jpg" alt="" loading="lazy" />
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

  {#if page < pmax}
    <div class="pagi">
      <a
        class="m-button _line"
        href="search?kw={word}&pg={page > 1 ? page - 1 : 1}">
        <MIcon name="chevron-left" />
        <span>Trước</span>
      </a>

      <a
        class="m-button _line _primary"
        href="search?kw={word}&pg={page < pmax ? page + 1 : pmax}">
        <span>Kế tiếp</span>
        <MIcon name="chevron-right" />
      </a>
    </div>
  {/if}
</Layout>

<style lang="scss">
  .list {
    // width: 35rem;
    max-width: 100%;

    padding: 0.75rem 0;
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
        @include fgcolor(primary, 5);
      }
    }
  }

  .title {
    // font-weight: 300;
    @include font-size(5);
    line-height: 1.75rem;
    @include fgcolor(neutral, 7);
  }

  strong {
    font-weight: 500;
  }

  .cover {
    float: left;
    @include radius();
    @include apply(width, screen-vals(35%, 30%));

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
      @include bgcolor(primary, 7);
      z-index: -1;
    }

    > img {
      width: 100%;
      height: auto;
      @include radius();
    }
  }

  .name {
    float: right;
    margin-bottom: 0.375rem;
    padding-left: 0.5rem;
    @include apply(width, screen-vals(65%, 70%));
  }

  .extra {
    float: right;
    padding-left: 0.5rem;

    @include apply(width, screen-vals(65%, 70%));

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
      @include fgcolor(neutral, 6);
    }

    :global(svg) {
      margin-top: -0.125rem;
    }
  }

  .label {
    text-align: center;

    @include apply(margin-top, screen-vals(1rem, 1.5rem, 2rem));
    @include apply(margin-bottom, screen-vals(0rem, 0.5rem, 1rem));
    @include apply(
      font-size,
      screen-vals(font-size(5), font-size(6), font-size(7))
    );
    @include apply(line-height, screen-vals(1.5rem, 1.75rem, 2rem));
    @include fgcolor(neutral, 6);
  }

  .pagi {
    @include flex($gap: 0.75rem, $child: '.m-button');
    justify-content: center;
    .m-button {
      width: 6.25rem;
      :global(svg) {
        margin-top: rem(-1px);
      }
    }
  }
</style>

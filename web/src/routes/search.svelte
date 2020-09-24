<script context="module">
  export const limit = 8

  export async function preload({ query }) {
    const word = (query.kw || '').replace(/\+|-/g, ' ')
    const page = +(query.page || '1')
    const type = query.type || 'fuzzy'

    if (word) {
      const url = `/_books?word=${word}&page=${page}&limit=${limit}&order=weight&type=${type}`
      const res = await this.fetch(url)
      const data = await res.json()
      return { word, page, type, total: data.total, items: data.items }
    } else {
      return { word, page: 1, type, total: 0, items: [] }
    }
  }
</script>

<script>
  import Vessel from '$parts/Vessel'

  import SvgIcon from '$atoms/SvgIcon.svelte'
  import BookCover from '$atoms/BookCover.svelte'

  export let word = ''
  export let page = 1
  export let type = 'fuzzy'

  export let items = []
  export let total = 0

  $: offset = (+page - 1) * limit
  $: pmax = Math.floor((+total - 1) / limit) + 1

  function searchUrl(page) {
    if (page < 1) page = 1
    if (page > pmax) page = pmax
    return `/search?kw=${word}&page=${page}&type=${type}`
  }
</script>

<svelte:head>
  <title>Kết quả tìm kiếm cho "{word}" - Chivi</title>
</svelte:head>

<Vessel>
  <form slot="header-left" class="header-field" action="/search" method="get">
    <input type="search" name="kw" placeholder="Tìm kiếm" value={word} />
    <SvgIcon name="search" />
  </form>

  {#if items.length > 0}
    <h1>
      Hiển thị kết quả {offset + 1}~{offset + items.length}/{total} cho từ khoá "{word}":
    </h1>

    <div class="list" data-page={page}>
      {#each items as book}
        <a class="book" href="/~{book.slug}" rel="external">
          <div class="cover">
            <BookCover ubid={book.ubid} path={book.main_cover} />
          </div>

          <div class="infos">
            <div class="extra">
              <h2>{book.vi_title}</h2>
            </div>

            <div class="extra _sep">
              <h3>{book.zh_title}</h3>
            </div>

            <div class="extra">
              <span class="label _sub">Tác giả:</span>
              <span class="value">{book.vi_author}</span>
            </div>

            <div class="extra">
              <span class="label">Thể loại:</span>
              <span class="value">{book.vi_genres[0]}</span>
            </div>

            <div class="extra">
              <span class="label">Đánh giá:</span>
              <span class="value">{book.rating == 0 ? '--' : book.rating}</span>
              <span class="label _cram">/10</span>
            </div>
          </div>
        </a>
      {/each}
    </div>

    <div class="pagi">
      <a
        class="m-button _line"
        class:_disable={page == 1}
        href={searchUrl(page - 1)}>
        <SvgIcon name="chevron-left" />
        <span>Trước</span>
      </a>

      <span class="m-button _line _primary _disable"><span>{page}</span></span>

      <a
        class="m-button _solid _primary"
        class:_disable={page == pmax}
        href={searchUrl(page + 1)}>
        <span>Kế tiếp</span>
        <SvgIcon name="chevron-right" />
      </a>
    </div>
  {:else}
    <h1>Không tìm được kết quả phù hợp cho từ khoá "{word}"</h1>
  {/if}
</Vessel>

<style lang="scss">
  .list {
    // width: 35rem;
    max-width: 100%;

    padding: 0.75rem 0;
    margin: 0 auto;

    @include grid($gap: 0.75rem, $size: minmax(18rem, 1fr));
  }

  h1 {
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

  .book {
    display: block;
    padding: 0.5rem;

    @include bgcolor(white);
    @include radius();
    @include shadow(1);

    @include clearfix;

    &:hover {
      @include shadow(2);

      h2,
      h3 {
        @include fgcolor(primary, 5);
      }
    }
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
      padding-top: #{4 / 3} * 100%;
      @include bgcolor(primary, 7);
      z-index: -1;
    }

    :global(img) {
      width: 100%;
      height: auto;
      @include radius();
    }
  }

  .infos {
    float: right;
    @include apply(width, screen-vals(65%, 70%));
    padding-left: 0.5rem;

    > * + * {
      margin-top: 0.25rem;
    }
  }

  h2,
  h3 {
    line-height: 1.5rem;
    font-weight: 400;
    @include truncate();
  }

  h2 {
    @include font-size(5);
    @include fgcolor(neutral, 8);

    @include screen(md) {
      padding-top: 0.25rem;
      padding-bottom: 0.25rem;
    }
  }

  h3 {
    @include font-size(4);
    @include fgcolor(neutral, 7);
  }

  .extra {
    // @include clearfix;
    // > * {
    //   float: left;
    // }

    // > * + * {
    //   margin-left: 0.5rem;
    // }

    ._cram {
      margin-left: 0;
    }
  }

  .label {
    @include fgcolor(neutral, 6);

    &._sub {
      display: none;
      @include screen(md) {
        display: inline-block;
      }
    }
  }

  .value {
    font-weight: 500;
    @include truncate(null);
    @include fgcolor(neutral, 6);
  }

  .pagi {
    @include flex($gap: 0.75rem, $child: '.m-button');
    justify-content: center;
    margin-bottom: 0.75rem;

    .m-button {
      span {
        padding-top: rem(1px);
      }
    }
  }
</style>

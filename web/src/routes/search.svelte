<script context="module">
  import Vessel from '$layout/Vessel'

  import SIcon from '$blocks/SIcon.svelte'
  import BCover from '$blocks/BCover.svelte'

  export const take = 8

  export async function preload({ query }) {
    const word = (query.kw || '').replace(/\+|-/g, ' ')
    const page = +(query.page || '1')
    const type = query.type || 'btitle'

    if (word) {
      let skip = (page - 1) * take
      if (skip < 0) skip = 0

      let url = `/api/nvinfos?skip=${skip}&take=${take}`
      if (type == 'author') url += `&author=${word}`
      else url += `&btitle=${word}`

      const res = await this.fetch(url)
      const { books, total } = await res.json()
      return { word, page, type, books, total }
    } else {
      return { word, page: 1, type, total: 0, books: [] }
    }
  }
</script>

<script>
  export let word = ''
  export let page = 1
  export let type = 'btitle'

  export let books = []
  export let total = 0

  $: skip = (page - 1) * take
  $: pmax = Math.floor((+total - 1) / take) + 1

  function make_url(page) {
    if (page < 1) page = 1
    if (page > pmax) page = pmax

    let url = `/search?kw=${word}&page=${page}`
    if (type != 'btitle') url += `&type=${type}`

    return url
  }
</script>

<svelte:head>
  <title>Kết quả tìm kiếm cho "{word}" - Chivi</title>
</svelte:head>

<Vessel>
  <form slot="header-left" class="header-field" action="/search" method="get">
    <input type="search" name="kw" placeholder="Tìm kiếm" value={word} />
    <SIcon name="search" />
  </form>

  {#if books.length > 0}
    <h1>
      Hiển thị kết quả
      {skip + 1}~{skip + books.length}/{total}
      cho từ khoá "{word}":
    </h1>

    <div class="list" data-page={page}>
      {#each books as book}
        <a href="/~{book.bslug}" class="book">
          <div class="cover">
            <BCover bhash={book.bhash} bcover={book.bcover} />
          </div>

          <div class="infos">
            <div class="extra _title">
              <span class="-vi -trim">{book.btitle_vi}</span>
            </div>

            <div class="extra _subtitle">
              <small class="-zh -trim">{book.btitle_zh}</small>
            </div>

            <div class="extra _author">
              <span class="value -trim">{book.author_vi}</span>
            </div>

            <div class="extra">
              <span class="label">Thể loại:</span>
              <span class="value">{book.genres[0]}</span>
            </div>

            <div class="extra">
              <span class="label">Đánh giá:</span>
              <span class="value">{book.rating == 0 ? '--' : book.rating}</span
              ><span class="label">/10</span>
            </div>
          </div>
        </a>
      {/each}
    </div>

    <div class="pagi">
      <a href={make_url(page - 1)} class="m-button" class:_disable={page == 1}>
        <SIcon name="chevron-left" />
        <span>Trước</span>
      </a>

      <div class="m-button _primary _disable"><span>{page}</span></div>

      <a
        href={make_url(page + 1)}
        class="m-button _solid _primary"
        class:_disable={page == pmax}>
        <span>Kế tiếp</span>
        <SIcon name="chevron-right" />
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

    @include grid($size: minmax(18rem, 1fr));
    @include grid-gap($gap: 0.75rem);
  }

  h1 {
    text-align: center;

    @include props(margin-top, 1rem, 1.5rem, 2rem);
    @include props(margin-bottom, 0rem, 0.5rem, 1rem);
    @include props(font-size, font-size(5), font-size(6), font-size(7));
    @include props(line-height, 1.5rem, 1.75rem, 2rem);
    @include fgcolor(neutral, 6);
  }

  .book {
    display: block;
    padding: 0.5rem;

    @include bgcolor(white);
    @include radius();
    @include shadow(1);

    @include flow;

    &:hover {
      @include shadow(2);

      .-zh,
      .-vi {
        @include fgcolor(primary, 5);
      }
    }
  }

  .cover {
    float: left;
    @include radius();
    @include props(width, 35%, 30%);

    position: relative;
    overflow: hidden;

    @include flow;

    &:before {
      content: '';
      display: block;
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 0;
      padding-top: (4 / 3) * 100%;
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

    padding-left: 0.5rem;
    width: 65%;
    @include props(width, 65%, 70%);
  }

  .extra {
    @include flow();
    margin-top: 0.25rem;

    > * {
      float: left;
    }
    > * + * {
      margin-left: 0.25rem;
    }
  }

  .-vi,
  .-zh {
    display: inline-block;
  }

  .-vi {
    line-height: 1.5rem;
    // font-weight: 500;
    @include font-size(5);
    @include fgcolor(neutral, 8);
  }

  .-zh {
    line-height: 1.25rem;
    margin-bottom: 0.25rem;
    @include font-size(4);
    @include fgcolor(neutral, 7);
  }

  .label {
    @include fgcolor(neutral, 6);
  }

  .value {
    font-weight: 500;
    @include fgcolor(neutral, 6);
  }

  .-trim {
    display: inline-block;
    max-width: 100%;
    @include truncate(null);
  }

  .pagi {
    margin-bottom: 0.75rem;
    @include flex($center: content);
    @include flex-gap($gap: 0.75rem, $child: '.m-button');
  }
</style>

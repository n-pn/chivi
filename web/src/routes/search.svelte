<script context="module">
  export async function load({ fetch, page: { query } }) {
    const word = (query.get('q') || '').replace(/\+|-/g, ' ')
    const page = +query.get('p') || 1
    const type = query.get('t') || 'btitle'

    if (word) {
      const url = `/api/cvbooks?take=8&page=${page}&${type}=${word}`

      const res = await fetch(url)
      const data = await res.json()
      return {
        props: { ...data, word, page, type },
      }
    } else {
      return {
        props: { word, page: 1, type, total: 0, books: [] },
      }
    }
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import BCover from '$atoms/BCover.svelte'
  import Vessel from '$sects/Vessel.svelte'

  export let word = ''
  export let page = 1
  export let type = 'btitle'

  export let books = []
  export let total = 0
  export let pgidx = 0
  export let pgmax = 0

  function make_url(page) {
    if (page < 1) page = 1
    if (page > pgmax) page = pgmax

    let url = `/search?q=${word}&p=${page}`
    if (type != 'btitle') url += `&t=${type}`

    return url
  }
</script>

<svelte:head>
  <title>Kết quả tìm kiếm cho "{word}" - Chivi</title>
</svelte:head>

<Vessel>
  <svelte:fragment slot="header-left">
    <form class="header-field" action="/search" method="get">
      <input type="search" name="q" placeholder="Tìm kiếm" value={word} />
      <SIcon name="search" />
    </form>
  </svelte:fragment>

  {#if pgmax > 0}
    <h1>
      Hiển thị kết quả
      {(pgidx - 1) * 8 + 1}~{(pgidx - 1) * 8 + books.length}/{total}
      cho từ khoá "{word}":
    </h1>

    <div class="list" data-page={page}>
      {#each books.slice(0, 8) as book}
        <a href="/-{book.bslug}" class="book">
          <div class="cover">
            <BCover bcover={book.bcover} />
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
        class="m-button _fill _primary"
        class:_disable={page == pgmax}>
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

    display: grid;
    grid-gap: 0.75rem;
    grid-template-columns: repeat(auto-fill, minmax(18rem, 1fr));
  }

  h1 {
    text-align: center;
    @include fgcolor(secd, 6);

    @include fluid(margin-top, 1rem, 1.5rem, 2rem);
    @include fluid(margin-bottom, 0rem, 0.5rem, 1rem);
    @include fluid(font-size, font-size(5), font-size(6), font-size(7));
    @include fluid(line-height, 1.5rem, 1.75rem, 2rem);
  }

  .book {
    display: block;
    padding: 0.5rem;

    @include bgcolor(white);
    @include bdradi();
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
    @include bdradi();
    @include fluid(width, 35%, 30%);

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
      padding-top: math.div(4, 3) * 100%;
      @include bgcolor(primary, 7);
      z-index: -1;
    }

    :global(img) {
      width: 100%;
      height: auto;
      @include bdradi();
    }
  }

  .infos {
    float: right;

    padding-left: 0.5rem;
    width: 65%;
    @include fluid(width, 65%, 70%);
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
    @include ftsize(xl);
    @include fgcolor(neutral, 8);
  }

  .-zh {
    line-height: 1.25rem;
    margin-bottom: 0.25rem;
    @include ftsize(lg);
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
    @include clamp($width: null);
  }

  .pagi {
    margin-bottom: 0.75rem;
    @include flex($center: horz, $gap: 0.75rem);
  }
</style>

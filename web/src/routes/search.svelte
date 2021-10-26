<script context="module">
  export async function load({ fetch, page: { query } }) {
    const page = +query.get('page') || 1
    const type = query.get('t') || 'btitle'

    const input = query.get('q')
    if (!input) return { props: { input, type } }

    const qs = input.replace(/\+|-/g, ' ')
    const url = `/api/books?order=weight&take=8&page=${page}&${type}=${qs}`
    const res = await fetch(url)
    return { props: { input, type, ...(await res.json()) } }
  }
</script>

<script>
  import { page } from '$app/stores'
  import SIcon from '$atoms/SIcon.svelte'
  import BCover from '$atoms/BCover.svelte'
  import Header from '$sects/Header.svelte'
  import Vessel from '$sects/Vessel.svelte'
  import Mpager, { Pager } from '$molds/Mpager.svelte'

  export let input = ''
  export let books = []
  export let pgidx = 0
  export let pgmax = 0

  $: from = (pgidx - 1) * 8 + 1
  $: upto = from + books.length - 1
  $: pager = new Pager($page.path, $page.query)
</script>

<svelte:head>
  <title>Kết quả tìm kiếm cho "{input}" - Chivi</title>
</svelte:head>

<Header>
  <svelte:fragment slot="left">
    <form class="header-field" action="/search" method="get">
      <input type="search" name="q" placeholder="Tìm kiếm" value={input} />
      <SIcon name="search" />
    </form>
  </svelte:fragment>
</Header>

<Vessel>
  {#if pgmax > 0}
    <h1>Hiển thị kết quả từ {from} tới {upto} cho từ khoá "{input}":</h1>
  {:else}
    <h1>Không tìm được kết quả phù hợp cho từ khoá "{input}"</h1>
  {/if}

  <div class="list">
    {#each books.slice(0, 8) as book}
      <a href="/-{book.bslug}" class="book">
        <div class="cover">
          <BCover bcover={book.bcover} />
        </div>

        <div class="infos">
          <div class="extra _title">
            <span class="-vi -trim">{book.vtitle}</span>
          </div>

          <div class="extra _subtitle">
            <small class="-zh -trim">{book.ztitle}</small>
          </div>

          <div class="extra _author">
            <span class="value -trim">{book.vauthor}</span>
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

  <svelte:fragment slot="footer">
    {#if books.length > 0}
      <Mpager {pager} {pgidx} {pgmax} />
    {/if}
  </svelte:fragment>
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

    @include bps(margin-top, 1rem, 1.5rem, 2rem);
    @include bps(margin-bottom, 0rem, 0.5rem, 1rem);
    @include bps(font-size, font-size(5), font-size(6), font-size(7));
    @include bps(line-height, 1.5rem, 1.75rem, 2rem);
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
    @include bps(width, 35%, 30%);

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
    @include bps(width, 65%, 70%);
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
</style>

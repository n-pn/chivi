<script context="module">
  export async function preload({ query }) {
    const page = query.page || 1
    let url = `api/books?page=${page}`
    const sort = query.sort || 'access'
    url += `&sort=${sort}`

    const res = await this.fetch(url)
    const data = await res.json()
    return Object.assign(data, { page })
  }

  export function page_url(page = 1, sort = 'access') {
    const params = {}
    if (page > 1) params.page = page
    if (sort !== 'access') params.sort = sort

    const query = Object.entries(params)
      .map(([k, v]) => `${k}=${v}`)
      .join('&')

    if (query) return `/?${query}`
    return '/'
  }
</script>

<script>
  import MIcon from '$mould/MIcon.svelte'
  import Layout from '$layout/Layout.svelte'

  export let items = []
  export let total = 0
  export let page = 1
  export let sort = 'access'

  const sorts = {
    access: 'Vừa xem',
    update: 'Mới cập nhật',
    score: 'Đánh giá',
    votes: 'Lượt đánh giá',
    tally: 'Tổng hợp',
  }

  $: pageMax = Math.floor((total - 1) / 20) + 1
  $: pageList = make_pageList(page, pageMax)

  function make_pageList(currPage, pageMax) {
    let pageFrom = currPage - 2
    if (pageFrom < 1) pageFrom = 1

    let pageUpto = pageFrom + 4
    if (pageUpto > pageMax) {
      pageUpto = pageMax
      pageFrom = pageUpto - 4
      if (pageFrom < 1) pageFrom = 1
    }

    // console.log({ pageFrom, pageUpto })
    let output = []
    for (let i = pageFrom; i <= pageUpto; i++) output.push(i)
    return output
  }
</script>

<svelte:head>
  <title>Chivi - Chinese to Vietname Machine Translation</title>
</svelte:head>

<Layout>

  <div class="sort">
    <span class="label">Sắp xếp theo:</span>
    {#each Object.entries(sorts) as [type, label]}
      <a class="type" class:_active={sort == type} href="/?sort={type}">
        {label}
      </a>
    {/each}
  </div>
  <div class="list">
    {#each items as book}
      <a class="book" href={book.slug} rel="prefetch">
        <picture class="-cover">
          <img src="/covers/{book.uuid}.jpg" alt={book.vi_title} />
        </picture>

        <div class="-title">{book.vi_title}</div>
        <div class="-genre">{book.vi_genre}</div>
        <div class="-score">
          <span class="--icon">⭐</span>
          <span class="--text">{book.score}</span>
        </div>
      </a>
    {/each}
  </div>

  <div class="pagi" slot="footer">
    {#if page == 1}
      <button class="page m-button _line" disabled>
        <MIcon class="m-icon" name="chevrons-left" />
      </button>
    {:else}
      <a class="page m-button _line" href={page_url(1, sort)}>
        <MIcon class="m-icon" name="chevrons-left" />
      </a>
    {/if}

    {#each pageList as currPage}
      {#if page == currPage}
        <button class="page m-button _line _primary" disabled>
          <span>{currPage}</span>
        </button>
      {:else}
        <a class="page m-button _line" href={page_url(currPage, sort)}>
          <span>{currPage}</span>
        </a>
      {/if}
    {/each}
    {#if page == pageMax}
      <button class="page m-button _line" disabled>
        <MIcon class="m-icon" name="chevrons-right" />
      </button>
    {:else}
      <a class="page m-button _line" href={page_url(pageMax, sort)}>
        <MIcon class="m-icon" name="chevrons-right" />
      </a>
    {/if}

  </div>

</Layout>

<style lang="scss">
  .list {
    max-width: 100%;
    margin: 0;

    @include grid($gap: 0.5rem, $size: minmax(8.5rem, 1fr));
  }

  .book {
    display: block;
    position: relative;

    margin-bottom: 3rem;

    @include hover {
      .-title {
        @include fgcolor(color(primary, 5));
      }
    }
    // overflow: hidden;
    &::before {
      content: '';
      display: block;
      padding-top: 4/3;
      position: absolute;
      top: 0;
      left: 0;
      z-index: -1;
    }

    .-cover {
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100%;
      z-index: 1;

      // source,
      img {
        @include radius();
        // display: block;
        min-width: 100%;
        min-height: 100%;
      }
    }

    .-title {
      width: 100%;
      position: absolute;
      bottom: -1.75rem;
      font-weight: 500;
      @include fgcolor(color(neutral, 7));
      @include truncate();
      @include font-size(3);
      // line-height: 1rem;
      // @include font-family(narrow);
    }

    .-genre,
    .-score {
      // width: 100%;
      position: absolute;
      // bottom: 0.375rem;
      bottom: -2.75rem;
      // padding: 0.125rem 0.25rem;
      text-transform: uppercase;
      font-weight: 500;
      @include fgcolor(color(neutral, 5));
      // @include bgcolor(rgba(color(neutral, 9), 0.3));
      @include font-size(1);
      @include radius();
    }
    .-genre {
      // left: 0.375rem;
      left: 0;
    }

    .-score {
      // right: 0.375rem;
      right: 0;
      text-transform: uppercase;
      text-align: right;

      > span {
        display: inline-block;
        vertical-align: top;
        font-size: 95%;
        // margin-top: -0.125rem;
      }
    }
  }

  .sort {
    margin-top: 0.25rem;
    margin-bottom: 0.75rem;

    display: flex;
    flex-wrap: wrap;

    line-height: 2rem;
    @include clearfix;
    .label {
      font-weight: 500;
      padding-top: 0.375rem;

      @include font-size(5);
      // @include fgcolor(color(neutral, 6));
    }
    .type {
      margin-left: 0.5rem;
      margin-top: 0.5rem;

      text-transform: uppercase;
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
  }

  $footer-height: 4rem;

  // :global(.footer) {
  //   position: sticky;
  //   bottom: 0;
  //   left: 0;
  //   width: 100%;
  //   transition: transform 0.1s ease-in-out;
  //   @include bgcolor(rgba(color(neutral, 1), 0.8));

  //   :global(.main._clear) & {
  //     transform: translateY($footer-height);
  //     background-color: transparent;
  //     margin-bottom: 0;
  //   }
  // }

  .pagi {
    padding: 0.5rem 0;
    display: flex;
    justify-content: center;
  }

  .page {
    // :global(.main._clear) & {
    //   @include bgcolor(color(neutral, 2));
    // }
    & + & {
      margin-left: 0.5rem;
    }
  }
</style>

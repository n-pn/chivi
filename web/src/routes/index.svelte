<script context="module">
  export async function preload({ query }) {
    const page = query.page || 1

    const res = await this.fetch(`api/books?page=${page}`)
    const data = await res.json()
    return Object.assign(data, { page })
  }
</script>

<script>
  export let items = []
  export let total = 0
  export let page = 1

  $: page_max = total / 20
  $: pages = make_pages(page, page_max)

  function make_pages(page_now, page_max) {
    let page_from = page_now - 2
    if (page_from < 1) page_from = 1
    let page_upto = page_from + 4
    if (page_upto > page_max) {
      page_upto = page_max
      page_from = page_upto - 4
      if (page_from < 1) page_from = 1
    }

    // console.log({ page_from, page_upto })
    let arr = []
    for (let i = page_from; i <= page_upto; i++) arr.push(i)
    return arr
  }

  import MIcon from '$mould/shared/MIcon.svelte'
</script>

<style lang="scss">
  .list {
    max-width: 100%;
    margin: 1rem auto;

    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(9rem, 1fr));
    grid-gap: 0.5rem;
  }

  .book {
    display: block;
    position: relative;

    margin-bottom: 3rem;

    @include hover {
      .book-title {
        @include color(primary, 5);
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
  }

  .book-cover {
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
  .book-title {
    width: 100%;
    position: absolute;
    bottom: -1.75rem;
    font-weight: 600;
    @include color(neutral, 7);
    @include truncate();
    @include font-size(3);
    @include font-family(narrow);
  }

  .book-genre {
    width: 100%;
    position: absolute;
    bottom: -3rem;
    @include color(neutral, 5);
    text-transform: uppercase;
    font-weight: 500;
    @include font-size(1);
  }

  .book-score {
    width: 100%;
    position: absolute;
    bottom: -3rem;
    @include color(neutral, 5);
    text-transform: uppercase;
    font-weight: 500;
    @include font-size(1);
    text-align: right;
    span {
      display: inline-block;
      vertical-align: top;
      font-size: 95%;
      // margin-top: -0.125rem;
    }
  }

  .pagi {
    margin-bottom: 1rem;
    display: flex;
    justify-content: center;
  }

  [m-button] {
    & + & {
      margin-left: 0.5rem;
    }
  }
</style>

<svelte:head>
  <title>Chivi - Chinese to Vietname Machine Translation</title>
</svelte:head>

<div class="list">
  {#each items as book}
    <a class="book" href={book.vi_slug}>
      <picture class="book-cover">
        {#each book.covers as cover}
          <source srcset={cover} />
        {/each}
        <img src="img/nocover.png" alt={book.vi_title} />
      </picture>

      <div class="book-title">{book.vi_title}</div>
      <div class="book-genre">{book.vi_genre}</div>
      <div class="book-score">
        <span>⭐</span>
        {book.score}
      </div>
    </a>
  {/each}
</div>

<footer class="pagi">

  {#if page == 1}
    <button class="page" m-button="line" disabled>
      <MIcon m-icon="chevrons-left" />
    </button>
  {:else}
    <a class="page" m-button="line" href="/?page=1">
      <MIcon m-icon="chevrons-left" />
    </a>
  {/if}

  {#each pages as curr}
    {#if page == curr}
      <button class="page" m-button="line primary" disabled>
        <span>{curr}</span>
      </button>
    {:else}
      <a class="page" m-button="line" href="/?page={curr}">
        <span>{curr}</span>
      </a>
    {/if}
  {/each}
  {#if page == page_max}
    <button class="page" m-button="line" disabled>
      <MIcon m-icon="chevrons-right" />
    </button>
  {:else}
    <a class="page" m-button="line" href="/?page={page_max}">
      <MIcon m-icon="chevrons-right" />
    </a>
  {/if}

</footer>

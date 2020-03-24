<script context="module">
  export async function preload({ query }) {
    const page = query.page || 1

    const res = await this.fetch(`api/books?page=${page}`)
    const { items, total } = await res.json()
    return { items, total }
  }
</script>

<script>
  export let items = []
  export let total = 0
</script>

<style lang="scss">
  .list {
    max-width: 100%;
    margin: 1rem auto;

    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(8rem, 1fr));
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

<div class="pagi">
  <div>Total: {total}</div>
</div>

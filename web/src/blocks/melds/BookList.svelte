<script context="module">
  import BookCover from '$atoms/BookCover.svelte'
  import { anchor_rel } from '$src/stores.js'
  function book_url(book, atab) {
    switch (atab) {
      case 'content':
        return `/~${book.slug}/content?order=desc`
      case 'discuss':
        return `/~${book.slug}/discuss`
      default:
        return `/~${book.slug}`
    }
  }
</script>

<script>
  export let books = []
  export let atab = 'overview'
</script>

<div class="list">
  {#each books as book}
    <a class="book" href={book_url(book, atab)} rel={$anchor_rel}>
      <div class="cover">
        <BookCover ubid={book.ubid} path={book.main_cover} />
      </div>

      <div class="title">{book.vi_title}</div>

      <div class="extra">
        <div class="genre">{book.vi_genres[0]}</div>

        <div class="score">
          <span class="-icon">⭐</span>
          <span class="-text">{book.voters <= 10 ? '--' : book.rating}</span>
        </div>
      </div>
    </a>
  {/each}
</div>

<style lang="scss">
  .list {
    max-width: 100%;
    margin: 0;

    display: grid;
    grid-gap: 0.5rem;

    grid-template-columns: repeat(auto-fill, minmax(6.5rem, 1fr));

    @include screen-min(md) {
      grid-template-columns: repeat(auto-fill, minmax(7.5rem, 1fr));
    }
  }

  .book {
    display: block;

    // margin-bottom: 3.75rem;

    &:hover {
      .title {
        @include fgcolor(primary, 5);
      }
    }
  }

  .cover {
    position: relative;
    height: 0;
    padding-top: (4 / 3) * 100%;
    overflow: hidden;

    @include radius();
    @include bgcolor(primary, 7);

    > :global(*) {
      position: absolute;
      top: 0;
      left: 0;
    }
  }

  .title,
  .extra {
    font-weight: 500;
  }

  .title {
    display: -webkit-box;
    -webkit-box-orient: vertical;
    -webkit-line-clamp: 2;
    overflow: hidden;

    margin-top: 0.375rem;
    line-height: 1.125rem;
    font-size: rem(14px);
    @include fgcolor(neutral, 7);
  }

  .extra {
    display: flex;
    text-transform: uppercase;
    line-height: 1rem;
    margin-top: 0.125rem;
    @include fgcolor(neutral, 5);
  }

  .genre {
    font-size: rem(11px);
    flex: 1;
    @include truncate(null);
  }

  .score {
    @include font-size(1);

    > .-icon {
      display: inline-block;
      font-size: 0.9em;
      margin-top: -0.05rem;
      vertical-align: top;
    }
  }
</style>

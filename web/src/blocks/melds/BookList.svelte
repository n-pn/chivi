<script>
  import BookCover from '$atoms/BookCover.svelte'
  export let books = []
</script>

<div class="list">
  {#each books as book}
    <a class="book" href="/~{book.slug}" rel="prefetch">
      <div class="cover">
        <BookCover ubid={book.ubid} path={book.main_cover} />
      </div>

      <div class="title">{book.vi_title}</div>
      <div class="genre">{book.vi_genres[0]}</div>

      <div class="score">
        <span class="-icon">⭐</span>
        <span class="-text">{book.voters < 10 ? '--' : book.rating}</span>
      </div>
    </a>
  {/each}
</div>

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

    &:hover {
      .title {
        @include fgcolor(primary, 5);
      }
    }

    // overflow: hidden;
    &::before {
      content: '';
      display: block;
      padding-top: #{4 / 3};
      position: absolute;
      top: 0;
      left: 0;
      z-index: -1;
    }
  }

  .genre,
  .score {
    // width: 100%;
    position: absolute;
    // bottom: 0.375rem;
    bottom: -2.75rem;
    // padding: 0.125rem 0.25rem;
    text-transform: uppercase;
    font-weight: 500;
    @include fgcolor(neutral, 5);
    // @include bgcolor(rgba(color(neutral, 9), 0.3));
    @include font-size(1);
    @include radius();
  }
  .genre {
    // left: 0.375rem;
    left: 0;
  }

  .score {
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

  .title {
    width: 100%;
    position: absolute;
    bottom: -1.75rem;
    font-weight: 500;
    @include fgcolor(neutral, 7);
    @include truncate();
    @include font-size(3);
    // line-height: 1rem;
    // @include font-family(narrow);
  }

  .cover {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100%;
    z-index: 1;

    :global(img) {
      min-width: 100%;
      max-height: 13.5rem;
      object-fit: cover;
      @include radius();
    }
  }
</style>

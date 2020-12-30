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

  function stars(rating, voters) {
    if (voters <= 10) return []

    const output = ['⭐']
    if (rating >= 1.25) output.push('⭐')
    if (rating >= 3.75) output.push('⭐')
    if (rating >= 6.25) output.push('⭐')
    if (rating >= 8.75) output.push('⭐')
    return output
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

        <div class="extra">
          <div class="score">
            {#each stars(book.rating, book.voters) as star}
              <span class="-star">{star}</span>
            {/each}
            <span class="-text">{book.voters <= 10 ? '—' : book.rating}</span>
          </div>
        </div>
      </div>

      <div class="title">{book.vi_title}</div>

      <div class="genre">{book.vi_genres[0]}</div>
    </a>
  {/each}
</div>

<style lang="scss">
  .list {
    @include grid($size: minmax(6.5rem, 1fr));
    @include grid-gap(0.5rem);
    @include screen-min(md) {
      grid-template-columns: repeat(auto-fill, minmax(8rem, 1fr));
    }
  }

  .cover {
    position: relative;
    height: 0;
    padding-top: (4 / 3) * 100%;
    overflow: hidden;

    @include radius();
    @include bgcolor(primary, 7);

    > :global(picture) {
      position: absolute;
      top: 0;
      left: 0;
    }
  }

  .extra {
    display: flex;
    position: absolute;
    bottom: 0;
    right: 0;
    width: 100%;
    padding: 0.25rem;
    background: linear-gradient(color(neutral, 1, 0.1), color(neutral, 7, 0.7));
  }

  .score {
    margin-left: auto;
    display: inline-flex;
    line-height: 1.25rem;
    @include props(font-size, 10px, 11px, 12px);

    > .-star {
      @include screen-min(md) {
        margin-left: 1px;
      }
    }
    > .-text {
      margin-left: 0.25rem;
      padding: 0 0.25rem;
      font-weight: 500;
      @include radius;
      @include fgcolor(#fff);
      @include bgcolor(primary, 6, 0.8);
    }
  }

  .title {
    display: -webkit-box;
    -webkit-box-orient: vertical;
    -webkit-line-clamp: 2;
    overflow: hidden;

    margin-top: 0.375rem;
    line-height: 1.125rem;
    font-size: rem(15px);
    font-weight: 500;
    @include fgcolor(neutral, 7);

    .book:hover & {
      @include fgcolor(primary, 5);
    }
  }

  .genre {
    font-weight: 500;
    font-size: rem(11px);
    text-transform: uppercase;
    line-height: 1rem;
    margin-top: 0.125rem;
    @include fgcolor(neutral, 5);
  }
</style>

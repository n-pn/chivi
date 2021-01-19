<script context="module">
  import BookCover from '$atoms/BookCover.svelte'

  function rating_stars(rating, voters) {
    if (voters <= 10) return []

    const output = ['⭐']

    if (rating >= 1.25) output.push('⭐')
    if (rating >= 3.75) output.push('⭐')
    if (rating >= 6.25) output.push('⭐')
    if (rating >= 8.75) output.push('⭐')

    return output
  }

  function book_url(b_slug, nvtab) {
    switch (nvtab) {
      case 'content':
        return `/~${b_slug}/content?order=desc`
      case 'discuss':
        return `/~${b_slug}/discuss`
      default:
        return `/~${b_slug}`
    }
  }
</script>

<script>
  export let nvtab = ''

  export let b_hash = ''
  export let b_slug = ''

  export let btitle = []
  export let genres = []

  export let bcover = 'blank.png'
  export let voters = 0
  export let rating = 0

  $: title = btitle[2] || btitle[1]
  $: genre = genres[0] || 'Loại khác'
  $: href = book_url(b_slug, nvtab)
  $: stars = rating_stars(rating, voters)
</script>

<a class="book" {href}>
  <div class="cover">
    <BookCover {b_hash} cover={bcover} />

    {#if voters >= 10}
      <div class="extra">
        <div class="score">
          {#each stars as star}
            <span class="-star">{star}</span>
          {/each}
          <span class="-text">{rating / 10}</span>
        </div>
      </div>
    {/if}
  </div>

  <div class="title">{title}</div>
  <div class="genre">{genre}</div>
</a>

<style lang="scss">
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

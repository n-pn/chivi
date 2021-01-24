<script context="module">
  import BCover from '$blocks/BCover.svelte'

  function rating_stars(rating, voters) {
    if (voters <= 10) return []

    const output = ['⭐']

    if (rating > 12) output.push('⭐')
    if (rating > 37) output.push('⭐')
    if (rating > 62) output.push('⭐')
    if (rating > 87) output.push('⭐')

    return output
  }

  function book_url(bslug, atab) {
    switch (atab) {
      case 'content':
        return `/~${bslug}/content?order=desc`
      case 'discuss':
        return `/~${bslug}/discuss`
      default:
        return `/~${bslug}`
    }
  }
</script>

<script>
  export let nvinfo = {}
  export let atab = ''

  $: title = nvinfo.btitle[2] || nvinfo.btitle[1]
  $: genre = nvinfo.genres[0] || 'Loại khác'
  $: href = book_url(nvinfo.bslug, atab)
  $: stars = rating_stars(nvinfo.rating, nvinfo.voters)
</script>

<a class="book" {href}>
  <div class="cover">
    <BCover bhash={nvinfo.bhash} bcover={nvinfo.bcover} />

    {#if nvinfo.voters > 10}
      <div class="extra">
        <div class="score">
          {#each stars as star}
            <span class="-star">{star}</span>
          {/each}
          <span class="-text">{nvinfo.rating / 10}</span>
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

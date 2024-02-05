<script lang="ts">
  import BCover from '$gui/atoms/BCover.svelte'
  import { gen_stars } from '$utils/star_utils'

  export let nvinfo: CV.Wninfo
  export let nvtab = ''

  $: stars = gen_stars(nvinfo.rating, nvinfo.voters)
  $: route = nvtab == 'index' ? '' : nvtab
</script>

<a class="book" href="/wn/{nvinfo.id}/{route}">
  <div class="tooltip">{nvinfo.vtitle} - {nvinfo.vauthor}</div>

  <div class="cover">
    <BCover srcset={nvinfo.bcover} />
    {#if nvinfo.voters > 10}
      <div class="extra">
        <div class="score">
          <span class="-star">{stars}</span>
          <span class="-text">{nvinfo.rating}</span>
        </div>
      </div>
    {/if}
  </div>
  <div class="title">{nvinfo.vtitle}</div>
  <div class="genre">{nvinfo.genres[0] || 'Loại khác'}</div>
</a>

<style lang="scss">
  .book:nth-child(25) {
    @include bps(display, none, $tm: block, $ls: none);
  }

  .book {
    position: relative;
  }
  .cover {
    position: relative;
  }

  .tooltip {
    display: none;
    position: absolute;
    top: 0;
    left: 0;
    z-index: 10;
    width: 100%;
    padding: 0.375rem;
    line-height: 1.25em;
    font-family: var(--font-sans);

    color: var(--bg-main);
    background-color: var(--fg-secd);
    opacity: 0.85;

    @include ftsize(xs);
    @include bdradi(0.25rem);

    .book:hover & {
      display: initial;
    }
  }

  .extra {
    display: flex;
    position: absolute;
    bottom: 0;
    right: 0;
    width: 100%;
    padding: 0.25rem;
    background: linear-gradient(color(neutral, 1, 1), color(neutral, 7, 7));
  }

  .score {
    margin-left: auto;
    display: inline-flex;
    line-height: 1.25rem;
    @include bps(font-size, 10px, 11px, 12px);

    > .-text {
      margin-left: 0.25rem;
      padding: 0 0.25rem;
      font-weight: 500;
      color: $color-white;
      @include bdradi;
      @include bgcolor(primary, 6, 5);
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

    @include tm-dark {
      @include fgcolor(neutral, 3);
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

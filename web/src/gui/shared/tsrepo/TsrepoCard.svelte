<script lang="ts">
  import BCover from '$gui/atoms/BCover.svelte'
  import { _pgidx } from '$lib/kit_path'

  export let crepo: CV.Tsrepo

  $: pg_no = crepo.lc_ch_no > 32 ? _pgidx(crepo.lc_ch_no) : 1
  $: query = pg_no > 1 ? `?pg=${pg_no}` : ''
  $: cover = crepo.cover || '//cdn.chivi.app/covers/blank.png'
</script>

<a class="crepo" href="/ts/{crepo.sroot}{query}">
  <div class="cover">
    <BCover srcset={cover} />
    <div class="rdlog">
      Đang đọc: {crepo.lc_ch_no}/{crepo.chmax}
    </div>
  </div>
  <div class="title">{crepo.vname}</div>
</a>

<style lang="scss">
  .crepo:nth-child(25) {
    @include bps(display, none, $tm: block, $ls: none);
  }

  .crepo {
    position: relative;
  }

  .cover {
    position: relative;
  }

  .rdlog {
    @include flex-ca;
    @include fgcolor(secd);
    @include ftsize(xs);
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
  }

  // .tooltip {
  //   display: none;
  //   position: absolute;
  //   top: 0;
  //   left: 0;
  //   z-index: 10;
  //   width: 100%;
  //   padding: 0.375rem;
  //   line-height: 1.25em;
  //   font-family: var(--font-sans);

  //   color: var(--bg-main);
  //   background-color: var(--fg-secd);
  //   opacity: 0.85;

  //   @include ftsize(xs);
  //   @include bdradi(0.25rem);

  //   .crepo:hover & {
  //     display: initial;
  //   }
  // }

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

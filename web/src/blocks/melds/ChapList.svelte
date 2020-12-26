<script context="module">
  import { anchor_rel } from '$src/stores.js'
</script>

<script>
  export let bslug = ''
  export let sname = ''
  export let chaps = []

  function chap_url(chap) {
    return `/~${bslug}/-${chap.uslug}-${sname}-${chap.scid}`
  }
</script>

<ul class="list">
  {#each chaps as chap}
    <li class="item">
      <a href={chap_url(chap)} class="link" rel={$anchor_rel}>
        <span class="label">{chap.label}</span>
        <span class="title">{chap.title}</span>
      </a>
    </li>
  {/each}
</ul>

<style lang="scss">
  $chap-size: 17.5rem;
  // $chap-break: $chap-size * 2 + 0.75 * 5;

  .list {
    @include grid($size: minmax($chap-size, 1fr));
    @include grid-gap($gap: 0 0.75rem);
  }

  .item {
    display: block;

    @include border($sides: bottom);

    &:first-child {
      @include border($sides: top);
    }

    &:nth-child(odd) {
      @include bgcolor(neutral, 1);
    }

    @include screen-min(md) {
      &:nth-child(2) {
        @include border($sides: top);
      }

      &:nth-child(4n),
      &:nth-child(4n + 1) {
        @include bgcolor(neutral, 1);
      }

      &:nth-child(4n + 2),
      &:nth-child(4n + 3) {
        background-color: #fff;
      }
    }
  }

  .link {
    display: block;
    padding: 0.375rem 0.75rem;

    &:visited {
      .title {
        font-style: italic;
        @include fgcolor(neutral, 5);
      }
    }

    &:hover {
      .title {
        @include fgcolor(primary, 5);
      }
    }
  }

  // .label {
  //   padding-top: 0.5rem;
  //   padding-left: 0.5rem;
  // }

  .label {
    display: block;
    padding: 0;
    line-height: 1.25rem;
    @include font-size(1);
    text-transform: uppercase;
    @include fgcolor(neutral, 5);
    @include truncate(100%);
  }

  .title {
    display: block;
    padding: 0;
    line-height: 1.5rem;
    // $font-sizes: screen-vals(rem(15px), rem(16px), rem(17px));
    // @include props(font-size, $font-sizes);

    @include fgcolor(neutral, 8);
    @include truncate(100%);
  }
</style>

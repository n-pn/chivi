<script>
  export let bslug = ''
  export let chaps = []
</script>

<ul class="chap-list">
  {#each chaps as chap}
    <li class="chap-item">
      <a
        class="chap-link"
        href="/{bslug}/{chap.url_slug}"
        rel="nofollow prefetch">
        <span class="volume">{chap.vi_volume}</span>
        <span class="title">{chap.vi_title}</span>
      </a>
    </li>
  {/each}
</ul>

<style type="text/scss">
  .volume {
    padding-top: 0.5rem;
    padding-left: 0.5rem;
  }

  $chap-size: 17.5rem;
  $chap-break: $chap-size * 2 + 0.75 * 5;

  .chap-list {
    @include grid($size: minmax($chap-size, 1fr), $gap: 0 0.75rem);
  }

  .chap-item {
    display: block;

    @include border($pos: bottom);

    &:first-child {
      @include border($pos: top);
    }

    &:nth-child(even) {
      background-color: color(neutral, 1);
    }

    @include screen-min($chap-break) {
      &:nth-child(2) {
        @include border($pos: top);
      }

      &:nth-child(4n),
      &:nth-child(4n + 1) {
        background-color: #fff;
      }

      &:nth-child(4n + 2),
      &:nth-child(4n + 3) {
        background-color: color(neutral, 1);
      }

      // &:nth-child(4n),
      // &:nth-child(4n + 3) {
      //   @include border($pos: right);
      // }

      // &:nth-child(4n + 1),
      // &:nth-child(4n + 2) {
      //   @include border($pos: left);
      // }
    }
  }

  .chap-link {
    display: block;
    padding: 0.375rem 0.75rem;

    &:visited {
      .title {
        font-style: italic;
        @include fgcolor(color(neutral, 5));
      }
    }

    @include hover {
      .title {
        @include fgcolor(color(primary, 5));
      }
    }
  }

  .volume {
    display: block;
    padding: 0;
    line-height: 1.25rem;
    @include font-size(1);
    text-transform: uppercase;
    @include fgcolor(color(neutral, 5));
    @include truncate(100%);
  }

  .title {
    display: block;
    padding: 0;
    line-height: 1.5rem;
    @include fgcolor(color(neutral, 8));
    @include truncate(100%);
  }
</style>

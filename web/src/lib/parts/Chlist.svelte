<script>
  export let bslug = ''
  export let sname = ''

  export let chaps = []
</script>

<div class="list">
  {#each chaps as { chidx, title, label, uslug }}
    <div class="item">
      <a href="/-{bslug}/-{sname}/-{uslug}-{chidx}" class="link" rel="nofollow">
        <div class="text">
          <div class="title">{title}</div>
          <span class="chidx">{chidx}</span>
        </div>
        <div class="meta">
          <span class="label">{label}</span>
        </div>
      </a>
    </div>
  {/each}
</div>

<style lang="scss">
  $chap-size: 17.5rem;
  // $chap-break: $chap-size * 2 + 0.75 * 5;

  .list {
    @include grid($size: minmax(var(--size, 17.5rem), 1fr));
    @include bps(--size, 17.75rem, $md: 16.25rem, $lg: 17.75rem);

    grid-gap: 0 var(--gutter-sm);
  }

  .item {
    display: block;
    @include border(--bd-main, $loc: bottom);
    $bg-dark: color(neutral, 8);

    &:first-child {
      @include border(--bd-main, $loc: top);
    }

    &:nth-child(odd) {
      @include bgcolor(secd);
    }

    @include bp-min(md) {
      &:nth-child(2) {
        @include border(--bd-main, $loc: top);
      }

      &:nth-child(4n),
      &:nth-child(4n + 1) {
        @include bgcolor(secd);
      }

      &:nth-child(4n + 2),
      &:nth-child(4n + 3) {
        @include bgcolor(tert);
      }
    }
  }

  .link {
    display: block;
    padding: 0.375rem 0.5rem;
  }

  .text {
    display: flex;
    line-height: 1.5rem;
  }

  .meta {
    display: flex;
    padding: 0;
    height: 1rem;
    line-height: 1rem;
    margin-top: 0.25rem;
    text-transform: uppercase;
    @include ftsize(xs);
  }

  .title {
    flex: 1;
    @include clamp($width: null);
    @include fgcolor(secd);

    .link:visited & {
      @include fgcolor(tert);
    }

    .link:hover & {
      @include fgcolor(primary, 5);
    }
  }

  .chidx {
    margin-left: 0.125rem;
    user-select: none;
    @include fgcolor(neutral, 5);
    @include ftsize(xs);

    // &:before {
    //   content: '#';
    //   padding-right: rem(1px);
    //   font-size: rem(10px);
    // }

    &:after {
      content: '.';
    }
  }

  .label {
    flex: 1;
    @include fgcolor(neutral, 5);
    @include clamp($width: null);
  }
</style>

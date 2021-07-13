<script>
  export let bslug = ''
  export let sname = ''

  export let chaps = []
</script>

<ul class="list">
  {#each chaps as { chidx, title, label, uslug }}
    <li class="item">
      <a href="/~{bslug}/-{uslug}-{sname}-{chidx}" class="link" rel="nofollow">
        <div class="text">
          <div class="title">{title}</div>
          <span class="chidx">{chidx}</span>
        </div>
        <div class="meta">
          <span class="label">{label}</span>
        </div>
      </a>
    </li>
  {/each}
</ul>

<style lang="scss">
  $chap-size: 17rem;
  // $chap-break: $chap-size * 2 + 0.75 * 5;

  .list {
    @include grid($size: minmax($chap-size, 1fr));
    @include fluid(grid-gap, $sm: 0 0.5rem, $md: 0 0.75rem);
  }

  .item {
    display: block;
    @include border($sides: bottom);
    $bg-dark: color(neutral, 8);

    @include tm-dark {
      border-color: color(neutral, 6) !important;
    }

    &:first-child {
      @include border($sides: top);
    }

    &:nth-child(odd) {
      @include bgcolor(neutral, 1);
      @include tm-dark {
        background: $bg-dark;
      }
    }

    @include bp-min(md) {
      &:nth-child(2) {
        @include border($sides: top);
      }

      &:nth-child(4n),
      &:nth-child(4n + 1) {
        @include bgcolor(neutral, 1);
        @include tm-dark {
          background: $bg-dark;
        }
      }

      &:nth-child(4n + 2),
      &:nth-child(4n + 3) {
        background-color: #fff;
        @include tm-dark {
          @include bgcolor(neutral, 7);
        }
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
    @include fgcolor(neutral, 8);

    @include tm-dark {
      @include fgcolor(neutral, 4);
    }

    .link:visited & {
      @include fgcolor(neutral, 6);

      @include tm-dark {
        @include fgcolor(neutral, 5);
      }
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

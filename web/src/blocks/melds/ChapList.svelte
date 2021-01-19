<script>
  export let b_slug = ''
  export let s_name = ''

  export let chaps = []
</script>

<ul class="list">
  {#each chaps as { ch_idx, title, label, uslug }}
    <li class="item">
      <a
        href="/~{b_slug}/-{uslug}-{s_name}-{ch_idx}"
        class="link"
        rel="nofollow">
        <div class="label">{label}</div>
        <div class="title">{title}</div>
      </a>
    </li>
  {/each}
</ul>

<style lang="scss">
  $chap-size: 17rem;
  // $chap-break: $chap-size * 2 + 0.75 * 5;

  .list {
    @include grid($size: minmax($chap-size, 1fr));
    @include props(grid-gap, $sm: 0 0.5rem, $md: 0 0.75rem);
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
    padding: 0.375rem 0.5rem;

    @include screen-min(md) {
      padding: 0.5rem 0.75rem;
    }

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

  .label {
    padding: 0;
    line-height: 1rem;
    margin-bottom: 0.25rem;
    text-transform: uppercase;

    @include font-size(1);
    @include fgcolor(neutral, 5);
    @include truncate(100%);
  }

  .title {
    line-height: 1.25rem;
    @include fgcolor(neutral, 8);
    @include truncate(100%);
  }
</style>

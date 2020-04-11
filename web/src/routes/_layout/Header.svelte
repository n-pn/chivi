<script>
  import { lookup_pinned, lookup_active } from '$src/stores.js'
</script>

<style lang="scss">
  $outer-height: 3rem;
  $inner-height: 2.25rem;
  $gutter: ($outer-height - $inner-height) / 2;

  .header {
    position: sticky;
    top: 0;
    left: 0;
    width: 100%;
    height: $outer-height;
    z-index: 800;
    @include bgcolor(color(primary, 7));
    @include shadow(2);

    &._tilt {
      @include screen-min(lg) {
        margin-right: 30rem;
      }
    }
  }

  .header-nav {
    margin: 0 auto;
    width: 54rem;
    max-width: 100%;

    display: flex;
    padding: $gutter 0.75rem;
    line-height: $inner-height;
    color: #fff;

    :global(.left) {
      display: flex;
      margin-right: auto;
    }

    :global(.right) {
      display: flex;
      margin-left: auto;
      padding-left: $gutter;
    }
  }

  :global(.header-item) {
    display: inline-flex;
    cursor: pointer;

    text-decoration: none;
    padding: 0 0.5rem;

    height: $inner-height;

    text-transform: uppercase;
    font-weight: 500;

    @include fgcolor(color(neutral, 2));

    @include radius(3);
    @include font-size(2);

    @include bgcolor(color(primary, 6));

    @include hover() {
      @include bgcolor(color(primary, 5));
    }

    & + & {
      margin-left: $gutter;
    }

    &._active {
      @include bgcolor(color(primary, 5));
    }

    &._title {
      max-width: 40vw;
      @include screen-min(sm) {
        max-width: 50vw;
      }
      @include screen-min(md) {
        max-width: 60vw;
      }
    }

    &._index {
      max-width: 20vw;
      @include screen-min(sm) {
        max-width: 40vw;
      }
      @include screen-min(md) {
        max-width: 60vw;
      }
    }

    :global(span) {
      @include truncate(100%);
    }

    :global(img),
    :global(svg) {
      display: inline-block;
      margin: 0.5rem 0;
      width: 1.25rem;
      height: 1.25rem;
    }

    &._logo {
      letter-spacing: 0.1em;
      @include font-size(3);

      > span {
        margin-left: 0.25rem;
      }
    }

    &._input {
      border: none;
      cursor: text;
      @include bgcolor(darken(color(primary, 7), 5%));
    }
  }
</style>

<header class="header" class:_tilt={$lookup_pinned && $lookup_active}>
  <form action="/search" method="get">
    <nav class="header-nav">
      <slot>
        <div class="left">
          <a href="/" class="header-item _logo _active">
            <img src="/logo.svg" alt="logo" />
            <span>Chivi</span>
          </a>

          <input
            type="search"
            name="kw"
            class="header-item _input"
            placeholder="Tìm kiếm"
            on:focus={evt => evt.stopPropagation()} />

        </div>
      </slot>
    </nav>
  </form>
</header>

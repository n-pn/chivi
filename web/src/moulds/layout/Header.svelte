<script>
  let header
  let scroll = 0

  function scrolling(evt) {
    const st = window.pageYOffset || document.documentElement.scrollTop
    if (st > scroll) {
      header.classList.remove('fixed')
    } else {
      header.classList.add('fixed')
    }
    scroll = st <= 0 ? 0 : st
  }
</script>

<style lang="scss">
  $outer-height: 3rem;
  $inner-height: 2.25rem;
  $gutter: ($outer-height - $inner-height) / 2;

  .header {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: $outer-height;
    z-index: 800;
    @include bgcolor(primary, 7);
    @include shadow(2);

    :global(&.fixed) {
      position: fixed;
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

    @include color(neutral, 2);

    @include radius(3);
    @include font-size(2);
    @include truncate(null);
    @include bgcolor(primary, 6);

    @include hover() {
      @include bgcolor(primary, 5);
    }

    & + & {
      margin-left: $gutter;
    }

    &._active {
      @include bgcolor(primary, 5);
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
  }
</style>

<svelte:window on:scroll={scrolling} />

<header class="header" bind:this={header}>
  <nav class="header-nav">
    <slot>
      <div class="left">
        <a href="/" class="header-item _logo _active">
          <img src="/logo.svg" alt="logo" />
          <span>Chivi</span>
        </a>
      </div>
    </slot>
  </nav>
</header>

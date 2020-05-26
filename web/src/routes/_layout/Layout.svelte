<script>
  import MIcon from '$mould/MIcon.svelte'

  export let shiftLeft = false
  export let searchKey = ''

  let scrollDown = false
  let lastScrollTop = 0

  function handleScroll(evt) {
    // Credits: "https://github.com/qeremy/so/blob/master/so.dom.js#L426"
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop

    scrollDown = scrollTop > lastScrollTop
    lastScrollTop = scrollTop <= 0 ? 0 : scrollTop // For Mobile or negative scrolling
  }

  function handleKeypress(evt) {
    if (!evt.altKey) return

    switch (evt.keyCode) {
      case 73:
        _goto('/')
        evt.preventDefault()
        break

      default:
        break
    }
  }
</script>

<svelte:window on:scroll={handleScroll} on:keypress={handleKeypress} />

<main class="main" class:_clear={scrollDown} class:_shift={shiftLeft}>
  <header class="header">
    <nav class="center">
      <div class="header-left">
        <slot name="header-left">
          <a href="/" class="header-item _logo _active">
            <img src="/logo.svg" alt="logo" />
            <span>Chivi</span>
          </a>

        </slot>
      </div>

      <div class="header-right">
        <slot name="header-right">
          <form class="header-item _input" action="/search" method="get">
            <input
              type="search"
              name="kw"
              placeholder="Tìm kiếm"
              value={searchKey} />
            <MIcon class="m-icon _search" name="search" />

          </form>
        </slot>
      </div>
    </nav>

  </header>

  <section class="section" on:click:passive={() => (scrollDown = false)}>
    <div class="center">
      <slot />
    </div>
  </section>

  <footer class="footer">
    <div class="center">
      <slot name="footer" />
    </div>
  </footer>
</main>

<style lang="scss">
  $header-height: 3rem;
  $header-inner-height: 2.25rem;
  $gutter: ($header-height - $header-inner-height) / 2;

  .main {
    position: relative;
    &._shift {
      @include screen-min(lg) {
        margin-right: 30rem;
      }
    }
  }

  $page-width: 52rem;

  .center {
    margin: 0 auto;
    width: $page-width;
    max-width: 100%;
    padding: 0 0.75rem;
  }

  .header {
    position: sticky;
    z-index: 800;

    top: 0;
    left: 0;

    max-width: 100%;
    height: $header-height;

    color: #fff;
    transition: transform 0.1s ease-in-out;

    @include bgcolor(color(primary, 7));
    @include shadow(2);

    .center {
      display: flex;
      padding-top: $gutter;
      padding-bottom: $gutter;
    }

    .main._clear & {
      transform: translateY(-$header-height);
    }
  }

  .header-left {
    display: flex;
    margin-right: auto;
  }

  .header-right {
    display: flex;
    margin-left: auto;
    padding-left: $gutter;
  }

  :global(.header-item) {
    display: inline-flex;

    text-decoration: none;
    padding: 0 0.5rem;

    min-width: $header-inner-height;
    max-width: 80vw;
    height: $header-inner-height;
    line-height: $header-inner-height;

    text-transform: uppercase;
    font-weight: 500;

    @include fgcolor(color(neutral, 2));
    @include bgcolor(color(primary, 6));

    @include radius();
    @include font-size(2);

    @include hover() {
      cursor: pointer;
      @include bgcolor(color(primary, 5));
    }

    & + & {
      margin-left: $gutter;
    }

    &._active {
      @include bgcolor(color(primary, 5));
    }

    &._title {
      max-width: 25vw;
      @include screen-min(sm) {
        max-width: 35vw;
      }
      @include screen-min(md) {
        max-width: 45vw;
      }
    }

    &._index {
      max-width: 15vw;
      @include screen-min(sm) {
        max-width: 20vw;
      }
      @include screen-min(md) {
        max-width: 30vw;
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
      padding: 0;
      position: relative;
      cursor: text;

      > input {
        color: inherit;
        padding: 0 0.5rem;
        display: block;
        font-weight: 500;
        width: 100%;
        border: none;
        outline: none;
        @include radius();
        &::placeholder {
          @include fgcolor(color(neutral, 5));
        }
        @include bgcolor(darken(color(primary, 7), 5%));
      }

      > :global(.m-icon) {
        display: grid;
        padding: 0;
        margin: 0;
        position: absolute;
        right: 0.5rem;
        top: 0.5rem;
        @include fgcolor(color(neutral, 5));
      }
    }
  }
</style>

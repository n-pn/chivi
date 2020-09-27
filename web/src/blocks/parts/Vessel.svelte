<script>
  import { self_uname, self_power } from '$src/stores'
  import SvgIcon from '$atoms/SvgIcon.svelte'

  export let segment = ''
  export let shift = false
  export let clear = false

  async function logout() {
    $self_uname = 'Khách'
    $self_power = -1
    const res = await fetch('_logout')
  }

  let lastScrollTop = 0

  // Credits: "https://github.com/qeremy/so/blob/master/so.dom.js#L426"
  function handleScroll(evt) {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop

    const scrollDown = scrollTop > lastScrollTop
    lastScrollTop = scrollTop <= 0 ? 0 : scrollTop

    clear = scrollDown
  }
</script>

<svelte:window on:scroll={handleScroll} />

<header
  class="header"
  data-page={segment}
  class:_clear={clear}
  class:__shift={shift}>
  <nav class="center -wrap">
    <div class="-left">
      <a href="/" class="header-item _brand">
        <img src="/logo.svg" alt="logo" />
        <span class="header-text _show-md">Chivi</span>
      </a>

      <slot name="header-left" />
    </div>

    <div class="-right">
      <slot name="header-right" />

      <span class="header-item _menu">
        <SvgIcon name="user" />
        <span class="header-text _show-md">
          {#if $self_power > 0}{$self_uname} [{$self_power}]{:else}Khách{/if}
        </span>

        <div class="header-menu">
          {#if $self_power < 0}
            <a href="/auth/login" class="-item">
              <SvgIcon name="log-in" />
              <span>Đăng nhập</span>
            </a>
            <a href="/auth/signup" class="-item">
              <SvgIcon name="user-plus" />
              <span>Đăng ký</span>
            </a>
          {:else}
            <a href="/@{$self_uname}" class="-item">
              <SvgIcon name="layers" />
              <span>Tủ truyện</span>
            </a>
            <a
              href="/auth/logout"
              class="-item"
              on:click|preventDefault={logout}>
              <SvgIcon name="log-out" />
              <span>Đăng xuất</span>
            </a>
          {/if}
        </div>
      </span>
    </div>
  </nav>
</header>

<main class="vessel" class:__clear={clear} class:__shift={shift}>
  <section class="center">
    <slot />
  </section>
</main>

<footer class:__clear={clear}>
  <slot name="footer" />
</footer>

<style lang="scss">
  .__shift {
    @include screen-min(lg) {
      padding-right: 30rem;
    }
  }

  $page-width: 54rem;

  .center {
    width: $page-width;
    max-width: 100%;
    margin: 0 auto;
    padding: 0 0.75rem;
  }

  $header-height: 3rem;
  $header-inner-height: 2.25rem;
  $header-gutter: ($header-height - $header-inner-height) / 2;

  .header {
    display: block;
    position: fixed;
    z-index: 800;

    top: 0;
    left: 0;

    width: 100%;
    height: $header-height;

    color: #fff;
    transition: transform 100ms ease-in-out;
    will-change: transform;

    @include bgcolor(primary, 7);
    @include shadow(2);

    &._clear {
      // position: absolute;
      // top: -$header-height;
      transform: translateY(-100%);
    }

    .-wrap {
      display: flex;
      padding-top: $header-gutter;
      padding-bottom: $header-gutter;
    }

    .-left,
    .-right {
      @include flex($gap: $header-gutter, $child: ':global(*)');
    }

    .-left {
      flex-grow: 1;
    }

    .-right {
      margin-left: auto;
      padding-left: $header-gutter;
    }
  }

  :global(.header-item) {
    cursor: pointer;
    display: inline-flex;
    position: relative;
    outline: none;
    text-decoration: none;
    user-select: none;

    padding: 0 0.5rem;
    height: $header-inner-height;
    line-height: $header-inner-height;

    @include fgcolor(neutral, 2);
    @include bgcolor(primary, 6);

    @include radius();

    @include hover {
      @include bgcolor(primary, 5);
    }

    &._active {
      @include bgcolor(primary, 5);
    }

    &:disabled {
      cursor: text;
      @include fgcolor(neutral, 4);
      @include bgcolor(primary, 6);
    }

    :global(img),
    :global(svg) {
      margin: 0.5rem 0;
      width: 1.25rem;
      height: 1.25rem;

      & + :global(.header-text) {
        margin-left: 0.25rem;
      }
    }
  }

  :global(.header-text) {
    text-transform: uppercase;
    font-weight: 500;

    @include font-size(2);

    &._show-sm {
      display: none;
      @include screen-min(sm) {
        display: inline-block;
      }
    }

    &._show-md {
      display: none;
      @include screen-min(md) {
        display: inline-block;
      }
    }

    ._brand & {
      @include font-size(3);
      letter-spacing: 0.1em;
    }

    &._title {
      max-width: 40vw;
      @include truncate(null);
    }
  }

  :global(.header-field) {
    position: relative;
    padding: 0;
    // flex-grow: 1;

    cursor: text;
    border-radius: $header-inner-height / 2;
    height: $header-inner-height;
    line-height: $header-inner-height;

    > :global(input) {
      color: inherit;
      padding: 0 1rem;
      display: block;
      // font-weight: 500;
      width: 100%;
      border: none;
      outline: none;
      border-radius: $header-inner-height / 2;

      @include bgcolor(darken(color(primary, 7), 5%));

      &::placeholder {
        @include fgcolor(neutral, 5);
      }
    }

    > :global(svg) {
      position: absolute;
      // display: flex;
      padding: 0;
      margin: 0;
      right: 0.875rem;
      top: 0.625rem;
      width: 1.125rem;
      height: 1.125rem;
      @include fgcolor(neutral, 5);
    }
  }

  :global(.header-menu) {
    position: absolute;
    width: 12rem;
    padding: 0.5rem 0;
    top: $header-inner-height;
    right: 0;

    @include bgcolor(#fff);
    @include shadow;
    @include radius;

    display: none;
    :global(.header-item):hover & {
      display: block;
    }

    :global(.-item) {
      display: flex;

      padding: 0 0.25rem;
      // line-height: 2.25rem;
      text-transform: uppercase;
      font-weight: 500;

      @include flex(0);

      @include border($sides: top);
      &:last-child {
        @include border($sides: bottom);
      }

      @include font-size(2);
      @include fgcolor(neutral, 6);

      &:hover {
        @include fgcolor(primary, 6);
        @include bgcolor(neutral, 2);
      }

      :global(svg) {
        margin: 0.5rem;
      }

      :global(._right) {
        margin-left: auto;
      }
    }
  }

  .vessel {
    padding-top: $header-height;
  }

  footer {
    position: fixed;
    width: 100%;
    bottom: 0;

    $bgc-top: rgba(color(neutral, 1), 0.1);
    $bgc-bottom: rgba(color(neutral, 7), 0.7);

    background: linear-gradient($bgc-top, $bgc-bottom);

    &.__clear {
      background: transparent;
      position: static;
    }
  }
</style>

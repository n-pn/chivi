<script>
  import { user } from '$src/stores'
  import MIcon from '$mould/MIcon.svelte'

  export let segment = ''
  export let shift = false
  export let clear = false

  async function logout() {
    $user = { uname: 'Guest', power: -1 }
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

<style lang="scss">
  .vessel {
    position: relative;
    width: 100%;
    height: 100%;

    &._shift {
      @include screen-min(lg) {
        margin-right: 30rem;
      }
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
    position: sticky;
    z-index: 800;

    top: 0;
    left: 0;

    max-width: 100%;
    height: $header-height;

    color: #fff;
    transition: transform 0.1s ease-in-out;

    @include bgcolor(primary, 7);
    @include shadow(2);

    :global(.__clear) & {
      transform: translateY(-$header-height);
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
    display: inline-flex;
    position: relative;

    text-decoration: none;
    padding: 0 0.5rem;

    height: $header-inner-height;
    line-height: $header-inner-height;
    user-select: none;

    @include fgcolor(neutral, 2);
    @include bgcolor(primary, 6);

    @include radius();

    @include hover() {
      cursor: pointer;
      @include bgcolor(primary, 5);
    }

    &._active {
      @include bgcolor(primary, 5);
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

  .header-menu {
    position: absolute;
    display: none;
    width: 12rem;

    .header-item:hover > & {
      display: block;
      top: $header-inner-height;
      right: 0;
      @include bgcolor(#fff);
      @include shadow;
      @include radius;
      padding-bottom: 0.5rem;
    }

    :global(.m-icon) {
      margin: 0;
    }

    .-head {
      padding: 0 0.75rem;
      margin-bottom: 0.5rem;
      line-height: 3rem;
      font-weight: 500;
      @include font-size(4);
      @include fgcolor(neutral, 6);
      @include border($sides: bottom);
      // @include bgcolor(neutral, 2);
      @include radius($sides: top);

      :global(.m-icon) {
        width: 1.75rem;
        height: 1.75rem;
        margin-top: -0.25rem;
        margin-left: -0.25rem;
      }
    }

    .-item {
      display: block;

      padding: 0 0.75rem;
      line-height: 2.25rem;
      // text-transform: uppercase;
      font-weight: 500;
      @include fgcolor(neutral, 6);

      &:hover {
        @include fgcolor(primary, 6);
        @include bgcolor(neutral, 2);
      }

      span {
        margin-left: 0.25rem;
      }
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

    > :global(.m-icon) {
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
</style>

<svelte:window on:scroll={handleScroll} />

<div class="vessel" class:_shift={shift} class:__clear={clear}>
  <header class="header" data-page={segment}>
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
          <MIcon class="m-icon _user" name="user" />
          <span class="header-text _show-md">
            {$user.power < 0 ? 'Khách' : $user.uname}
          </span>

          <div class="header-menu">
            <div class="-head">
              <MIcon class="m-icon _user" name="user" />
              <span class="-uname">{$user.uname}</span>
            </div>

            {#if $user.power < 0}
              <a href="/auth/login" class="-item">
                <MIcon class="m-icon _log-in" name="log-in" />
                <span>Đăng nhập</span>
              </a>
              <a href="/auth/signup" class="-item">
                <MIcon class="m-icon _user-plus" name="user-plus" />
                <span>Đăng ký</span>
              </a>
            {:else}
              <a
                href="/auth/logout"
                class="-item"
                on:click|preventDefault={logout}>
                <MIcon class="m-icon _log-out" name="log-out" />
                <span>Đăng xuất</span>
              </a>
            {/if}
          </div>
        </span>
      </div>
    </nav>
  </header>

  <main>
    <div class="center">
      <slot />
    </div>
  </main>
</div>

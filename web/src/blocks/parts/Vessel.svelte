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
  class="app-header"
  data-page={segment}
  class:_clear={clear}
  class:_shift={shift}>
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

<main class:_shift={shift}>
  <section class="center">
    <slot />
  </section>
</main>

<footer class:_show={!clear} class:_shift={shift}>
  <slot name="footer" />
</footer>

<style lang="scss">
  ._shift {
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

  main {
    padding-top: 3rem;
  }

  footer {
    // transition: all 100ms ease-in-out;
    // will-change: transform;

    &._show {
      position: fixed;
      width: 100%;
      bottom: 0;
      $bgc-top: rgba(color(neutral, 1), 0.1);
      $bgc-bottom: rgba(color(neutral, 7), 0.7);
      background: linear-gradient($bgc-top, $bgc-bottom);
    }
  }
</style>

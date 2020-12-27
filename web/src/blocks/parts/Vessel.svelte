<script context="module">
  import { self_uname, self_power, anchor_rel } from '$src/stores'
  import SvgIcon from '$atoms/SvgIcon.svelte'
</script>

<script>
  export let segment = ''
  export let shift = false

  async function logout() {
    $self_uname = 'Khách'
    $self_power = -1
    await fetch('api/logout')
  }

  let lastScrollTop = 0
  let scroll = 0

  // Credits: "https://github.com/qeremy/so/blob/master/so.dom.js#L426"
  function handle_croll() {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop

    scroll = scrollTop - lastScrollTop
    lastScrollTop = scrollTop <= 0 ? 0 : scrollTop
  }
</script>

<svelte:window on:scroll={handle_croll} />

<header
  class="app-header"
  data-page={segment}
  class:_clear={scroll > 0}
  class:_shift={shift}>
  <nav class="center -wrap">
    <div class="-left">
      <a href="/" class="header-item _brand" rel={$anchor_rel}>
        <img src="/chivi-logo.svg" alt="logo" />
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
            <a href="/@{$self_uname}" class="-item" rel={$anchor_rel}>
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

<footer class:_stick={scroll < 0} class:_shift={shift}>
  <slot name="footer" />
</footer>

<style lang="scss">
  $page-width: 56rem;

  ._shift {
    @include props(padding-right, $lg: 30rem);
  }

  .center {
    width: $page-width;
    max-width: 100%;
    margin: 0 auto;
    padding: 0 0.5rem;
  }

  $footer-height: 3.25rem;

  :global(.vessel) {
    position: relative;
    min-height: calc(100% - #{$footer-height + 3rem});
    margin-bottom: $footer-height;
  }

  footer {
    will-change: transform;
    transition: transform 100ms ease-in-out;

    position: absolute;
    bottom: -$footer-height;
    width: 100%;

    &._stick {
      position: fixed;
      transform: translateY(-$footer-height);
      background: linear-gradient(
        color(neutral, 1, 0.1),
        color(neutral, 7, 0.7)
      );
    }
  }
</style>

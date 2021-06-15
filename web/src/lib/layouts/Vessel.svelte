<script>
  import { u_dname, u_power, l_scroll } from '$src/stores'
  import SIcon from '$lib/blocks/SIcon'

  import Signin from '$lib/widgets/Signin'
  import Appnav from '$lib/widgets/Appnav'
  import Usercp from '$lib/widgets/Usercp'

  export let shift = false
  let active_usercp = false
  let active_appnav = false
</script>

<header class="app-header" class:_shift={shift} class:_clear={$l_scroll > 0}>
  <nav class="center -wrap">
    <div class="-left">
      <button class="header-item" on:click={() => (active_appnav = true)}>
        <SIcon name="menu" />
      </button>

      <a href="/" class="header-item _brand">
        <img src="/chivi-logo.svg" alt="logo" />
        <span class="header-text _show-md">Chivi</span>
      </a>

      <slot name="header-left" />
    </div>

    <div class="-right">
      <slot name="header-right" />

      <button class="header-item" on:click={() => (active_usercp = true)}>
        <SIcon name="user" />
        <span class="header-text _show-md">
          {#if $u_power > 0}{$u_dname} [{$u_power}]{:else}Khách{/if}
        </span>
      </button>
    </div>
  </nav>
</header>

<main class="main" class:_shift={shift}>
  <div class="center _main">
    <slot />
  </div>

  <footer class="footer" class:_shift={shift} class:_stick={$l_scroll < 0}>
    <div class="center">
      <slot name="footer" />
    </div>
  </footer>
</main>

{#if process.browser}
  <Appnav bind:actived={active_appnav} />

  {#if $u_dname == 'Khách'}
    <Signin bind:actived={active_usercp} />
  {:else}
    <Usercp bind:actived={active_usercp} />
  {/if}
{/if}

<style lang="scss">
  $page-width: 54rem;

  .center {
    width: $page-width;
    max-width: 100%;
    margin: 0 auto;
    padding: 0 0.5rem;

    &._main {
      min-height: calc(100vh - 3rem);
    }
  }

  $footer-height: 3.25rem;

  .main {
    flex: 1;
    flex-direction: column;
    position: relative;
    margin-bottom: $footer-height;
  }

  ._shift {
    @include props(padding-right, $lg: 30rem);
  }

  .footer {
    will-change: transform;
    transition: transform 100ms ease-in-out;

    position: absolute;
    // bottom: 0;
    bottom: -$footer-height;
    width: 100%;

    &._stick {
      position: fixed;
      transform: translateY(-$footer-height);

      background: linear-gradient(
        color(neutral, 1, 0.1),
        color(neutral, 7, 0.7)
      );

      @include tm-dark {
        background: linear-gradient(
          color(neutral, 7, 0.1),
          color(neutral, 8, 0.7)
        );
      }
    }
  }

  // ._brand {
  //   @include props(display, none, $md: inline-block);
  // }
</style>

<script>
  import { session } from '$app/stores'
  import { l_scroll } from '$lib/stores'

  import SIcon from '$lib/blocks/SIcon.svelte'

  import Signin from '$lib/widgets/Signin.svelte'
  import Appnav from '$lib/widgets/Appnav.svelte'
  import Usercp from '$lib/widgets/Usercp.svelte'

  export let shift = false
  export let pledge = true

  let active_usercp = false
  let active_appnav = false
</script>

<header class="app-header" class:_shift={shift} class:_clear={$l_scroll > 0}>
  <nav class="center -wrap">
    <div class="-left">
      <button class="header-item" on:click={() => (active_appnav = true)}>
        <img src="/chivi-logo.svg" alt="logo" />
        <span class="header-text _show-md">Chivi</span>
      </button>

      <slot name="header-left" />
    </div>

    <div class="-right">
      <slot name="header-right" />

      <button class="header-item" on:click={() => (active_usercp = true)}>
        <SIcon name="user" />
        <span class="header-text _show-md">
          {#if $session.privi > 0}{$session.uname} [{$session.privi}]{:else}Khách{/if}
        </span>
      </button>
    </div>
  </nav>
</header>

<main class="main" class:_shift={shift}>
  <div class="center _main">
    {#if pledge && $session.privi < 2}
      <div class="pledge">
        Chivi cần thiết sự ủng hộ của các bạn để tiếp tục tồn tại và phát triển.
        Đọc thêm <a href="/notes/donation">tại đây</a>.
      </div>
    {/if}

    <slot />
  </div>

  <footer class="footer" class:_shift={shift} class:_stick={$l_scroll < 0}>
    <div class="center">
      <slot name="footer" />
    </div>
  </footer>
</main>

<Appnav bind:actived={active_appnav} />

{#if $session.uname == 'Khách'}
  <Signin bind:actived={active_usercp} />
{:else}
  <Usercp bind:actived={active_usercp} />
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

  .pledge {
    text-align: center;
    margin: 0.5rem auto;
    // max-width: 50vw;
    font-size: rem(15px);

    --fg: #{color(neutral, 6)};
    --bg: #{color(neutral, 2)};

    padding: 0.25rem;
    @include radius();

    color: var(--fg);
    background: var(--bg);

    @include tm-dark {
      --fg: #{color(neutral, 4)};
      --bg: #{color(neutral, 8)};
    }

    > a {
      color: color(primary, 5);
    }
  }

  // ._brand {
  //   @include props(display, none, $md: inline-block);
  // }
</style>

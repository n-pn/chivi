<script>
  import { session } from '$app/stores'
  import { l_scroll } from '$lib/stores'

  import SIcon from '$atoms/SIcon.svelte'

  import Signin from '$parts/Signin.svelte'
  import Appnav from '$parts/Appnav.svelte'
  import Usercp from '$parts/Usercp.svelte'

  export let shift = false
  export let pledge = true

  let active_usercp = false
  let active_appnav = false
</script>

<header class="app-header" class:_shift={shift} class:_clear={$l_scroll > 0}>
  <nav class="center -wrap">
    <div class="-left">
      <button
        class="header-item _brand"
        on:click={() => (active_appnav = true)}>
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
    padding: 0 var(--gutter);

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
    @include fluid(padding-right, $lg: 30rem);
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

      --bg-start: #{rgba(color(gray, 1), 0.1)};
      --bg-stop: #{rgba(color(gray, 7), 0.7)};
      background: linear-gradient(var(--bg-start), var(--bg-stop));

      @include tm-dark {
        --bg-start: #{rgba(color(gray, 7), 0.1)};
        --bg-stop: #{rgba(color(gray, 8), 0.7)};
      }
    }
  }

  .pledge {
    --fgcolor: var(--color-gray-6);
    --bgcolor: var(--color-gray-2);

    text-align: center;
    margin: 0.5rem auto;
    // max-width: 50vw;
    font-size: rem(15px);

    padding: 0.25rem;

    color: var(--fgcolor);
    background: var(--bgcolor);
    @include bdradi();

    @include tm-dark {
      --fgcolor: var(--color-gray-4);
      --bgcolor: var(--color-gray-8);
    }

    > a {
      color: var(--fg-link);
    }
  }

  // ._brand {
  //   @include fluid(display, none, $md: inline-block);
  // }
</style>

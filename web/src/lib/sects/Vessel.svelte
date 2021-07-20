<script context="module">
  import { onMount } from 'svelte'
  import { session } from '$app/stores'
  import { scroll, toleft } from '$lib/stores'
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'

  import Signin from '$parts/Signin.svelte'
  import Appnav from '$parts/Appnav.svelte'
  import Usercp from '$parts/Usercp.svelte'

  export let pledge = true

  let active_usercp = false
  let active_appnav = false

  let footer
  onMount(() => {
    const observer = new IntersectionObserver(
      ([e]) => e.target.classList.toggle('sticked', e.intersectionRatio < 1),
      { threshold: [1] }
    )
    observer.observe(footer)
  })
</script>

<header class="app-header" class:_shift={$toleft} class:_clear={$scroll > 0}>
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

<main class="main" class:_shift={$toleft}>
  <div class="center _main">
    {#if pledge && $session.privi < 2}
      <div class="pledge">
        Chivi cần thiết sự ủng hộ của các bạn để tiếp tục tồn tại và phát triển.
        Đọc thêm <a href="/notes/donation">tại đây</a>.
      </div>
    {/if}

    <slot />
  </div>

  <footer class="footer" class:_sticky={$scroll < 0} bind:this={footer}>
    <slot name="footer" />
  </footer>
</main>

<Appnav bind:actived={active_appnav} />

{#if $session.uname == 'Khách'}
  <Signin bind:actived={active_usercp} />
{:else}
  <Usercp bind:actived={active_usercp} />
{/if}

<style lang="scss">
  $page-width: 55.5rem;

  .center {
    width: $page-width;
    max-width: 100%;
    margin: 0 auto;
    padding: 0 var(--gutter);
  }

  $footer-height: 3.5rem;

  .main {
    flex: 1;
    flex-direction: column;
    position: relative;

    // &._footer {
    //   margin-bottom: $footer-height;
    // }
  }

  ._shift {
    @include fluid(padding-right, $lg: 30rem);
  }

  .footer {
    will-change: transform;
    transition: transform 100ms ease-in-out;

    position: relative;
    padding: 0.5rem var(--gutter);

    &._sticky {
      position: sticky;
      bottom: -1px;
    }

    &:global(.sticked:not(:empty)) {
      background: linear-gradient(color(neutral, 1, 1), color(neutral, 7, 7));

      @include tm-dark {
        background: linear-gradient(color(neutral, 7, 1), color(neutral, 8, 7));
      }
    }
  }

  .pledge {
    text-align: center;
    margin: 0.5rem auto;
    // max-width: 50vw;
    font-size: rem(15px);

    padding: 0.25rem;

    @include fgcolor(tert);
    @include bgcolor(main);

    @include bdradi();

    > a {
      @include fgcolor(--fg-link);
    }
  }

  // ._brand {
  //   @include fluid(display, none, $md: inline-block);
  // }
</style>

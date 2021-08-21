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
  <nav class="vessel -wrap">
    <div class="-left">
      <button
        class="header-item _brand"
        on:click={() => (active_appnav = true)}>
        <img src="/chivi-logo.svg" alt="logo" />
        <span class="header-text _show-lg">Chivi</span>
      </button>

      <slot name="header-left" />
    </div>

    <div class="-right">
      <slot name="header-right" />

      <button class="header-item" on:click={() => (active_usercp = true)}>
        <SIcon name="user" />
        <span class="header-text _show-md">
          {#if $session.privi >= 0}{$session.uname} [{$session.privi}]{:else}Khách{/if}
        </span>
      </button>
    </div>
  </nav>
</header>

<main class="main" class:_shift={$toleft}>
  <div class="vessel _main">
    {#if $session.privi < 0}
      <div class="pledge">
        Protip: Đăng ký tài khoản <strong>Chivi</strong> ngay hôm nay để mở khoá
        các tính năng!
      </div>
    {:else if pledge && $session.privi < 2}
      <a class="pledge" href="/notes/donation">
        Ủng hộ <strong>Chivi</strong> để nâng cấp quyền hạn!
      </a>
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

  :global(.vessel) {
    width: $page-width;
    max-width: 100%;
    margin: 0 auto;
    padding: 0 var(--gutter);
  }

  $footer-height: 3.5rem;

  .main {
    flex: 1;
    position: relative;

    // &._footer {
    //   margin-bottom: $footer-height;
    // }
  }

  ._shift {
    @include bps(padding-right, $lg: 30rem);
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
    text-align: vessel;
    margin: 0.5rem auto;
    // max-width: 50vw;
    font-size: rem(15px);
    text-align: center;

    padding: 0.5rem var(--gutter-small);

    @include fgcolor(tert);
    @include bgcolor(tert);

    @include bdradi();
  }

  a.pledge {
    display: block;

    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  // .alert {
  //   // font-weight: 500;
  //   margin-top: 0.5rem;
  //   padding: 0.5rem var(--gutter-small);

  //   @include fgcolor(main);
  //   @include bgcolor(tert);
  //   @include bdradi();
  //   @include ftsize(sm);

  //   .h4 {
  //     font-weight: 500;
  //   }
  //   p {
  //     line-height: 1.25em;
  //     margin-top: 0.5rem;
  //   }
  // }
  // ._brand {
  //   @include bps(display, none, $md: inline-block);
  // }
</style>

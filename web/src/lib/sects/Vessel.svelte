<script context="module">
  import { onMount } from 'svelte'
  import { session } from '$app/stores'
  import { scroll, toleft } from '$lib/stores'
</script>

<script>
  export let pledge = true

  let footer
  onMount(() => {
    const observer = new IntersectionObserver(
      ([e]) => e.target.classList.toggle('sticked', e.intersectionRatio < 1),
      { threshold: [1] }
    )
    observer.observe(footer)
  })
</script>

<main class="main" class:_shift={$toleft}>
  <div class="vessel _main">
    {#if $session.privi < 0}
      <div class="pledge">
        Protip: Đăng ký tài khoản <strong>Chivi</strong> ngay hôm nay để mở khoá
        các tính năng!
      </div>
    {:else if pledge && $session.privi < 2}
      <a class="pledge" href="/guide/donation">
        Ủng hộ <strong>Chivi</strong> để nâng cấp quyền hạn!
      </a>
    {/if}

    <slot />
  </div>

  <footer class="footer" class:_show={$scroll < 0} bind:this={footer}>
    <slot name="footer" />
  </footer>
</main>

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
    @include bps(padding-right, $ls: 30rem);
  }

  .footer {
    will-change: transform;
    transition: transform 100ms ease-in-out;

    position: relative;
    padding: 0.5rem var(--gutter);

    position: sticky;
    bottom: -0.1px;
    // transform: translateY(-1px);

    &:global(.sticked) {
      transform: translateY(100%);
    }

    &:global(.sticked)._show {
      // top: -$header-height;
      transform: none;
      // transform: translateY(100%);
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

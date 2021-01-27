<script>
  import { l_scroll } from '$src/stores'

  import Header from '$layout/Header'

  export let shift = false
</script>

<main class="main" class:_shift={shift}>
  <Header>
    <slot name="header-left" slot="header-left" />
    <slot name="header-right" slot="header-right" />
  </Header>

  <div class="center">
    <slot />
  </div>

  <footer class="footer" class:_stick={$l_scroll < 0}>
    <slot name="footer" />
  </footer>
</main>

<style lang="scss">
  $page-width: 54rem;

  :global(.center) {
    width: $page-width;
    max-width: 100%;
    margin: 0 auto;
    padding: 0 0.5rem;
  }

  $footer-height: 3.25rem;

  .main {
    flex: 1;
    flex-direction: column;
    position: relative;
    // margin-bottom: $footer-height;

    &._shift {
      @include props(padding-right, $lg: 30rem);
    }
  }

  .center {
    min-height: calc(100vh - 3rem);
  }

  .footer {
    will-change: transform;
    transition: transform 100ms ease-in-out;

    position: sticky;
    bottom: 0;
    bottom: -$footer-height;
    width: 100%;

    &._stick {
      position: sticky;
      transform: translateY(-$footer-height);

      background: linear-gradient(
        color(neutral, 1, 0.1),
        color(neutral, 7, 0.7)
      );
    }
  }
</style>

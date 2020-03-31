<style lang="scss">
  .wrapper {
    margin: 0 auto;
    width: 54rem;
    max-width: 100%;

    padding: 0;

    @include screen-min(sm) {
      padding: 0 0.75rem;
    }

    @include screen-min(md) {
      padding: 0 1rem;
    }

    @include screen-min(lg) {
      padding: 0 1.25rem;
    }

    @include screen-min(xl) {
      padding: 0 1.5rem;
    }
  }
</style>

<div class="wrapper">
  <slot />
</div>

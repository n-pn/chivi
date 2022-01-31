<section class="main">
  <slot />
</section>

<style lang="scss">
  .main {
    border-radius: 0.5rem;
    @include bgcolor(tert);

    margin-top: 1rem;
    margin: 1rem auto;
    max-width: 48rem;

    padding: var(--gutter);
  }
</style>

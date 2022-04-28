<article class="article">
  <slot />
</article>

<style lang="scss">
  .article {
    @include margin-y(1rem);

    > :global(*) {
      @include padding-x(var(--gutter-large));
    }
  }
</style>

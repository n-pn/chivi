<article class="article">
  <slot />
</article>

<style lang="scss">
  .article {
    margin-top: 1rem;

    > :global(*) {
      max-width: 42rem;
    }
  }
</style>

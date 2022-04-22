<section class="vessel" class:_forum={$$props.vessel == 'forum'}>
  <slot />
</section>

<slot name="footer" />

<style lang="scss">
  ._forum {
    width: 45rem;
  }
</style>

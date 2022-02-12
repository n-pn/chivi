<section>
  <slot />
</section>

<style lang="scss">
  section {
    @include bgcolor(tert);
    // @include fgcolor(main);
    @include shadow(1);

    margin-bottom: 0.75rem;
    padding: 0.75rem var(--gutter);
    @include bps(margin-left, 0, $tm: var(--gutter));
    @include bps(margin-right, 0, $tm: var(--gutter));

    @include bp-min(tm) {
      @include bdradi();
    }
  }
</style>

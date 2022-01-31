<forum-wrap>
  <slot />
</forum-wrap>

<style lang="scss">
  forum-wrap {
    display: block;
    max-width: 45rem;

    padding: 0.75rem var(--gutter);
    margin: 0.75rem auto;

    @include bgcolor(tert);
    @include shadow();
    @include bps(border-radius, 0, $ts: 0.5rem);
    @include tm-dark {
      @include linesd(--bd-soft, $ndef: false, $inset: false);
    }
  }
</style>

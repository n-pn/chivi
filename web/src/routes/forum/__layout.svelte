<div class="forum">
  <slot />
</div>

<style lang="scss">
  .forum {
    padding: 0.75rem var(--gutter);
    margin: 0.75rem 0;

    @include bgcolor(tert);
    @include shadow();
    @include bps(border-radius, 0, $ts: 0.5rem);
    @include tm-dark {
      @include linesd(--bd-soft, $ndef: false, $inset: false);
    }
  }
</style>

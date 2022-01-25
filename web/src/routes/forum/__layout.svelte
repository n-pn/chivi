<script>
  import { Vessel } from '$lib/components'
</script>

<Vessel>
  <forum-wrap>
    <slot />
  </forum-wrap>
</Vessel>

<style lang="scss">
  forum-wrap {
    display: block;
    max-width: 45rem;

    padding: 0.75rem var(--gutter);
    margin: 0.75rem auto;

    @include bgcolor(tert);
    @include shadow();
    @include bps(border-radius, 0, $ts: 0.5rem);
    @include bps(margin-left, calc(var(--gutter) * -1), $ts: auto);
    @include bps(margin-right, calc(var(--gutter) * -1), $ts: auto);
    @include tm-dark {
      @include linesd(--bd-soft, $ndef: false, $inset: false);
    }
  }
</style>

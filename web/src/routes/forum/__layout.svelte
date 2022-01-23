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

    margin: var(--gutter);

    @include bps(margin-left, 0rem, $ts: 1.5rem, $tl: 2rem);
    @include bps(margin-right, 0rem, $ts: 1.5rem, $tl: 2rem);
  }
</style>

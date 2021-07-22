<script>
  export let bcover
</script>

<div>
  {#if bcover}
    <img alt="" src="/covers/{bcover}" loading="lazy" />
  {:else}
    <img alt="" src="/covers/_blank.png" />
  {/if}
</div>

<style lang="scss">
  div {
    position: relative;
    height: 0;
    padding-top: math.div(4, 3) * 100%;
    overflow: hidden;

    @include bdradi();
    @include bgcolor(primary, 8);

    > :global(img) {
      position: absolute;
      top: 0;
      left: 0;
    }
  }

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
</style>

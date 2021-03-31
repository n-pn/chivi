<script>
  export let bhash
  export let bcover
</script>

<div>
  <picture>
    {#if bcover}
      <source srcset="/covers/{bcover}.webp" type="image/webp" />
      <img alt={bhash} src="/covers/{bcover}" loading="lazy" />
    {:else}
      <img alt={bhash} src="/covers/_blank.png" />
    {/if}
  </picture>
</div>

<style lang="scss">
  div {
    position: relative;
    height: 0;
    padding-top: (4 / 3) * 100%;
    overflow: hidden;
    @include radius();
    @include bgcolor(primary, 8);

    > :global(picture) {
      position: absolute;
      top: 0;
      left: 0;
    }
  }

  picture {
    width: 100%;
    height: 100%;
  }

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
</style>

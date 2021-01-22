<script>
  export let b_hash
  export let bcover
</script>

<div>
  <picture>
    {#if bcover}
      <source srcset="/covers/_chivi/{b_hash}.webp" type="image/webp" />
    {/if}
    <img alt={b_hash} src="/covers/{bcover || 'blank.png'}" loading="lazy" />
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

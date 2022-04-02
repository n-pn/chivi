<script lang="ts">
  export let bcover: string | undefined
  export let scover: string | undefined
</script>

<picture>
  {#if scover}<source srcset={scover} />{/if}
  {#if bcover}<source srcset="/covers/{bcover}" />{/if}
  <img src="/imgs/blank.png" alt="" referrerpolicy="no-referrer" />
</picture>

<style lang="scss">
  picture {
    display: block;
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

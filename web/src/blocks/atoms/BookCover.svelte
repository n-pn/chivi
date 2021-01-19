<script>
  export let b_hash = ''
  export let bcover = 'blank.png'
</script>

<picture>
  <source srcset="/covers/_chivi/{b_hash}.webp" type="image/webp" />
  <img alt="" src="/covers/{bcover}" loading="lazy" />
</picture>

<style lang="scss">
  picture {
    width: 100%;
    height: 100%;
  }

  img {
    width: 100%;
    min-height: 100%;
    object-fit: cover;
  }
</style>

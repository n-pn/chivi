<script>
  export let bhash = ''
  export let cover = ''
</script>

<picture>
  <source srcset="/covers/_chivi/{bhash}.webp" type="image/webp" />
  <img alt="" src="/covers/{cover}" loading="lazy" />
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

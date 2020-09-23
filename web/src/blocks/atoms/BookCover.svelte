<script>
  export let ubid = ''
  export let path = ''

  $: image_url = `/images/${ubid}.webp`
  $: cover_url = `/covers/${ubid}.${path}`
</script>

<picture>
  {#if path}
    <source srcset={image_url} type="image/webp" />
    <source srcset={cover_url} type="image/jpeg" />
    <img src={cover_url} alt="" loading="lazy" />
  {:else}<img src="/nocover.png" alt="" loading="lazy" />{/if}
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
    @include radius();
  }
</style>

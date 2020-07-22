<script>
  export let ubid = ''
  export let curl = ''
  export let text = ''

  $: webp_url = `/images/${ubid}.webp`
  $: main_url = `/covers/${ubid}.${curl}`
</script>

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

<picture>
  <source srcset={webp_url} type="image/webp" />
  {#if curl !== ''}
    <source srcset={main_url} type="image/jpeg" />
    <img src={main_url} alt="" loading="lazy" />
  {:else}
    <img src="/nocover.png" alt={text} loading="lazy" />
  {/if}
</picture>

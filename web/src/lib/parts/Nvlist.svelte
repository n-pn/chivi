<script>
  export let books = []
  export let nvtab = 'index'

  import Nvinfo from '$molds/Nvinfo.svelte'
</script>

<div class="list">
  {#each books as nvinfo (nvinfo)}
    <Nvinfo {nvinfo} {nvtab} />
  {/each}
</div>

<style lang="scss">
  .list {
    display: grid;
    grid-gap: 0.5rem;

    grid-template-columns: repeat(3, 1fr);

    @include bp-min(sm) {
      grid-template-columns: repeat(4, 1fr);
    }

    @include bp-min(md) {
      grid-template-columns: repeat(5, 1fr);
    }

    @include bp-min(lg) {
      grid-template-columns: repeat(6, 1fr);
    }
  }
</style>

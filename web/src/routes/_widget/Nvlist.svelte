<script>
  export let books = []
  export let nvtab = 'summary'

  import Nvinfo from './Nvinfo.svelte'
</script>

<div class="list">
  {#each books as nvinfo, idx (nvinfo)}
    <Nvinfo {nvinfo} {nvtab} />
  {/each}
</div>

<style lang="scss">
  .list {
    display: grid;
    grid-gap: 0.5rem;

    grid-template-columns: repeat(3, 1fr);

    @include screen-min(480px) {
      grid-template-columns: repeat(4, 1fr);
    }

    @include screen-min(md) {
      grid-template-columns: repeat(5, 1fr);
    }

    @include screen-min(lg) {
      grid-template-columns: repeat(6, 1fr);
    }
  }
</style>

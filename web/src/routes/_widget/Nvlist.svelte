<script>
  export let books = []
  export let nvtab = 'summary'

  import Nvinfo from './Nvinfo.svelte'
</script>

<div class="list">
  {#each books as nvinfo, idx (nvinfo)}
    <Nvinfo {nvinfo} {nvtab} _last={idx == 24} />
  {/each}
</div>

<style lang="scss">
  .list {
    @include grid($size: minmax(6.5rem, 1fr));
    @include grid-gap(0.5rem);
    @include screen-min(md) {
      grid-template-columns: repeat(auto-fill, minmax(8rem, 1fr));
    }
  }
</style>

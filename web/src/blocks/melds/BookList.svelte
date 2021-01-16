<script>
  export let books = []
  export let atab = 'summary'

  import BookItem from './BookItem.svelte'
</script>

<div class="list">
  {#each books as book}
    <BookItem nvtab={atab} {...book} />
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

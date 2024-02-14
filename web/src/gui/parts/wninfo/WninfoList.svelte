<script lang="ts">
  import WninfoCard from '$gui/parts/wninfo/WninfoCard.svelte'

  export let books: CV.Wninfo[] = []
</script>

<div class="blist">
  {#each books as binfo (binfo)}
    <WninfoCard {binfo} />
  {:else}
    <div class="d-empty">Danh sách trống</div>
  {/each}
</div>

<style lang="scss">
  .blist {
    display: grid;
    grid-gap: 0.5rem;

    grid-template-columns: repeat(3, 1fr);

    @include bp-min(pl) {
      grid-template-columns: repeat(4, 1fr);
    }

    @include bp-min(tm) {
      grid-template-columns: repeat(5, 1fr);
    }

    @include bp-min(ls) {
      grid-template-columns: repeat(6, 1fr);
    }
  }
</style>

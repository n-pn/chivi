<script context="module" lang="ts">
  import CvreplCard from './CvreplCard.svelte'
</script>

<script lang="ts">
  export let cvpost: CV.Cvpost

  export let repls: CV.Cvrepl[]
  export let level = 0
  export let fluid = false
</script>

<div class="repl-list" class:_nest={level > 0}>
  {#each repls as cvrepl}
    <CvreplCard {cvrepl} nest_level={level} />

    {#if cvrepl.repls && cvrepl.repls.length > 0}
      <svelte:self {cvpost} repls={cvrepl.repls} level={level + 1} {fluid} />
    {/if}
  {/each}
</div>

<style lang="scss">
  ._nest {
    padding-left: 0.75rem;
  }
</style>

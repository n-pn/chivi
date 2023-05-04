<script context="module" lang="ts">
  import GdreplCard from './GdreplCard.svelte'
</script>

<script lang="ts">
  export let gdroot = ''

  export let repls: CV.Gdrepl[]

  export let level = 0
  export let fluid = false
</script>

<div class="repl-list" class:_nest={level > 0}>
  {#each repls as repl}
    <GdreplCard {gdroot} bind:repl nest_level={level} />

    {#if repl.repls && repl.repls.length > 0}
      <svelte:self {gdroot} repls={repl.repls} level={level + 1} {fluid} />
    {/if}
  {/each}
</div>

<style lang="scss">
  ._nest {
    padding-left: 0.5rem;
  }
</style>

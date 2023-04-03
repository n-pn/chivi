<script context="module" lang="ts">
  import CvreplCard from './CvreplCard.svelte'
</script>

<script lang="ts">
  export let cvpost: CV.Cvpost

  export let repls: CV.Cvrepl[]
  export let users: Record<number, CV.Viuser>
  export let memos: Record<number, CV.Memoir>

  export let level = 0
  export let fluid = false
</script>

<div class="repl-list" class:_nest={level > 0}>
  {#each repls as repl}
    <CvreplCard
      bind:repl
      bind:memo={memos[repl.id]}
      user={users[repl.user_id]}
      nest_level={level} />

    {#if repl.repls && repl.repls.length > 0}
      <svelte:self
        {cvpost}
        repls={repl.repls}
        {users}
        {memos}
        level={level + 1}
        {fluid} />
    {/if}
  {/each}
</div>

<style lang="scss">
  ._nest {
    padding-left: 0.5rem;
  }
</style>

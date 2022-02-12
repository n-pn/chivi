<script context="module" lang="ts">
  import { page } from '$app/stores'
</script>

<script lang="ts">
  import NvinfoCard from '$gui/sects/Nvinfo/Card.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  export let items = []
  export let pgidx = 0
  export let pgmax = 0

  $: pager = new Pager($page.url)
</script>

<book-list>
  {#each items as nvinfo}
    <NvinfoCard {nvinfo} />
  {/each}
</book-list>

{#if items.length > 0}
  <Mpager {pager} {pgidx} {pgmax} />
{/if}

<style lang="scss">
  book-list {
    display: grid;
    grid-gap: 0.75rem;
    grid-template-columns: repeat(auto-fill, minmax(18rem, 1fr));

    // width: 35rem;
    max-width: 100%;

    padding: 0.75rem 0;
    margin: 0 auto;
  }
</style>

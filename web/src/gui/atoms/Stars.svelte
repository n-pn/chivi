<script>
  export let count = 3
  import Star from './Star.svelte'
</script>

{#each [1, 2, 3, 4, 5] as x}
  <Star active={x <= count} scale={x == count} />
{/each}

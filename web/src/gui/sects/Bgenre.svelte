<script>
  import { bgenres, mgenres } from '$lib/constants'
  import SIcon from '$atoms/SIcon.svelte'

  export let genres = []
  let show_all_genres = false
</script>

<genre-list class="m-chips">
  {#each bgenres as [name, slug]}
    {@const _active = genres.includes(name) || genres.includes(slug)}
    {@const _reveal = show_all_genres || mgenres.includes(name)}

    {#if _active || _reveal}
      <a href="/books/-{slug}" class="m-chip _success" class:_active>{name}</a>
    {/if}
  {/each}

  <button class="m-chip" on:click={() => (show_all_genres = !show_all_genres)}>
    <SIcon name={show_all_genres ? 'chevron-left' : 'chevron-right'} />
  </button>
</genre-list>

<style lang="scss">
</style>

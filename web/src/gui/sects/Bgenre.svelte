<script lang="ts">
  import { bgenres } from '$lib/constants'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let genres = []
  let show_all_genres = false
</script>

<genre-list class="m-chips">
  {#each bgenres as [name, slug, primary_genre]}
    {@const _active = genres.includes(name) || genres.includes(slug)}
    {@const _reveal = show_all_genres || primary_genre}

    {#if _active || _reveal}
      <a href="/wn/~{name}" class="m-chip _success" class:_active>{name}</a>
    {/if}
  {/each}

  <button class="m-chip" on:click={() => (show_all_genres = !show_all_genres)}>
    <SIcon name={show_all_genres ? 'chevron-left' : 'chevron-right'} />
  </button>
</genre-list>

<style lang="scss">
</style>

<script>
  import { bgenres, mgenres } from '$lib/constants'
  import SIcon from '$atoms/SIcon.svelte'

  export let genres = []
  let show_all_genres = false
</script>

<genre-list>
  {#each bgenres as [name, slug]}
    {@const _active = genres.includes(name) || genres.includes(slug)}
    {@const _reveal = show_all_genres || mgenres.includes(name)}

    {#if _active || _reveal}
      <a href="/books/-{slug}" class="m-chip _green" class:_active>{name}</a>
    {/if}
  {/each}

  <button class="m-chip" on:click={() => (show_all_genres = !show_all_genres)}>
    <SIcon name={show_all_genres ? 'chevron-left' : 'chevron-right'} />
  </button>
</genre-list>

<style lang="scss">
  genre-list {
    @include flow();
    margin-right: -0.375rem;
    margin-bottom: -0.375rem;
    @include bps(font-size, rem(12px), rem(13px), rem(14px));
  }

  .m-chip {
    float: left;
  }
</style>

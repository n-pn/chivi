<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let loader: () => Promise<string[]>
  export let vstr = ''
</script>

{#await loader()}
  <SIcon name="loader-2" spin={true} />
{:then list}
  {#each list as tran}
    <span class="txt" class:_same={vstr == tran}>{tran}</span>
  {/each}
{/await}

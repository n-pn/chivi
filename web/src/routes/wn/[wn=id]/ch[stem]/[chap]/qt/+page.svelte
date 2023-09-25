<script lang="ts">
  import type { PageData } from './$types'
  export let data: PageData

  $: ({ cinfo, xargs, vtran } = data)
</script>

{#each vtran.lines as line, l_id}
  <svelte:element
    this={l_id > 0 ? 'p' : 'h1'}
    id="L{l_id}"
    class="cdata"
    data-line={l_id}>
    {line}
    {#if l_id == 0 && cinfo.psize > 1}[{xargs.p_idx}/{cinfo.psize}]{/if}
  </svelte:element>
{/each}

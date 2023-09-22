<script lang="ts">
  import type { PageData } from './$types'
  export let data: PageData

  $: cinfo = data.cinfo
  $: xargs = data.xargs
</script>

{#each data.lines as line, l_id}
  <svelte:element
    this={l_id > 0 ? 'p' : 'h1'}
    id="L{l_id}"
    class="cdata"
    data-line={l_id}>
    {line}
    {#if l_id == 0 && cinfo.psize > 1}[{xargs.cpart}/{cinfo.psize}]{/if}
  </svelte:element>
{/each}

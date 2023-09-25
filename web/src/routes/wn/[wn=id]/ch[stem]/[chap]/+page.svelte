<script lang="ts">
  import { config } from '$lib/stores'
  import { gen_vtran_html } from '$lib/mt_data_2'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ cinfo, xargs, vtran } = data)

  $: rmode = $config.r_mode == 2 ? 2 : 1
</script>

{#each vtran.lines as line, _idx}
  {@const opts = { mode: rmode, cap: true, und: true, _qc: 0 }}
  <svelte:element
    this={_idx > 0 ? 'p' : 'h1'}
    id="L{_idx}"
    class="cdata"
    data-line={_idx}>
    {@html gen_vtran_html(line, opts)}
    {#if _idx == 0 && cinfo.psize > 1}[{xargs.p_idx}/{cinfo.psize}]{/if}
  </svelte:element>
{/each}

<script lang="ts">
  import { page } from '$app/stores'
  import { Pager } from '$lib/pager'

  import Qtpage from '$gui/shared/reader/Qtpage.svelte'
  import type { PageData } from './$types'
  export let data: PageData

  $: ({ rdata, xargs } = data)

  $: label = rdata.p_max > 1 ? `[${rdata.p_idx}/${rdata.p_max}]` : ''

  $: pager = new Pager($page.url, { type: 'qt', mode: 'qt_v1' })
</script>

<Qtpage {pager} {rdata} {xargs} {label} dirty={data.dirty} />

<script lang="ts">
  import { page } from '$app/stores'
  import { Pager } from '$lib/pager'

  import WncritList from '$gui/parts/review/WncritList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ydata, vdata, qdata } = data)
  $: pager = new Pager($page.url, { _s: 'score', og: 'mixed', gt: 1, lt: 5, pg: 1 })
</script>

<WncritList {vdata} {ydata} {qdata} {pager} show_book={false} />

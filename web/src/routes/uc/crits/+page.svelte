<script lang="ts">
  import WncritList from '$gui/parts/review/WncritList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ydata, vdata, qdata, pager } = data)
</script>

<WncritList {vdata} {ydata} {qdata} {pager} show_book={true} />

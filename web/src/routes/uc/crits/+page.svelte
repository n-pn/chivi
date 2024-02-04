<script lang="ts">
  import WncritList from '$gui/parts/review/WncritList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ydata, vdata, qdata } = data)
</script>

<WncritList {vdata} {ydata} {qdata} show_book={true} />

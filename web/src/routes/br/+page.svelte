<script lang="ts">
  import WncritList from '$gui/parts/review/WncritList.svelte'

  import type { PageData } from './$types'
  export let data: PageData
</script>

<WncritList vdata={data.vdata} ydata={data.ydata} show_book={true} />

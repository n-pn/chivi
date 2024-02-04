<script lang="ts">
  import VicritList from '$gui/parts/review/VicritList.svelte'

  import type { PageData } from './$types'
  export let data: PageData
</script>

<VicritList vdata={data.vdata} qdata={data.qdata} show_book={true} />

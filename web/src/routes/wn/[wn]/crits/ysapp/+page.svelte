<script lang="ts">
  import YscritList from '$gui/parts/review/YscritList.svelte'

  import type { PageData } from './$types'
  export let data: PageData
</script>

<YscritList {...data.ydata} qdata={data.qdata} show_book={true} />

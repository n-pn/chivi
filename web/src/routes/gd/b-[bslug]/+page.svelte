<script lang="ts">
  import DtopicList from '$gui/parts/dboard/DtopicList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ dboard, dtlist } = data)
</script>

<DtopicList {dboard} {dtlist} />

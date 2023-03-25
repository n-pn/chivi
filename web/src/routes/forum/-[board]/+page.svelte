<script lang="ts">
  import CvpostList from '$gui/parts/dboard/CvpostList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ dboard, dtlist = [] } = data)
</script>

<CvpostList dboard={data.dboard} dtlist={data.dtlist} />

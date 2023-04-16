<script lang="ts">
  import DtopicList from '$gui/parts/dboard/DtopicList.svelte'
  import type { PageData } from './$types'
  export let data: PageData

  const dboard = { id: -1, bname: 'Đại sảnh', bslug: 'dai-sanh' }
</script>

<svelte:head>
  <title>Diễn đàn - Chivi</title>
</svelte:head>

<DtopicList dtlist={data.dtlist} {dboard} _mode={1} />

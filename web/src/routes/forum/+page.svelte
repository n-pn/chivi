<script lang="ts">
  import CvpostList from '$gui/parts/cvpost/CvpostList.svelte'
  import type { PageData } from './$types'
  export let data: PageData

  const dboard = { id: -1, bname: 'Đại sảnh', bslug: 'dai-sanh' }
</script>

<svelte:head>
  <title>Diễn đàn - Chivi</title>
</svelte:head>

<CvpostList dtlist={data.dtlist} {dboard} _mode={1} />

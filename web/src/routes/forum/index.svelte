<script context="module" lang="ts">
  import { appbar } from '$lib/stores'
  export async function load({ fetch, url }) {
    appbar.set({ left: [['Diễn đàn', 'messages', '/forum']] })

    const pg = url.searchParams.get('pg') || 1
    const tl = url.searchParams.get('tl')

    let api_url = `/api/topics?pg=${pg}&lm=10`
    if (tl) api_url += `&dlabel=${tl}`

    const api_res = await fetch(api_url)
    return await api_res.json()
  }
</script>

<script lang="ts">
  import DtopicList from '$gui/parts/cvpost/DtopicList.svelte'
  export let dtlist: CV.Dtlist
  const dboard = { id: -1, bname: 'Đại sảnh', bslug: 'dai-sanh' }
</script>

<svelte:head>
  <title>Diễn đàn - Chivi</title>
</svelte:head>

<DtopicList {dtlist} {dboard} _mode={1} />

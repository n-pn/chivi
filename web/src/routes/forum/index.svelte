<script context="module" lang="ts">
  import { data as appbar } from '$gui/sects/Appbar.svelte'

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
  import DtopicList from '$gui/parts/dtopic/DtopicList.svelte'

  export let dtlist = { items: [], pgidx: 1, pgmax: 1 }
  const dboard = { id: -1, bname: 'Đại sảnh', bslug: 'dai-sanh' }
</script>

<svelte:head>
  <title>Diễn đàn - Chivi</title>
</svelte:head>

<DtopicList {dtlist} {dboard} _mode={1} />

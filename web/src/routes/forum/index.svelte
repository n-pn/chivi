<script context="module" lang="ts">
  import { appbar } from '$lib/stores'
  export async function load({ fetch, url }) {
    const pg = url.searchParams.get('pg') || 1
    const lb = url.searchParams.get('lb')

    let api_url = `/api/topics?pg=${pg}&lm=10`
    if (lb) api_url += `&labels=${lb}`

    const api_res = await fetch(api_url)
    return await api_res.json()
  }
</script>

<script lang="ts">
  import { Vessel } from '$gui'

  import CvpostList from '$gui/parts/cvpost/CvpostList.svelte'
  export let dtlist: CV.Dtlist
  const dboard = { id: -1, bname: 'Đại sảnh', bslug: 'dai-sanh' }

  $: topbar = {
    lefts: [['Diễn đàn', 'messages', { href: '/forum' }]],
  }
</script>

<svelte:head>
  <title>Diễn đàn - Chivi</title>
</svelte:head>

<Vessel {topbar} vessel="forum">
  <forum-wrap>
    <CvpostList {dtlist} {dboard} _mode={1} />
  </forum-wrap>
</Vessel>

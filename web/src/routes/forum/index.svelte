<script context="module" lang="ts">
  import { topbar } from '$lib/stores'
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
  import CvpostList from '$gui/parts/cvpost/CvpostList.svelte'
  export let dtlist: CV.Dtlist
  const dboard = { id: -1, bname: 'Đại sảnh', bslug: 'dai-sanh' }

  $: $topbar = {
    left: [['Diễn đàn', 'messages', { href: '/forum' }]],
  }
</script>

<svelte:head>
  <title>Diễn đàn - Chivi</title>
</svelte:head>

<CvpostList {dtlist} {dboard} _mode={1} />

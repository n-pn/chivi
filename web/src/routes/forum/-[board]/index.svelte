<script context="module" lang="ts">
  export async function load({ stuff, fetch, url: { searchParams } }) {
    const { dboard } = stuff
    const pg = +searchParams.get('pg') || 1
    const lb = searchParams.get('lb')

    let api_url = `/api/topics?dboard=${dboard.id}&pg=${pg}&lm=10`
    if (lb) api_url += `&labels=${lb}`

    const api_res = await fetch(api_url)
    const payload = await api_res.json()

    payload.props.dboard = dboard
    return payload
  }
</script>

<script lang="ts">
  import { Vessel } from '$gui'
  import CvpostList from '$gui/parts/cvpost/CvpostList.svelte'

  export let dboard: CV.Dboard
  export let dtlist: CV.Dtlist

  $: topbar = {
    lefts: [
      ['Diễn đàn', 'messages', { href: '/forum', show: 'pl' }],
      [dboard.bname, null, { href: `/forum/-${dboard.bslug}`, kind: 'title' }],
    ],
  }
</script>

<svelte:head>
  <title>{dboard.bname} - Diễn đàn - Chivi</title>
</svelte:head>

<Vessel {topbar} vessel="forum">
  <forum-wrap>
    <CvpostList {dboard} {dtlist} />
  </forum-wrap>
</Vessel>

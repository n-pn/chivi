<script context="module" lang="ts">
  import { appbar } from '$lib/stores'

  export async function load({ stuff, fetch, url: { searchParams } }) {
    const { dboard } = stuff
    appbar.set({
      left: [
        ['Diễn đàn', 'messages', '/forum', '_show-lg'],
        [dboard.bname, null, '/forum/-' + dboard.bslug, null, '_title'],
      ],
    })

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
  import CvpostList from '$gui/parts/cvpost/CvpostList.svelte'

  export let dboard: CV.Dboard
  export let dtlist: CV.Dtlist
</script>

<svelte:head>
  <title>{dboard.bname} - Diễn đàn - Chivi</title>
</svelte:head>

<CvpostList {dboard} {dtlist} />

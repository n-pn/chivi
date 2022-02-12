<script context="module" lang="ts">
  import type { Dboard } from '$types/models'

  import { data as appbar } from '$gui/sects/Appbar.svelte'

  export async function load({ stuff, fetch, url: { searchParams } }) {
    const { dboard } = stuff
    appbar.set({
      left: [
        ['Diễn đàn', 'messages', '/forum', '_show-lg'],
        [dboard.bname, null, '/forum/-' + dboard.bslug, null, '_title'],
      ],
    })

    const pg = +searchParams.get('pg') || 1
    const tl = searchParams.get('tl')

    let api_url = `/api/topics?dboard=${dboard.id}&pg=${pg}&lm=10`
    if (tl) api_url += `&dlabel=${tl}`

    const api_res = await fetch(api_url)
    const payload = await api_res.json()

    payload.props.dboard = dboard
    return payload
  }
</script>

<script lang="ts">
  import DtopicList from '$gui/parts/dtopic/DtopicList.svelte'

  export let dboard: Dboard
  export let dtlist = { items: [], pgidx: 1, pgmax: 1 }
</script>

<svelte:head>
  <title>{dboard.bname} - Diễn đàn - Chivi</title>
</svelte:head>

<DtopicList {dboard} {dtlist} />

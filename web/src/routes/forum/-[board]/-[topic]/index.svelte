<script context="module" lang="ts">
  import { appbar } from '$lib/stores'
  export async function load({ stuff, fetch, url }) {
    const { dboard, dtopic } = stuff
    appbar.set({
      left: [
        ['Diễn đàn', 'messages', '/forum', '_show-lg'],
        [dboard.bname, null, '/forum/-' + dboard.bslug, null, '_title'],
      ],
    })

    const pg = url.searchParams.get('pg') || 1

    const api_url = `/api/tposts?dtopic=${dtopic.id}&pg=${pg}&lm=20`
    const api_res = await fetch(api_url)
    const payload = await api_res.json()

    payload.props.dboard = dboard
    payload.props.dtopic = dtopic
    return payload
  }
</script>

<script lang="ts">
  import { DtopicFull, DtpostList } from '$gui'

  export let dboard: CV.Dboard
  export let dtopic: CV.Dtopic
  export let tplist: CV.Tplist
</script>

<svelte:head>
  <title>{dtopic.title} - Diễn đàn - Chivi</title>
</svelte:head>

<DtopicFull {dboard} {dtopic} />

<dtopic-posts>
  <DtpostList {tplist} {dtopic} />
</dtopic-posts>

<style lang="scss">
  dtopic-posts {
    display: block;
    margin-top: 0.75rem;
  }
</style>

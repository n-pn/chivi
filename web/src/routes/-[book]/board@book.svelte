<script context="module" lang="ts">
  export async function load({ stuff, fetch, url }) {
    const { nvinfo } = stuff

    const pg = +url.searchParams.get('pg') || 1
    const lb = url.searchParams.get('lb')

    let api_url = `/api/topics?dboard=${nvinfo.id}&pg=${pg}&lm=10`
    if (lb) api_url += `&labels=${lb}`

    const res = await fetch(api_url)
    return await res.json()
  }
</script>

<script lang="ts">
  import { page } from '$app/stores'

  import CvpostList from '$gui/parts/cvpost/CvpostList.svelte'

  export let nvinfo: CV.Nvinfo = $page.stuff.nvinfo
  export let dtlist: CV.Dtlist = { items: [], pgidx: 1, pgmax: 1 }

  $: dboard = { id: nvinfo.id, bname: nvinfo.vname, bslug: nvinfo.bslug }
</script>

<CvpostList {dboard} {dtlist} />

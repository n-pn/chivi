<script context="module" lang="ts">
  export async function load({ stuff, fetch, url }) {
    const { nvinfo } = stuff

    const pg = +url.searchParams.get('pg') || 1
    const tl = url.searchParams.get('tl')

    let api_url = `/api/topics?dboard=${nvinfo.id}&pg=${pg}&lm=10`
    if (tl) api_url += `&dlabel=${tl}`

    const res = await fetch(api_url)
    return await res.json()
  }
</script>

<script lang="ts">
  import { page } from '$app/stores'

  import DtopicList from '$gui/parts/dtopic/DtopicList.svelte'
  import BookPage from './_layout/BookPage.svelte'

  export let nvinfo: CV.Nvinfo = $page.stuff.nvinfo
  export let dtlist: CV.Dtlist = { items: [], pgidx: 1, pgmax: 1 }

  $: dboard = { id: nvinfo.id, bname: nvinfo.vname, bslug: nvinfo.bslug }
</script>

<BookPage {nvinfo} nvtab="board">
  <DtopicList {dboard} {dtlist} />
</BookPage>

<script context="module">
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

<script>
  import { page } from '$app/stores'

  import DtopicList from '$parts/dtopic/DtopicList.svelte'
  import BookPage from './_layout/BookPage.svelte'

  export let nvinfo = $page.stuff.nvinfo
  export let dtlist = { items: [], pgidx: 1, pgmax: 1 }

  $: dboard = { id: nvinfo.id, bname: nvinfo.vname, bslug: nvinfo.bslug }
</script>

<BookPage {nvinfo} nvtab="board">
  <DtopicList {dboard} {dtlist} />
</BookPage>

<script context="module">
  export async function load({ stuff, fetch, url: { searchParams } }) {
    const { nvinfo } = stuff

    const page = +searchParams.get('page') || 1
    const dlabel = searchParams.get('label')

    let api_url = `/api/topics?dboard=${nvinfo.id}&page=${page}&take=10`
    if (dlabel) api_url += `&dlabel=${dlabel}`

    const res = await fetch(api_url)
    if (!res.ok) return { status: res.status, error: await res.text() }

    return { props: { nvinfo, dtlist: await res.json() } }
  }
</script>

<script>
  import DtopicList from '$parts/Dtopic/List.svelte'
  import BookPage from './_layout/BookPage.svelte'

  export let nvinfo
  export let dtlist = { items: [], pgidx: 1, pgmax: 1 }

  $: dboard = { id: nvinfo.id, bname: nvinfo.vname, bslug: nvinfo.bslug }
</script>

<BookPage {nvinfo} nvtab="board">
  <DtopicList {dboard} {dtlist} />
</BookPage>

<script context="module">
  export async function load({ stuff, fetch, url: { searchParams } }) {
    const { nvinfo } = stuff

    const page = +searchParams.get('page') || 1
    const dlabel = searchParams.get('label')

    const api_url = `/api/topics?dboard=${nvinfo.id}&page=${page}&take=10`
    const res = await fetch(dlabel ? `${api_url}&dlabel=${dlabel}` : api_url)

    if (res.ok) return { props: { nvinfo, bdtlist: await res.json() } }
    return { status: res.status, error: await res.text() }
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

<script context="module">
  import { data as appbar } from '$sects/Appbar.svelte'

  export async function load({ fetch, url: { searchParams } }) {
    const page = +searchParams.get('page') || 1
    const dlabel = searchParams.get('label')

    let api_url = `/api/topics?page=${page}&take=10`
    if (dlabel) api_url += `&dlabel=${dlabel}`

    const res = await fetch(api_url)
    if (!res.ok) return { status: res.status, error: await res.text() }

    appbar.set({
      left: [['Diễn đàn', 'messages', '/forum']],
    })

    return { props: { dtlist: await res.json() } }
  }
</script>

<script>
  import DtopicList from '$parts/Dtopic/List.svelte'
  export let dtlist = { items: [], pgidx: 1, pgmax: 1 }
  const dboard = { id: -1, bname: 'Đại sảnh', bslug: 'dai-sanh' }
</script>

<svelte:head>
  <title>Diễn đàn - Chivi</title>
</svelte:head>

<DtopicList {dtlist} {dboard} _mode={1} />

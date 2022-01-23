<script context="module">
  import { data as appbar } from '$sects/Appbar.svelte'

  export async function load({ stuff, fetch, url: { searchParams } }) {
    const { dboard } = stuff

    const page = +searchParams.get('page') || 1
    const dlabel = searchParams.get('label')

    let api_url = `/api/topics?dboard=${dboard.id}&page=${page}&take=10`
    if (dlabel) api_url += `&dlabel=${dlabel}`

    const res = await fetch(api_url)
    if (!res.ok) return { status: res.status, error: await res.text() }

    appbar.set({
      left: [
        ['Diễn đàn', 'messages', '/forum', '_show-lg'],
        [dboard.bname, null, '/forum/-' + dboard.bslug, null, '_title'],
      ],
    })

    return { props: { dboard, dtlist: await res.json() } }
  }
</script>

<script>
  import DtopicList from '$parts/Dtopic/List.svelte'

  export let dboard
  export let dtlist = { items: [], pgidx: 1, pgmax: 1 }
</script>

<DtopicList {dboard} {dtlist} />

<script context="module">
  import { data as appbar } from '$sects/Appbar.svelte'

  export async function load({ stuff, fetch, url: { searchParams } }) {
    const { dboard, dtopic } = stuff
    const page = +searchParams.get('page') || 1

    const api_url = `/api/tposts?dtopic=${dtopic.id}&page=${page}&take=20`
    const res = await fetch(api_url)

    if (!res.ok) return { status: res.status, error: await res.text() }

    appbar.set({
      left: [
        ['Diễn đàn', 'messages', '/forum', '_show-lg'],
        [dboard.bname, null, '/forum/-' + dboard.bslug, null, '_title'],
      ],
    })

    return { props: { dtopic, dboard, dtlist: await res.json() } }
  }
</script>

<script>
  import { DtopicFull, DtpostList } from '$gui'

  export let dboard
  export let dtopic
  export let dtlist
</script>

<svelte:head>
  <title>{dtopic.title} - Diễn đàn - Chivi</title>
</svelte:head>

<DtopicFull {dboard} {dtopic} />

<dtopic-posts>
  <DtpostList {dtlist} {dtopic} />
</dtopic-posts>

<style lang="scss">
  dtopic-posts {
    display: block;
    margin-top: 0.75rem;
  }
</style>

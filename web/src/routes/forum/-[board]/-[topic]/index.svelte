<script context="module">
  export async function load({ stuff, fetch, url: { searchParams } }) {
    const { dtopic } = stuff
    const page = +searchParams.get('page') || 1

    const api_url = `/api/dtposts/${dtopic.id}&page=${page}&take=24`
    const api_res = await fetch(api_url)

    if (api_res.ok) return { props: { dtopic, ...(await api_res.json()) } }
    return { status: api_res.status, error: await api_res.text() }
  }
</script>

<script>
  export let dtopic
  export let tposts
</script>

{dtopic.title}

{tposts.length}

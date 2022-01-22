<script context="module">
  export async function load({ fetch, params: { board } }) {
    const api_url = `/api/boards/` + board
    const api_res = await fetch(api_url)

    if (api_res.ok) return { stuff: await api_res.json() }
    return { status: api_res.status, error: await api_res.text() }
  }
</script>

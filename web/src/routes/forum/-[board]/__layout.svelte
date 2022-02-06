<script context="module">
  export async function load({ fetch, params: { board } }) {
    const api_url = `/api/boards/` + board
    const api_res = await fetch(api_url)
    const payload = await api_res.json()

    payload.stuff = payload.props
    return payload
  }
</script>

<slot />

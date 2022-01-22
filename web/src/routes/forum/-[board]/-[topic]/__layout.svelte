<script context="module">
  export async function load({ fetch, params: { topic } }) {
    const topic_id = topic.split('/')[0]
    const api_url = `/api/topics/${topic_id}`
    const api_res = await fetch(api_url)

    if (api_res.ok) return { stuff: await api_res.json() }
    return { status: api_res.status, error: await api_res.text() }
  }
</script>

<script context="module">
  import { api_call } from '$api/_api_call'

  export async function load({ page: { params }, fetch }) {
    const [status, nvinfo] = await api_call(fetch, `books/${params.book}`)
    if (status) return { status, error: nvinfo }
    return { context: { nvinfo } }
  }
</script>

<slot />

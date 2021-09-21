<script context="module">
  import { api_call } from '$api/_api_call'

  export async function load({ page: { params }, fetch }) {
    const [status, context] = await api_call(fetch, `books/${params.book}`)
    return status ? { status, error: context } : { context }
  }
</script>

<slot />

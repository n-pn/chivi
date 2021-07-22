<script context="module">
  import { api_call } from '$api/_api_call'

  export async function load({ page: { params }, fetch }) {
    const [status, payload] = await api_call(fetch, `cvbooks/${params.book}`)
    if (status) return { status, error: new Error(payload) }

    return {
      context: { nvinfo: payload },
    }
  }
</script>

<slot />

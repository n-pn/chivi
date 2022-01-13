<script context="module">
  export async function load({ stuff, fetch }) {
    const api_url = `/api/boards/${stuff.nvinfo.id}`
    const api_res = await fetch(api_url)
    if (api_res.ok)
      return { props: stuff, stuff: { dboard: await api_res.json() } }
    return { status: api_res.status, error: await api_res.text() }
  }
</script>

<script>
  import BookPage from '../_layout/BookPage.svelte'

  export let nvinfo
  export let ubmemo
</script>

<BookPage {nvinfo} {ubmemo} nvtab="board">
  <slot />
</BookPage>

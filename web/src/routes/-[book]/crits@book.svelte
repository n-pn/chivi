<script context="module" lang="ts">
  export async function load({ fetch, stuff, url }) {
    url.searchParams.set('book', stuff.nvinfo.id)
    url.searchParams.set('lm', 10)
    const api_url = `/api/yscrits${url.search}`
    console.log({ api_url })

    const api_res = await fetch(api_url)
    return await api_res.json()
  }
</script>

<script lang="ts">
  import YscritList from '$gui/sects/yscrit/YscritList.svelte'
  export let crits: CV.Yscrit[] = []
  export let pgidx = 1
  export let pgmax = 1
</script>

<YscritList {crits} {pgidx} {pgmax} show_book={false} />

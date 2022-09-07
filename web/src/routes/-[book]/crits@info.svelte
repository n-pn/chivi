<script context="module" lang="ts">
  export async function load({ fetch, stuff, url }) {
    const sort = url.searchParams.get('_s') || 'score'

    const api_url = new URL(url)
    api_url.pathname = '/_ys/crits'
    api_url.searchParams.set('book', stuff.nvinfo.id)
    api_url.searchParams.set('take', '10')
    api_url.searchParams.set('sort', sort)

    const api_res = await fetch(api_url.toString())
    const payload = api_res.json()
    return payload
  }
</script>

<script lang="ts">
  import YscritList from '$gui/sects/yscrit/YscritList.svelte'
  export let crits: CV.Yscrit[] = []
  export let pgidx = 1
  export let pgmax = 1
</script>

<YscritList {crits} {pgidx} {pgmax} _sort="score" show_book={false} />

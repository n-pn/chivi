<script context="module" lang="ts">
  export async function load({ fetch, stuff, url }) {
    const _sort = url.searchParams.get('_s') || 'score'

    url.searchParams.set('book', stuff.nvinfo.id)
    url.searchParams.set('lm', 10)
    url.searchParams.set('_s', _sort)
    const api_url = `/api/yscrits${url.search}`

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

<YscritList {crits} {pgidx} {pgmax} _sort="score" show_book={false} />

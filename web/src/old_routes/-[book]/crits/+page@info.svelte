<script context="module" lang="ts">
  throw new Error("@migration task: Check code was safely removed (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292722)");

  // import { get_crits } from '$lib/ys_api'

  // export async function load({ fetch, stuff, url }) {
  //   const sort = url.searchParams.get('sort') || 'score'
  //   const opts = { book: stuff.nvinfo.id, take: 10, sort }
  //   const props = await get_crits(url.searchParams, opts, fetch)

  //   return { props }
  // }
</script>

<script lang="ts">
  throw new Error("@migration task: Add data prop (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292707)");

  import YscritList from '$gui/parts/yousuu/YscritList.svelte'
  export let crits: CV.Yscrit[] = []
  export let pgidx = 1
  export let pgmax = 1
</script>

<YscritList {crits} {pgidx} {pgmax} _sort="score" show_book={false} />

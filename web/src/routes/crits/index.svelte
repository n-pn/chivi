<script context="module" lang="ts">
  export async function load({ fetch, url: { searchParams } }) {
    const api_url = `/api/yscrits?${searchParams.toString()}&lm=10`
    const api_res = await fetch(api_url)
    return await api_res.json()
  }
</script>

<script lang="ts">
  import { topbar } from '$lib/stores'
  import { Crumb } from '$gui'

  import YscritList from '$gui/sects/yscrit/YscritList.svelte'

  export let crits = []
  export let pgidx = 1
  export let pgmax = 1

  $: topbar.set({
    left: [['Đánh giá', 'stars', { href: '/crits' }]],
    right: [['Thư đơn', 'bookmarks', { href: '/lists', show: 'tm' }]],
  })
</script>

<svelte:head>
  <title>Đánh giá - Chivi</title>
</svelte:head>

<Crumb tree={[['Đánh giá', '/crits']]} />

<article class="article">
  <YscritList {crits} {pgidx} {pgmax} _sort="utime" />
</article>

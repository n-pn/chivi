<script context="module" lang="ts">
  export async function load({ fetch, url: { searchParams } }) {
    const api_url = `/api/yscrits?${searchParams.toString()}&lm=10`
    const api_res = await fetch(api_url)

    const topbar = {
      left: [['Đánh giá', 'stars', { href: '/crits' }]],
      right: [['Thư đơn', 'bookmarks', { href: '/lists', show: 'tm' }]],
    }

    const payload = await api_res.json()
    return { ...payload, stuff: { topbar } }
  }
</script>

<script lang="ts">
  import { Crumb } from '$gui'

  import YscritList from '$gui/sects/yscrit/YscritList.svelte'

  export let crits = []
  export let pgidx = 1
  export let pgmax = 1
</script>

<svelte:head>
  <title>Đánh giá - Chivi</title>
</svelte:head>

<Crumb tree={[['Đánh giá', '/crits']]} />

<article class="article">
  <YscritList {crits} {pgidx} {pgmax} _sort="utime" />
</article>

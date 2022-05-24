<script context="module" lang="ts">
  export async function load({ fetch, url: { searchParams } }) {
    const api_url = `/api/yslists?${searchParams.toString()}&lm=10`
    const api_res = await fetch(api_url)
    const payload = await api_res.json()

    const topbar = {
      left: [['Thư đơn', 'bookmarks', { href: '/lists' }]],
      right: [['Đánh giá', 'stars', { href: '/crits', show: 'tm' }]],
    }
    payload.stuff = { topbar }
    return payload
  }
</script>

<script lang="ts">
  import { Crumb } from '$gui'

  import YslistList from '$gui/parts/yslist/YslistList.svelte'

  export let lists = []
  export let pgidx = 1
  export let pgmax = 1
</script>

<svelte:head>
  <title>Thư đơn - Chivi</title>
</svelte:head>

<Crumb tree={[['Thư đơn', '/lists']]} />
<article class="article">
  <YslistList {lists} {pgidx} {pgmax} />
</article>

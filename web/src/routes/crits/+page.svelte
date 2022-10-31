<script context="module" lang="ts">
  import { get_crits } from '$lib/ys_api'

  export async function load({ fetch, url: { searchParams } }) {
    const props = await get_crits(searchParams, { take: 10 }, fetch)

    const topbar = {
      left: [['Đánh giá', 'stars', { href: '/crits' }]],
      right: [['Thư đơn', 'bookmarks', { href: '/lists', show: 'tm' }]],
    }

    return { props, stuff: { topbar } }
  }
</script>

<script lang="ts">
  import YscritList from '$gui/parts/yousuu/YscritList.svelte'
  import { Crumb } from '$gui'

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

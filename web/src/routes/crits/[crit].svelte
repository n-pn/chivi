<script context="module" lang="ts">
  export async function load({ fetch, params: { crit } }) {
    const api_res = await fetch(`/api/yscrits/${crit}`)
    return await api_res.json()
  }
</script>

<script lang="ts">
  import { topbar } from '$lib/stores'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import YscritCard from '$gui/sects/yscrit/YscritCard.svelte'

  export let yscrit: CV.Yscrit

  $: topbar.set({
    left: [
      ['Đánh giá', 'stars', { href: '/crits' }],
      [`[${yscrit.id}]`, null, { href: '.', kind: 'zseed' }],
    ],
  })
</script>

<svelte:head>
  <title>Đánh giá - Chivi</title>
</svelte:head>

<nav class="bread">
  <a class="crumb _link" href=".">
    <SIcon name="home" />
  </a>
  <span class="-sep">/</span>
  <a class="crumb _link" href="/crits">
    <span>Đánh giá</span>
  </a>
  <span class="-sep">/</span>
  <a class="crumb _link" href="/crits?book={yscrit.book.id}">
    <span>{yscrit.book.btitle}</span>
  </a>
</nav>

<article class="article _narrow">
  <YscritCard crit={yscrit} view_all={true} big_text={true} />
</article>

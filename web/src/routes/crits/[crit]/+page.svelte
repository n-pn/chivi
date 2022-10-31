<script context="module" lang="ts">
  export async function load({ fetch, params: { crit } }) {
    const api_res = await fetch(`/_ys/crits/${crit}`)
    const { entry } = await api_res.json()

    const topbar = {
      left: [
        ['Đánh giá', 'stars', { href: '/crits' }],
        [`[${crit}]`, null, { href: '.', kind: 'zseed' }],
      ],
    }

    return { props: { entry }, stuff: { topbar } }
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import YscritCard from '$gui/parts/yousuu/YscritCard.svelte'

  export let entry: CV.Yscrit
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
  <a class="crumb _link" href="/crits?book={entry.book.id}">
    <span>{entry.book.btitle}</span>
  </a>
</nav>

<article class="article _narrow">
  <YscritCard crit={entry} view_all={true} big_text={true} />
</article>

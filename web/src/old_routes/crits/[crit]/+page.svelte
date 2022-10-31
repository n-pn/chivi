<script lang="ts">
  throw new Error("@migration task: Add data prop (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292707)");

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

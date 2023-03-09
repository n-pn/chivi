<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import VicritCard from '$gui/parts/review/VicritCard.svelte'

  import type { PageData } from './$types'
  export let data: PageData
</script>

<nav class="bread">
  <a class="crumb _link" href=".">
    <SIcon name="home" />
  </a>
  <span class="-sep">/</span>
  <a class="crumb _link" href="/ys/crits">
    <span>Đánh giá</span>
  </a>
  <span class="-sep">/</span>
  <a class="crumb _link" href="/ys/crits?book={data.book.id}">
    <span>{data.book.vtitle}</span>
  </a>
</nav>

<article class="article island _narrow">
  <VicritCard {...data} view_all={true} />
</article>

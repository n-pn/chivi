<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import YscritCard from '$gui/parts/yousuu/YscritCard.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ entry: crit, vbook: book } = data)
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
  <a class="crumb _link" href="/ys/crits?book={book.id}">
    <span>{book.btitle}</span>
  </a>
</nav>

<article class="article island _narrow">
  <YscritCard {crit} {book} view_all={true} />
</article>

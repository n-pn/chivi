<script lang="ts">
  import NvcritList from '$gui/parts/review/WncritList.svelte'
  import WnNavMenu from '../WnNavMenu.svelte'

  import type { PageData } from './$types'
  export let data: PageData
</script>

<WnNavMenu tab="crits" />

<article class="article island">
  <NvcritList ys={data.ys} vi={data.vi} _sort="score" show_book={false} />
</article>

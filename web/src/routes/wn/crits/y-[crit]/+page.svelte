<script lang="ts">
  import YscritCard from '$gui/parts/review/YscritCard.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ycrit: crit, ylist: list, yuser: user, vbook: book } = data)
</script>

<article class="article island _narrow">
  <YscritCard {crit} {book} {list} {user} view_all={true} />
</article>

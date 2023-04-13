<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import VicritCard from '$gui/parts/review/VicritCard.svelte'

  import type { PageData } from './$types'
  export let data: PageData
</script>

<article class="article island _narrow">
  <VicritCard {...data} view_all={true} />
</article>

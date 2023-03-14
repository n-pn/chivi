<script lang="ts">
  import WnlistList from '$gui/parts/review/WnlistList.svelte'

  import type { PageData } from './$types'
  export let data: PageData
</script>

<WnlistList vi={data.vi} ys={data.ys} _sort="score" />

<script lang="ts">
  // import { get_user } from '$lib/stores'
  // const _user = get_user()

  import MtPage2 from '$gui/sects/MtPage2.svelte'

  import type { PageData } from './$types'
  export let data: PageData
</script>

<MtPage2 {data} />

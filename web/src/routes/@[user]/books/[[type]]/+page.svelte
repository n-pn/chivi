<script lang="ts">
  import { page } from '$app/stores'
  import { status_types, status_names } from '$lib/constants'

  import WninfoList from '$gui/parts/wninfo/WninfoList.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ books, pgidx, pgmax, uname, bmark } = data)

  $: pager = new Pager($page.url)
</script>

<div class="m-chips">
  {#each status_types as status}
    <a
      href="/@{uname}/books/{status}"
      class="m-chip"
      class:_active={status == bmark}>
      {status_names[status]}
    </a>
  {/each}
</div>

<WninfoList {books} nvtab="" />

<Footer>
  <Mpager {pager} {pgidx} {pgmax} />
</Footer>

<style lang="scss">
  .m-chips {
    @include flex-ca;
    padding: 1rem 0;
  }
</style>

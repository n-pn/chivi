<script lang="ts">
  import { page } from '$app/stores'
  import { status_types, status_names } from '$lib/constants'

  import WninfoList from '$gui/parts/wninfo/WninfoList.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ books, pgidx, pgmax, state } = data)

  $: pager = new Pager($page.url, { st: 'default' })
</script>

<div class="m-chips">
  {#each status_types as status, value}
    <a href={pager.gen_url({ st: status, pg: 1 })} class="m-chip" class:_active={value == state}>
      {status_names[status]}
    </a>
  {/each}
</div>

<WninfoList {books} />

<Footer>
  <Mpager {pager} {pgidx} {pgmax} />
</Footer>

<style lang="scss">
  .m-chips {
    @include flex-ca;
    padding: 1rem 0;
  }
</style>

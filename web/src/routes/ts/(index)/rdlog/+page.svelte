<script lang="ts" context="module">
  const stypes = [
    ['', 'Tất cả'],
    ['wn', 'Truyện chữ'],
    ['up', 'Sưu tầm'],
    ['rm', 'Nguồn nhúng'],
  ]
</script>

<script lang="ts">
  import { page } from '$app/stores'

  import RdchapList from '$gui/parts/rdmemo/RdchapList.svelte'

  import { _pgidx } from '$lib/kit_path'

  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ memos, repos, pgidx, pgmax } = data.table)
  $: pager = new Pager($page.url, { pg: 1, stype: '' })
</script>

<nav class="links">
  <span class="label">Lọc:</span>
  {#each stypes as [filter, label]}
    <a
      class="m-btn _xs _primary"
      class:_fill={data.filter.stype == filter}
      href={pager.gen_url({ pg: 1, stype: filter })}>{label}</a>
  {/each}

  <!-- <div class="right">
    <button
      class="m-btn _xs _primary"
      class:_fill={!data.rdmark}
      on:click={() => (data.rdmark = false)}>Vừa xem</button>

    <button
      class="m-btn _xs _primary"
      class:_fill={data.rdmark}
      on:click={() => (data.rdmark = true)}>Tuần tự</button>
  </div> -->
</nav>

<RdchapList {memos} {repos} empty_class="d-empty" />

<footer>
  <Mpager {pager} {pgidx} {pgmax} />
</footer>

<style lang="scss">
  .links {
    margin: 1rem 0;

    @include flex-ca($gap: 0.5rem);
    // flex-direction: column;
    .m-btn {
      border-radius: 1rem;
      padding: 0 0.5rem;
    }
  }

  footer {
    margin-top: 0.5rem;
  }
</style>

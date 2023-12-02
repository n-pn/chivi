<script lang="ts" context="module">
  const stypes = [
    ['', 'Không phân loại'],
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

  $: props = data.props

  $: pager = new Pager($page.url, { pg: 1, sn: '' })
</script>

<nav class="links">
  <span class="label">Lọc:</span>
  {#each stypes as [filter, label]}
    <a
      class="m-btn _xs _primary"
      class:_fill={data.filter.sname == filter}
      href={pager.gen_url({ pg: 1, sn: filter })}>{label}</a>
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

<RdchapList items={props.items} empty_class="d-empty" />

<footer>
  <Mpager {pager} pgidx={props.pgidx} pgmax={props.pgmax} />
</footer>

<style lang="scss">
  .links {
    margin-bottom: 1rem;

    @include flex-ca($gap: 0.5rem);
    // flex-direction: column;
    .m-btn {
      border-radius: 1rem;
      padding: 0 0.5rem;
    }

    .right {
      margin-left: auto;
    }
  }

  footer {
    margin-top: 0.5rem;
  }
</style>

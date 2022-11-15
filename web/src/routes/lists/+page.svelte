<script lang="ts">
  import { goto } from '$app/navigation'
  import { Crumb, SIcon } from '$gui'
  import YslistList from '$gui/parts/yousuu/YslistList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ lists, pgidx, pgmax } = data)
  let qs = data.params.qs || ''
</script>

<Crumb tree={[['Thư đơn', '/lists']]} />

<article class="article island">
  <form
    class="search-bar"
    method="get"
    action="/lists"
    on:submit|preventDefault={() => goto(`/lists?qs=${qs}`)}>
    <input
      type="search"
      class="m-input _sm"
      bind:value={qs}
      name="qs"
      placeholder="Tìm theo từ khóa" />

    <button type="submit" class="m-btn _primary _fill _sm">
      <SIcon name="search" />
    </button>
  </form>

  <YslistList {lists} {pgidx} {pgmax} />
</article>

<style lang="scss">
  .search-bar {
    display: flex;
    justify-content: center;
    gap: 0.5rem;
    margin-bottom: 0.75rem;
    // margin-bottom: var(--gutter);
  }
</style>

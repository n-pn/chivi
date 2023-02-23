<script lang="ts">
  import { goto } from '$app/navigation'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import YslistList from '$gui/parts/yousuu/YslistList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ lists, users, pgidx, pgmax } = data)
  let qs = data.params.qs || ''
</script>

<article class="article island">
  <form
    class="search-bar"
    method="get"
    action="/ys/lists"
    on:submit|preventDefault={() => goto(`/ys/lists?qs=${qs}`)}>
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

  <YslistList {lists} {users} {pgidx} {pgmax} />
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

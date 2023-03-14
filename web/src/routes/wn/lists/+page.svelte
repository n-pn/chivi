<script lang="ts">
  import { goto } from '$app/navigation'
  import SIcon from '$gui/atoms/SIcon.svelte'

  import WnlistList from '$gui/parts/review/WnlistList.svelte'
  import WnNavMenu from '../WnNavMenu.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  let qs = data.params.qs || ''
</script>

<WnNavMenu tab="lists" />

<article class="article island">
  <form
    class="search-bar"
    method="get"
    action="/wn/lists"
    on:submit|preventDefault={() => goto(`/wn/lists?qs=${qs}`)}>
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

  <WnlistList vi={data.vi} ys={data.ys} _sort="score" />
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

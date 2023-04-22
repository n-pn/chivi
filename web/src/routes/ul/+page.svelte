<script lang="ts">
  import { goto } from '$app/navigation'
  import SIcon from '$gui/atoms/SIcon.svelte'

  import WnlistList from '$gui/parts/review/WnlistList.svelte'
  import WnNavMenu from '../wn/WnNavMenu.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  const do_filter = async () => await goto(`/ul?qs=${data.filter.qs}`)
</script>

<WnNavMenu tab="/ul" />

<article class="article island">
  <header class="head">
    <form
      class="search-bar"
      method="get"
      action="/ul"
      on:submit|preventDefault={do_filter}>
      <input
        type="search"
        class="m-input _sm"
        bind:value={data.filter.qs}
        name="qs"
        placeholder="Tìm theo từ khóa" />

      <button type="submit" class="m-btn _primary _sm">
        <SIcon name="search" />
      </button>
    </form>

    <a class="m-btn _primary _fill _sm" href="/ul/+list">
      <SIcon name="ballpen" />
      <span class="-text">Tạo thư đơn</span>
    </a>
  </header>

  <WnlistList
    vi={data.vi || undefined}
    ys={data.ys || undefined}
    _sort="score" />
</article>

<style lang="scss">
  .head {
    display: flex;

    margin: 0 var(--gutter);

    a {
      margin-left: auto;
    }
    @include border($loc: bottom);
    margin-bottom: 1rem;
  }

  .search-bar {
    display: flex;
    gap: 0.5rem;
    margin-bottom: 0.75rem;
    // margin-bottom: var(--gutter);
  }
</style>

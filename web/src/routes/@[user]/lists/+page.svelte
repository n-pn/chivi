<script lang="ts">
  import { goto } from '$app/navigation'
  import SIcon from '$gui/atoms/SIcon.svelte'

  import WnlistList from '$gui/parts/review/WnlistList.svelte'
  import NavLink from '../NavLink.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ viuser, vi } = data)

  const do_filter = async () => {
    await goto(`/@${viuser.uname}/ul?qs=${data.filter.qs}`)
  }
</script>

<NavLink curr="/ul" />

<article class="article island">
  <header class="head">
    <form
      class="search-bar"
      method="get"
      action="/wn/lists"
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

    <a class="m-btn _primary _fill _sm" href="/wn/lists/+list">
      <SIcon name="ballpen" />
      <span class="-text show-ts">Tạo thư đơn</span>
    </a>
  </header>

  <WnlistList {vi} ys={undefined} _sort="score" />
</article>

<style lang="scss">
  .head {
    display: flex;
    margin: 0 var(--gutter);
    @include border($loc: bottom);

    margin-bottom: 1rem;

    a {
      margin-left: auto;
    }
  }

  .search-bar {
    display: flex;
    gap: 0.5rem;
    margin-bottom: 0.75rem;
    // margin-bottom: var(--gutter);
  }
</style>

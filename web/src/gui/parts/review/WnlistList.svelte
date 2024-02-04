<script context="module">
  const sort_lbls = { score: 'Nổi bật', utime: 'Đổi mới' }
  const type_lbls = { male: 'Nam sinh', female: 'Nữ sinh', both: 'Tất cả' }

  const empty = {
    lists: [],
    users: {},
    pgmax: 0,
    pgidx: 0,
    total: 0,
  }
</script>

<script lang="ts">
  import { page } from '$app/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'

  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import VilistCard from './VilistCard.svelte'
  import YslistCard from './YslistCard.svelte'

  export let ys: CV.YslistList = empty
  export let vi: CV.VilistList = empty
  export let qs = ''

  export let sroot = '/uc/lists'
  export let _sort = 'utime'

  $: pager = new Pager($page.url, { sort: _sort, pg: 1, type: '' })

  $: opts = {
    sort: $page.url.searchParams.get('sort') || _sort,
    type: $page.url.searchParams.get('type') || 'both',
  }

  $: pgidx = vi.pgidx > ys.pgidx ? vi.pgidx : ys.pgidx
  $: pgmax = vi.pgmax > ys.pgmax ? vi.pgmax : ys.pgmax
</script>

<header class="head">
  <form class="search" method="get" action={sroot}>
    <input
      type="search"
      class="m-input _sm"
      bind:value={qs}
      name="qs"
      placeholder="Tìm tên thư đơn theo tiếng Trung hoặc tiếng Việt" />

    <button type="submit">
      <SIcon name="search" />
    </button>
  </form>
</header>

<div class="filter m-flex">
  <div class="m-flex _cy">
    <span class="m-label u-show-pl">Đối tượng:</span>
    <div class="m-filter">
      {#each Object.entries(type_lbls) as [type, label]}
        {@const href = pager.gen_url({ sort: opts.sort, type, pg: 1 })}
        <a {href} class="-child" class:_active={type == opts.type}>
          <span>{label}</span>
        </a>
      {/each}
    </div>
  </div>

  <div class="m-filter">
    {#each Object.entries(sort_lbls) as [sort, name]}
      {@const href = pager.gen_url({ sort, type: 'both', pg: 1 })}
      <a {href} class="-child" class:_active={sort == opts.sort}>
        <span>{name}</span>
      </a>
    {/each}
  </div>
</div>

<div class="lists">
  {#each vi.lists as list}
    <VilistCard {list} />
  {/each}

  {#each ys.lists as list}
    {@const user = ys.users[list.user_id]}
    <YslistCard {list} {user} />
  {/each}

  {#if vi.lists.length + ys.lists.length == 0}
    <div class="d-empty">
      <p class="u-fg-tert"><em>Không có nội dung</em></p>
    </div>
  {/if}

  <Footer>
    <Mpager {pager} {pgidx} {pgmax} />
  </Footer>
</div>

<style lang="scss">
  .head {
    @include flex-ca;
    margin-top: 0.75rem;
    margin-bottom: 0.75rem;
  }

  .search {
    display: flex;
    gap: 0.5rem;
    width: 100%;
    position: relative;

    input {
      display: block;
      width: 100%;
      padding-right: 2rem;
    }
    button {
      position: absolute;
      right: 0;
      top: 0;
      bottom: 0;
      margin-right: 0.5rem;
      // width: 1rem;
      @include fgcolor(tert);
      background-color: transparent;
      &:hover {
        @include fgcolor(primary);
      }
    }

    // margin-bottom: var(--gutter);
  }

  // .filter,
  // .lists {
  //   @include bps(margin-left, 0rem, $tm: 0.75rem, $tl: 1.5rem);
  //   @include bps(margin-right, 0rem, $tm: 0.75rem, $tl: 1.5rem);
  // }

  .filter {
    gap: 0.5rem;
    margin-top: 0.25rem;
    justify-content: space-around;
  }

  .lists {
    padding-bottom: 0.75rem;
  }
</style>

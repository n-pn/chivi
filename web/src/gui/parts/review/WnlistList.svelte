<script context="module">
  const sort_lbls = { score: 'Nổi bật', likes: 'Ưa thích', utime: 'Đổi mới' }
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

  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import VilistCard from './VilistCard.svelte'
  import YslistCard from './YslistCard.svelte'

  export let ys: CV.YslistList = empty
  export let vi: CV.VilistList = empty

  export let _sort = 'utime'

  $: pager = new Pager($page.url, { sort: _sort, pg: 1, type: '' })

  $: opts = {
    sort: $page.url.searchParams.get('sort') || _sort,
    type: $page.url.searchParams.get('type') || 'both',
  }

  $: pgidx = vi.pgidx > ys.pgidx ? vi.pgidx : ys.pgidx
  $: pgmax = vi.pgmax > ys.pgmax ? vi.pgmax : ys.pgmax
</script>

<div class="filter">
  <div class="klass">
    <span class="label">Đối tượng:</span>
    {#each Object.entries(type_lbls) as [type, label]}
      {@const href = pager.gen_url({ sort: opts.sort, type, pg: 1 })}
      <a {href} class="m-chip _sort" class:_active={type == opts.type}>
        <span>{label}</span>
      </a>
    {/each}
  </div>

  <div class="sorts">
    <span class="label">Sắp xếp:</span>
    {#each Object.entries(sort_lbls) as [sort, name]}
      {@const href = pager.gen_url({ sort, type: 'both', pg: 1 })}
      <a {href} class="m-chip _sort" class:_active={sort == opts.sort}>
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
    <div class="empty">
      <p class="u-fg-tert"><em>Không có nội dung</em></p>
    </div>
  {/if}

  <footer class="pagi">
    <Mpager {pager} {pgidx} {pgmax} />
  </footer>
</div>

<style lang="scss">
  .filter,
  .lists {
    @include bps(margin-left, 0rem, $tm: 0.75rem, $tl: 1.5rem);
    @include bps(margin-right, 0rem, $tm: 0.75rem, $tl: 1.5rem);
  }

  .filter {
    display: flex;
    margin-top: 0.25rem;
    @include bps(flex-direction, column, $ts: row);

    .label {
      line-height: 1.75rem;
      @include fgcolor(mute);
    }
  }

  .sorts {
    @include flex-cx($gap: 0.5rem);
    margin-top: 0.5rem;
    @include bp-min(ts) {
      align-items: right;
      margin-top: 0;
      margin-left: auto;
    }
  }

  .empty {
    @include flex-ca;
    height: 30vh;
  }

  .klass {
    @include flex-cx($gap: 0.5rem);
    @include bp-min(ts) {
      align-items: left;
    }
  }
</style>

<script context="module">
  const sort_lbls = { score: 'Nổi bật', likes: 'Ưa thích', utime: 'Đổi mới' }
  const type_lbls = { male: 'Nam tần', female: 'Nữ tần', both: 'Tất cả' }
</script>

<script lang="ts">
  import { page } from '$app/stores'

  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import YslistCard from './YslistCard.svelte'

  export let lists = []
  export let pgidx = 1
  export let pgmax = 1
  export let _sort = 'utime'

  $: pager = new Pager($page.url, { sort: _sort, page: 1, type: 'both' })
  $: opts = {
    sort: $page.url.searchParams.get('sort') || _sort,
    type: $page.url.searchParams.get('type') || 'both',
  }
</script>

<div class="filter">
  <div class="sorts">
    <span class="label">Sắp xếp:</span>
    {#each Object.entries(sort_lbls) as [sort, name]}
      {@const href = pager.gen_url({ sort, page: 1, type: 'both' })}
      <a {href} class="m-chip _sort" class:_active={sort == opts.sort}>
        <span>{name}</span>
      </a>
    {/each}
  </div>

  <div class="type">
    <span class="label">Phân loại:</span>
    {#each Object.entries(type_lbls) as [type, label]}
      {@const href = pager.gen_url({ sort: opts.sort, page: 1, type })}
      <a {href} class="m-chip _sort" class:_active={type == opts.type}>
        <span>{label}</span>
      </a>
    {/each}
  </div>
</div>

<div class="lists">
  {#each lists as list}
    <YslistCard {list} />
  {/each}

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
    @include bp-min(ts) {
      align-items: left;
    }
  }

  .type {
    @include flex-cx($gap: 0.5rem);
    margin-top: 0.5rem;
    @include bp-min(ts) {
      align-items: right;
      margin-top: 0;
      margin-left: auto;
    }
  }
</style>

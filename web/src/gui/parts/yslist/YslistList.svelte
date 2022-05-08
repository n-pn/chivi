<script context="module">
  const sorts = { score: 'Nổi bật', likes: 'Ưa thích', utime: 'Đổi mới' }
  const klass = { male: 'Nam tần', female: 'Nữ tần', both: 'Tất cả' }
</script>

<script lang="ts">
  import { page } from '$app/stores'

  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import YslistCard from '$gui/parts/yslist/YslistCard.svelte'

  export let lists = []
  export let pgidx = 1
  export let pgmax = 1
  export let _sort = 'utime'

  $: pager = new Pager($page.url, { _s: _sort, pg: 1, class: 'both' })
  $: _s = pager.get('_s') || _sort
  $: _c = pager.get('class') || 'both'
</script>

<div class="filter">
  <div class="sorts">
    <span class="label">Sắp xếp:</span>
    {#each Object.entries(sorts) as [sort, name]}
      {@const href = pager.gen_url({ _s: sort, pg: 1, class: 'both' })}
      <a {href} class="m-chip _sort" class:_active={sort == _s}>
        <span>{name}</span>
      </a>
    {/each}
  </div>

  <div class="klass">
    <span class="label">Phân loại:</span>
    {#each Object.entries(klass) as [klass, label]}
      {@const href = pager.gen_url({ _s, pg: 1, class: klass })}
      <a {href} class="m-chip _sort" class:_active={klass == _c}>
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

  .klass {
    @include flex-cx($gap: 0.5rem);
    margin-top: 0.5rem;
    @include bp-min(ts) {
      align-items: right;
      margin-top: 0;
      margin-left: auto;
    }
  }
</style>

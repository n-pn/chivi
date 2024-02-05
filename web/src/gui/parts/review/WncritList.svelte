<script lang="ts" context="module">
  const from_types = { mixed: 'Trộn tất cả', chivi: 'Từ người dùng', ysapp: 'Ưu Thư Võng' }
  const memo_types = { '': 'Tất cả', 'liked': 'Đã thích' }

  const sort_types = { score: 'Nổi bật', utime: 'Gần nhất' }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import YscritCard from './YscritCard.svelte'
  import VicritCard from './VicritCard.svelte'
  import Mpager, { type Pager } from '$gui/molds/Mpager.svelte'

  export let vdata: CV.VicritList = { pgmax: 0 }
  export let ydata: CV.YscritList = { pgmax: 0 }

  export let qdata: Partial<CV.CritFilter> = {
    og: 'mixed',
    by: '',
    gt: 1,
    lt: 5,
    pg: 1,
    _s: 'utime',
    _m: '',
  }
  export let pager: Pager

  export let show_book = true
  export let show_list = true

  export let _mode = 2
</script>

{#if _mode == 2}
  <header class="m-flex _cx _cy">
    <div class="m-chips">
      {#each Object.entries(from_types) as [type, label]}
        <a href={pager.gen_url({ og: type, pg: 1 })} class="m-pill" class:_active={type == qdata.og}
          >{label}</a>
      {/each}
    </div>
    <!-- <div class="m-filter u-right">
      {#each Object.entries(memo_types) as [_m, name]}
        {@const href = pager.gen_url({ _m, pg: 1 })}
        <a {href} class="-child" class:_active={_m == qdata._m}>
          <span>{name}</span>
        </a>
      {/each}
    </div> -->
  </header>
{/if}

{#if _mode > 0}
  <div class="qdata m-flex">
    <div class="m-flex _cy">
      <span class="m-label u-show-pl">Số sao:</span>
      {#each [1, 2, 3, 4, 5] as star}
        {@const _active = star >= qdata.gt && star <= qdata.lt}
        {@const gt = _active || star < qdata.gt ? star : qdata.gt}
        {@const lt = _active || star > qdata.lt ? star : qdata.lt}
        {@const href = pager.gen_url({ ...qdata, gt, lt, pg: 1 })}

        <a {href} class="m-star" class:_active>
          <span>{star}</span>
          <SIcon name="star" iset="icons" />
        </a>
      {/each}
    </div>

    <div class="m-filter">
      {#each Object.entries(sort_types) as [_s, name]}
        {@const href = pager.gen_url({ _s, pg: 1 })}
        <a {href} class="-child" class:_active={_s == qdata._s}>
          <span>{name}</span>
        </a>
      {/each}
    </div>
  </div>
{/if}

{#if qdata.og != 'ysapp'}
  {#each vdata.crits as crit}
    {@const book = vdata.books[crit.wn_id]}

    {#key crit.vc_id}
      <VicritCard {crit} {book} {show_book} {show_list} />
    {/key}
  {:else}
    <div class="d-empty-sm">
      <div>Chưa có đánh giá của người dùng.</div>

      {#if qdata.wn}
        <p>
          <a class="m-btn _success _fill" href="/uc/crits/+crit?wn={qdata.wn}">
            <SIcon name="ballpen" />
            <span class="-text">Thêm đánh giá</span>
          </a>
        </p>
      {/if}
    </div>
  {/each}
{/if}

{#if qdata.og != 'chivi'}
  {#each ydata.crits as crit}
    {@const book = ydata.books[crit.book_id]}
    {@const user = ydata.users[crit.user_id]}
    {@const list = ydata.lists[crit.list_id]}

    {#key crit.id}
      <YscritCard {crit} {user} {book} {list} {show_book} {show_list} />
    {/key}
  {:else}
    <div class="d-empty-sm">
      <p>Chưa có đánh giá từ Ưu Thư Võng</p>
    </div>
  {/each}
{/if}

{#if _mode}
  <footer class="pagi">
    <Mpager
      {pager}
      pgidx={qdata.pg}
      pgmax={vdata.pgmax > ydata.pgmax ? vdata.pgmax : ydata.pgmax} />
  </footer>
{/if}

<style lang="scss">
  header {
    margin-top: 0.75rem;
  }

  .qdata {
    margin: 0.75rem 0;
    justify-content: space-around;
  }

  .m-star {
    display: inline-flex;
    align-items: center;
    @include fgcolor(mute);
    margin-left: 0.5rem;

    &._active {
      color: rgb(247, 186, 42);
      @include fgcolor(secd);
    }

    span {
      margin-right: 0.125rem;
    }
  }

  .pagi {
    margin-top: 1rem;
    margin-bottom: 1rem;
  }
</style>

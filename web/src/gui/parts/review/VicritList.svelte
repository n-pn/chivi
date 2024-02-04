<script lang="ts" context="module">
  const sort_trans = { score: 'Tổng hợp', likes: 'Ưa thích', utime: 'Gần nhất' }
</script>

<script lang="ts">
  import { page } from '$app/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import YscritCard from './YscritCard.svelte'
  import VicritCard from './VicritCard.svelte'

  export let vdata: CV.VicritList

  export let wn_id = 0
  export let qdata = { sort: 'score', smin: 0, smax: 6, pg: 1 }

  export let show_book = true
  export let show_list = true

  $: pager = new Pager($page.url, qdata)
</script>

<div class="qdata">
  <div class="stars">
    <span class="label">Số sao:</span>

    {#each [1, 2, 3, 4, 5] as star}
      {@const _active = star >= qdata.smin && star <= qdata.smax}
      {@const smin = _active || star < qdata.smin ? star : qdata.smin}
      {@const smax = _active || star > qdata.smax ? star : qdata.smax}
      {@const href = pager.gen_url({ ...qdata, smin, smax, pg: 1 })}

      <a {href} class="m-star" class:_active>
        <span>{star}</span>
        <SIcon name="star" iset="icons" />
      </a>
    {/each}
  </div>

  <div class="sorts">
    <span class="label">Sắp xếp:</span>
    {#each Object.entries(sort_trans) as [sort, name]}
      {@const href = pager.gen_url({ sort, pg: 1 })}
      <a {href} class="m-chip _sort" class:_active={sort == qdata.sort}>
        <span>{name}</span>
      </a>
    {/each}
  </div>
</div>

<div class="crits">
  {#each vdata.crits as crit}
    {@const book = vdata.books[crit.wn_id]}

    {#key crit.vc_id}
      <VicritCard {crit} {book} {show_book} {show_list} />
    {/key}
  {:else}
    <div class="d-empty">
      <p class="u-fg-tert fs-i">Chưa có đánh giá của người dùng.</p>

      {#if wn_id}
        <p>
          <a class="m-btn _primary _fill _lg" href="/br/+crit?wn=${wn_id}">
            <SIcon name="ballpen" />
            <span class="-text">Thêm đánh giá</span>
          </a>
        </p>
      {/if}
    </div>
  {/each}
</div>

<footer class="pagi">
  <Mpager {pager} pgidx={vdata.pgidx} pgmax={vdata.pgmax} />
</footer>

<style lang="scss">
  .crits,
  .qdata {
    @include bps(margin-left, 0rem, $tm: 0.75rem, $tl: 1.5rem);
    @include bps(margin-right, 0rem, $tm: 0.75rem, $tl: 1.5rem);
  }

  .qdata {
    display: flex;
    margin-top: 0.75rem;

    @include bps(flex-direction, column, $ts: row);
  }

  .label {
    line-height: 1.75rem;
    @include fgcolor(mute);
    font-size: rem(15px);
  }

  .stars {
    @include flex-cx;
    @include bp-min(ts) {
      align-items: left;
    }
  }

  .sorts {
    @include flex-cx($gap: 0.5rem);
    margin-top: 0.25rem;
    @include bp-min(ts) {
      align-items: right;
      // margin-top: 0;
      margin-left: auto;
    }
  }

  .m-star {
    display: inline-flex;
    align-items: center;
    @include fgcolor(mute);
    margin-left: 0.75rem;

    &._active {
      color: rgb(247, 186, 42);
      @include fgcolor(secd);
    }

    span {
      margin-right: 0.125rem;
    }
  }

  .pagi {
    padding-bottom: 1rem;
  }
</style>

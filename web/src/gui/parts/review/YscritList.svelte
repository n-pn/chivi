<script lang="ts">
  import { page } from '$app/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import YscritCard from './YscritCard.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  const sort_trans = { score: 'Tổng hợp', likes: 'Ưa thích', utime: 'Gần nhất' }

  export let crits: CV.Yscrit[] = []
  export let books: Record<number, CV.Crbook> = {}
  export let users: Record<number, CV.Ysuser> = {}
  export let lists: Record<number, CV.Yslist> = {}

  export let pgidx = 1
  export let pgmax = 1

  export let qdata = { sort: 'score', smin: 0, smax: 6, pg: 1 }

  export let show_book = true
  export let show_list = true

  $: pager = new Pager($page.url, qdata)
</script>

<div class="qdata m-flex _cx">
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

  <div class="sorts u-right">
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
  {#each crits as crit}
    {@const view_all = crit.vhtml.length < 600}
    {@const book = books[crit.book_id]}
    {@const user = users[crit.user_id]}
    {@const list = lists[crit.list_id]}

    {#key crit.id}
      <YscritCard {crit} {user} {book} {list} {show_book} {show_list} {view_all} />
    {/key}
  {/each}

  <footer class="pagi">
    <Mpager {pager} {pgidx} {pgmax} />
  </footer>
</div>

<style lang="scss">
  .qdata {
    margin-top: 0.75rem;
    @include bps(flex-direction, column, $ts: row);
  }

  .sorts {
    @include flex-cx($gap: 0.5rem);
    @include bp-min(ts) {
      align-items: left;
    }
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
    padding-bottom: 0.5rem;
  }
</style>

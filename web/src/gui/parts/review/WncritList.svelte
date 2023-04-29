<script lang="ts" context="module">
  const sort_trans = { score: 'Tổng hợp', likes: 'Ưa thích', utime: 'Gần nhất' }

  const empty_crits = {
    crits: [],
    books: {},
    users: {},
    lists: {},
    memos: {},
    pgmax: 0,
    pgidx: 0,
    total: 0,
  }

  const origs = [
    ['', 'Tất cả', 'Hiển thị tất cả đánh giá'],
    ['vi', 'Chivi', 'Đánh giá do người dùng Chivi viết'],
    ['ys', 'Yousuu', 'Đánh giá sưu tầm từ yousuu.com'],
    ['me', 'Của bạn', 'Đánh giá truyện của riêng bạn'],
  ]
</script>

<script lang="ts">
  import { page } from '$app/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import YscritCard from './YscritCard.svelte'
  import VicritCard from './VicritCard.svelte'

  export let ys: CV.YscritList = empty_crits
  export let vi: CV.VicritList = empty_crits

  export let _sort = 'score'
  export let bslug = ''

  export let show_book = true
  export let show_list = true

  $: pager = new Pager($page.url, { sort: _sort, smin: 1, smax: 5, pg: 1 })

  $: opts = {
    from: $page.url.searchParams.get('from') || '',
    sort: _sort,
    smin: +$page.url.searchParams.get('smin') || 1,
    smax: +$page.url.searchParams.get('smax') || 5,
  }

  $: pgidx = vi.pgidx > ys.pgidx ? vi.pgidx : ys.pgidx
  $: pgmax = vi.pgmax > ys.pgmax ? vi.pgmax : ys.pgmax

  $: no_crit = vi.crits.length + ys.crits.length == 0
</script>

<header class="select">
  <span class="label">Xuất xứ:</span>

  {#each origs as [from, name, dtip]}
    {@const page = { from, sort: _sort, smin: 1, smax: 5, pg: 1 }}
    {@const href = pager.gen_url(page)}
    <a
      {href}
      class="m-chip _sort"
      class:_active={from == opts.from}
      data-tip={dtip}>
      <span>{name}</span>
    </a>
  {/each}

  {#if bslug}
    <nav class="right">
      <a class="m-btn _primary _fill _sm" href="/wn/{bslug}/uc/+crit#cform">
        <SIcon name="ballpen" />
        <span class="show-pl">Viết đánh giá</span>
      </a>
    </nav>
  {/if}
</header>

<div class="filter">
  <div class="stars">
    <span class="label">Số sao:</span>

    {#each [1, 2, 3, 4, 5] as star}
      {@const _active = star >= opts.smin && star <= opts.smax}
      {@const smin = _active || star < opts.smin ? star : opts.smin}
      {@const smax = _active || star > opts.smax ? star : opts.smax}
      {@const href = pager.gen_url({ sort: opts.sort, smin, smax, pg: 1 })}

      <a {href} class="m-star" class:_active>
        <span>{star}</span>
        <SIcon name="star" iset="sprite" />
      </a>
    {/each}
  </div>

  <div class="sorts">
    <span class="label">Sắp xếp:</span>
    {#each Object.entries(sort_trans) as [sort, name]}
      {@const href = pager.gen_url({ sort, pg: 1 })}
      <a {href} class="m-chip _sort" class:_active={sort == opts.sort}>
        <span>{name}</span>
      </a>
    {/each}
  </div>
</div>

<div class="crits">
  {#each vi.crits as crit}
    {@const book = vi.books[crit.book_id]}
    {@const user = vi.users[crit.user_id]}
    {@const list = vi.lists[crit.list_id]}
    {@const memo = vi.memos[crit.id]}

    {#key crit.id}
      <VicritCard {crit} {book} {user} {memo} {list} {show_book} {show_list} />
    {/key}
  {/each}

  {#each ys.crits as crit}
    {@const book = ys.books[crit.book_id]}
    {@const user = ys.users[crit.user_id]}
    {@const list = ys.lists[crit.list_id]}

    {#key crit.id}
      <YscritCard {crit} {user} {book} {list} {show_book} {show_list} />
    {/key}
  {/each}

  {#if bslug && no_crit}
    <div class="empty">
      <p class="fg-tert fs-i">Chưa có đánh giá.</p>
      <p>
        <a class="m-btn _primary _fill _lg" href="/wn/{bslug}/uc/+crit#cform">
          <SIcon name="ballpen" />
          <span class="-text">Thêm đánh giá</span>
        </a>
      </p>
    </div>
  {/if}
</div>

<footer class="pagi">
  <Mpager {pager} {pgidx} {pgmax} />
</footer>

<style lang="scss">
  .select {
    @include flex-ca();
    gap: 0.5rem;

    @include border($loc: bottom);
    // margin-top: 0.25rem;
    padding-bottom: 0.75rem;

    .right {
      margin-left: auto;
    }
  }

  .crits,
  .filter {
    @include bps(margin-left, 0rem, $tm: 0.75rem, $tl: 1.5rem);
    @include bps(margin-right, 0rem, $tm: 0.75rem, $tl: 1.5rem);
  }

  .filter {
    display: flex;
    margin-top: 0.5rem;

    @include bps(flex-direction, column, $ts: row);
  }

  .label {
    line-height: 1.75rem;
    @include fgcolor(mute);
    font-size: rem(15px);
  }

  .crits {
    min-height: 10rem;
  }

  .empty {
    @include flex-ca;
    flex-direction: column;
    gap: 0.5rem;
    height: 40vh;
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
</style>

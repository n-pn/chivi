<script context="module">
  import { mark_types, mark_names } from '$utils/constants'

  export async function preload({ params, query }) {
    const uname = params.user
    const bmark = query.bmark || 'reading'
    const page = query.page || '1'

    const url = `/api/user-books/${uname}/?bmark=${bmark}&page=${page}`
    const res = await this.fetch(url)

    if (res.ok) {
      const { books, total } = await res.json()
      return { uname, bmark, books, total, page }
    } else {
      const msg = await res.text()
      this.error(res.status, msg)
    }
  }
</script>

<script>
  import SvgIcon from '$atoms/SvgIcon.svelte'
  import Vessel from '$parts/Vessel'
  import BookList from '$melds/BookList.svelte'

  export let uname = ''
  export let bmark = 'reading'

  export let books = []
  export let total = 0

  export let page = ''

  $: pmax = Math.floor((total - 1) / 24) + 1
  $: if (pmax < 1) pmax = 1
</script>

<Vessel>
  <span slot="header-left" class="header-item _active">
    <SvgIcon name="layers" />
    <span class="header-text">Tủ truyện của @{uname}</span>
  </span>

  <div class="tabs">
    {#each mark_types as type}
      <a
        href="/@{uname}?bmark={type}"
        class="tab"
        class:_active={type == bmark}>{mark_names[type]}</a>
    {/each}
  </div>

  {#if books.length == 0}
    <div class="empty">Danh sách trống</div>
  {:else}
    <BookList {books} atab="content" />

    <div class="pagi">
      <a
        href="/@{uname}?bmark={bmark}&page={+page - 1}"
        class="page m-button _line"
        class:_disable={page == 1}>
        <SvgIcon name="chevron-left" />
        <span>Trước</span>
      </a>

      <div class="page m-button _line _primary _disable">
        <span>{page}</span>
      </div>

      <a
        href="/@{uname}?bmark={bmark}&page={+page + 1}"
        class="page m-button _solid _primary"
        class:_disable={page == pmax}>
        <span>Kế tiếp</span>
        <SvgIcon name="chevron-right" />
      </a>
    </div>
  {/if}
</Vessel>

<style lang="scss">
  .tabs {
    display: flex;
    margin: 0.75rem 0;
    @include border($sides: bottom);
  }

  .tab {
    line-height: 2rem;
    text-transform: uppercase;
    cursor: pointer;
    font-weight: 500;
    padding: 0 0.5rem;
    // max-width: 30vw;

    @include font-size(2);
    @include fgcolor(neutral, 6);
    @include truncate(null);

    &:hover {
      @include fgcolor(primary, 6);
    }

    &._active {
      @include border($sides: bottom, $width: 2px, $color: primary, $shade: 6);
    }
  }

  .pagi {
    margin: 0.75rem 0;
    @include flex($center: content);
    @include flex-gap($gap: 0.375rem, $child: ':global(*)');
  }

  .page {
    display: inline-flex;
    > span {
      margin-top: rem(1px);
    }
  }
</style>

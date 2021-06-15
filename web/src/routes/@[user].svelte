<script context="module">
  import { mark_types, mark_names } from '$lib/constants'

  export async function preload({ params, query }) {
    const uname = params.user
    const bmark = query.bmark || 'reading'
    const page = +(query.page || '1')

    let skip = (page - 1) * 24
    if (skip < 0) skip = 0

    let url = `/api/@${uname}/books?skip=${skip}&take=24&order=update`
    if (bmark != 'reading') url += `&bmark=${bmark}`

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
  import SIcon from '$lib/blocks/SIcon'
  import Nvlist from '$lib/widgets/Nvlist'

  import Vessel from '$lib/layouts/Vessel'

  export let uname = ''
  export let bmark = 'reading'

  export let books = []
  export let total = 0

  export let page = ''

  $: pmax = Math.floor((total - 1) / 24) + 1
  $: if (pmax < 1) pmax = 1
</script>

<svelte:head>
  <title>Tủ truyện của {uname} - Chivi</title>
</svelte:head>

<Vessel>
  <span slot="header-left" class="header-item _active">
    <SIcon name="layers" />
    <span class="header-text _title">Tủ truyện của [{uname}]</span>
  </span>
  <div class="tabs">
    {#each mark_types as mtype}
      <a
        href="/@{uname}?bmark={mtype}"
        class="tab"
        class:_active={mtype == bmark}>
        {mark_names[mtype]}
      </a>
    {/each}
  </div>

  {#if books.length == 0}
    <div class="empty">Danh sách trống</div>
  {:else}
    <Nvlist {books} nvtab="content" />
  {/if}

  <div class="pagi" slot="footer">
    <a
      href="/@{uname}?bmark={bmark}&page={+page - 1}"
      class="page m-button _line"
      class:_disable={page == 1}>
      <SIcon name="chevron-left" />
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
      <SIcon name="chevron-right" />
    </a>
  </div>
</Vessel>

<style lang="scss">
  .tabs {
    display: flex;
    margin: 0.25rem 0 0.75rem;
    justify-content: center;
  }

  .tab {
    @include props(--pad, 0.25rem, 0.375rem, 0.5rem);

    font-weight: 500;
    text-transform: uppercase;

    line-height: 1rem;
    margin-top: 0.5rem;
    border-radius: 0.5rem;

    padding: var(--pad, 0.5rem);
    margin-right: var(--pad, 0.5rem);

    @include truncate(null);
    @include border;
    @include fgcolor(neutral, 6);

    @include props(font-size, rem(10px), rem(12px), rem(13px), rem(14px));

    &:last-child {
      margin-right: 0;
    }

    &:hover,
    &._active {
      @include fgcolor(primary, 6);
    }

    &._active {
      @include bdcolor($color: primary, $shade: 6);
    }

    @include tm-dark {
      @include bdcolor(neutral, 7);
      @include fgcolor(neutral, 5);

      &._active,
      &:hover {
        @include fgcolor(primary, 4);
      }

      &._active {
        @include bdcolor(primary, 5);
      }
    }
  }

  .pagi {
    padding: 0.5rem 0;

    @include flex($center: content);
    @include flex-gap($gap: 0.375rem, $child: ':global(*)');
  }
</style>

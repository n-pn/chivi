<script context="module">
  import { mark_types, mark_names } from '$lib/constants'

  export async function load({ page: { params, query }, fetch }) {
    const uname = params.user
    const bmark = query.get('bmark') || 'reading'
    const page = +query.get('page') || 1

    let url = `/api/cvbooks?page=${page}&take=24&order=update&uname=${uname}`
    if (bmark != 'reading') url += `&bmark=${bmark}`

    const res = await fetch(url)
    if (!res.ok) {
      return {
        status: res.status,
        error: new Error(await res.text()),
      }
    }

    const data = await res.json()
    return { props: { uname, bmark, ...data } }
  }
</script>

<script>
  import { page } from '$app/stores'

  import SIcon from '$atoms/SIcon.svelte'
  import Nvlist from '$parts/Nvlist.svelte'
  import Vessel from '$sects/Vessel.svelte'
  import Mpager, { Pager } from '$molds/Mpager.svelte'
  export let uname = ''
  export let bmark = 'reading'

  export let books = []
  export let total = 0
  export let pgidx = 1
  export let pgmax = 1

  $: pager = new Pager($page.path, $page.query)
  $: console.log({ total })
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
    <Nvlist {books} nvtab="chaps" />
  {/if}

  <div class="pagi" slot="footer">
    <Mpager {pager} {pgidx} {pgmax} />
  </div>
</Vessel>

<style lang="scss">
  .tabs {
    display: flex;
    margin: 0.25rem 0 0.75rem;
    justify-content: center;
  }

  .tab {
    @include fluid(--pad, 0.25rem, 0.375rem, 0.5rem);

    font-weight: 500;
    text-transform: uppercase;

    line-height: 1rem;
    margin-top: 0.5rem;
    border-radius: 0.5rem;

    padding: var(--pad, 0.5rem);
    margin-right: var(--pad, 0.5rem);

    @include clamp($width: null);
    @include border;
    @include fgcolor(neutral, 6);

    @include fluid(font-size, rem(10px), rem(12px), rem(13px), rem(14px));

    &:last-child {
      margin-right: 0;
    }

    &:hover,
    &._active {
      @include fgcolor(primary, 6);
    }

    &._active {
      @include bdcolor(primary, 5);
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
    @include flex($center: horz, $gap: 0.375rem);
  }
</style>

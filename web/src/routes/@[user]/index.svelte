<script context="module">
  import { status_types, status_names } from '$lib/constants'

  export async function load({ page: { params, query }, fetch }) {
    const uname = params.user
    const bmark = query.get('bmark') || 'reading'
    const page = +query.get('page') || 1

    let url = `/api/books?page=${page}&take=24&order=update&uname=${uname}`
    if (bmark != 'reading') url += `&bmark=${bmark}`

    const res = await fetch(url)
    if (res.ok) return { props: { uname, bmark, ...(await res.json()) } }
    return { status: res.status, error: await res.text() }
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
  export let pgidx = 1
  export let pgmax = 1

  $: pager = new Pager($page.path, $page.query)
</script>

<svelte:head>
  <title>Tủ truyện của {uname} - Chivi</title>
</svelte:head>

<Vessel>
  <span slot="header-left" class="header-item _active">
    <SIcon name="notebook" />
    <span class="header-text _title">Tủ truyện của [{uname}]</span>
  </span>
  <div class="tabs">
    {#each status_types as status}
      <a
        href="/@{uname}?bmark={status}"
        class="tab"
        class:_active={status == bmark}>
        {status_names[status]}
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
    @include flex($center: horz, $gap: 0.5rem);
    margin: 1rem 0;
  }

  .tab {
    font-weight: 500;
    text-transform: uppercase;

    padding: 0 0.75rem;
    @include bps(font-size, rem(13px), $md: rem(14px));
    @include bps(line-height, 1.75rem, $md: 2rem);

    @include bdradi();
    @include clamp($width: null);
    @include linesd(--bd-main);
    @include fgcolor(tert);

    &:hover,
    &._active {
      @include fgcolor(primary, 6);
    }

    &._active {
      @include linesd(primary, 5, $ndef: false);
      // overflow: auto;
    }

    @include tm-dark {
      &._active,
      &:hover {
        @include fgcolor(primary, 4);
      }
    }
  }

  .pagi {
    @include flex($center: horz, $gap: 0.375rem);
  }
</style>

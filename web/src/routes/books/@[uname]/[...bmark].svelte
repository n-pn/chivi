<script context="module" lang="ts">
  import { status_types, status_names } from '$lib/constants'
  import { appbar } from '$lib/stores'
  export async function load({ url, params, fetch }) {
    const uname = params.uname
    appbar.set({ left: [[`Tủ truyện của [${uname}]`, 'notebook']] })

    const bmark = params.bmark || 'reading'
    const page = +url.searchParams.get('pg') || 1

    const api_url = `/api/books?pg=${page}&lm=24&order=update&uname=${uname}&bmark=${bmark}`
    const api_res = await fetch(api_url)
    const payload = await api_res.json()

    payload.props.uname = uname
    payload.props.bmark = bmark
    return payload
  }
</script>

<script lang="ts">
  import { page } from '$app/stores'

  import NvinfoList from '$gui/parts/nvinfo/NvinfoList.svelte'
  import Footer from '$gui/sects/Footer.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  export let uname = ''
  export let bmark = 'reading'

  export let books = []
  export let pgidx = 1
  export let pgmax = 1
  // export let total = 1

  $: pager = new Pager($page.url)
</script>

<svelte:head>
  <title>Tủ truyện của {uname} - Chivi</title>
</svelte:head>

<div class="tabs">
  {#each status_types as status}
    <a
      href="/books/@{uname}/{status}"
      class="tab"
      class:_active={status == bmark}>
      {status_names[status]}
    </a>
  {/each}
</div>

{#if books.length == 0}
  <div class="empty">Danh sách trống</div>
{:else}
  <NvinfoList {books} nvtab="chaps" />
{/if}

<Footer>
  <div class="pagi">
    <Mpager {pager} {pgidx} {pgmax} />
  </div>
</Footer>

<style lang="scss">
  .tabs {
    @include flex($center: horz, $gap: 0.5rem);
    margin: 1rem 0;
  }

  .tab {
    font-weight: 500;
    text-transform: uppercase;

    padding: 0 0.75rem;
    @include bps(font-size, rem(13px), $tm: rem(14px));
    @include bps(line-height, 1.75rem, $tm: 2rem);

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

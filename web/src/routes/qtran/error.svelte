<script context="module" lang="ts">
  import { page } from '$app/stores'
  import { invalidate } from '$app/navigation'
  import { appbar } from '$lib/stores'
  export async function load({ fetch, url }) {
    appbar.set({ left: [['Lỗi máy dịch']] })
    const api_res = await fetch(`/api/tlspecs${url.search}`)
    return await api_res.json()
  }
</script>

<script lang="ts">
  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import Tlspec, { ctrl as tlspec } from '$gui/parts/Tlspec.svelte'

  export let pgidx = 1
  export let pgmax = 1
  export let items = []

  const on_destroy = () => invalidate(`/api/tlspecs${$page.url.search}`)

  $: pager = new Pager($page.url)
</script>

<svelte:head>
  <title>Lỗi máy dịch - Chivi</title>
</svelte:head>

<article class="md-article">
  <h1>Lỗi máy dịch (Đỏ: Đang lỗi, Xanh: Đã sửa đúng)</h1>

  <table class="m-table">
    <thead>
      <tr>
        <th class="id">#</th>
        <th class="ztext">Từ gốc</th>
        <th class="cvmtl">Dịch máy</th>
        <th class="match">Nghĩa đúng</th>
        <th class="_meta">N. dùng</th>
      </tr>
    </thead>
    <tbody>
      {#each items as { _ukey, ztext, d_dub, mtime, uname, match, cvmtl }, idx}
        <tr
          class={cvmtl == match ? 'ok' : 'err'}
          on:click={() => tlspec.load(_ukey)}>
          <td class="id">{idx + 1 + (pgidx - 1) * 50}</td>
          <td class="ztext">
            <div class="txt">{ztext}</div>
            <div class="dic">{d_dub}</div>
          </td>
          <td class="cvmtl">
            <div title={cvmtl}>{cvmtl}</div>
          </td>
          <td class="match">
            <div title={match}>{match}</div>
          </td>
          <td class="_meta">
            <div class="uname">{uname}</div>
            <div class="mtime">{get_rtime(mtime)}</div>
          </td>
        </tr>
      {/each}
    </tbody>
  </table>

  <footer class="pagi">
    <Mpager {pager} {pgidx} {pgmax} />
  </footer>
</article>

{#if $tlspec.actived}
  <Tlspec {on_destroy} />
{/if}

<style lang="scss">
  article {
    margin: 1rem 0;
    padding: var(--gutter);
    @include bdradi();
    @include bgcolor(tert);
    @include bps(border-radius, 0, $pl: 1rem);

    @include tm-dark {
      @include linesd(--bd-soft, $ndef: true);
    }
  }

  table {
    margin: 1rem 0;
  }

  tr {
    line-height: 1.25rem;
    // padding: 0.25rem;

    &:hover {
      cursor: pointer;
      @include bgcolor(primary, 5, 1);
    }
  }

  td {
    padding: 0.375rem 0.5rem;
    text-align: center;
    @include ftsize(sm);
    @include fgcolor(tert);
  }

  th {
    text-align: center;
    @include ftsize(xs);
    @include clamp($width: null);
  }

  .txt {
    @include fgcolor(secd);
  }

  .dic {
    font-style: italic;
  }

  .ztext {
    max-width: 10rem;
    > * {
      width: 100%;
      @include clamp($width: null);
    }
  }

  .cvmtl,
  .match {
    max-width: 12rem;

    > * {
      @include clamp($lines: 2, $width: null);
    }

    tr.ok & {
      @include fgcolor(success, 5);
    }

    tr.err & {
      @include fgcolor(harmful);
    }
  }

  ._meta {
    width: 6.5rem;
  }

  .uname {
    font-weight: 500;
  }

  .mtime {
    font-size: 0.9em;
  }

  td.cvmtl,
  td.match {
    font-size: rem(15px);
  }
</style>

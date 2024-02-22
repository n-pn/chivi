<script lang="ts">
  import { invalidate } from '$app/navigation'
  import { page } from '$app/stores'

  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import MtlError, { ctrl as tlspec } from '$gui/parts/MtlError.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  const on_destroy = () => invalidate(`/_sp/mt_errs${$page.url.search}`)

  $: pager = new Pager($page.url)
</script>

<article class="md-article">
  <h1>Lỗi máy dịch</h1>

  <table class="m-table">
    <thead>
      <tr>
        <th class="id">#</th>
        <th class="ztext">Từ gốc</th>
        <th class="qtran">Dịch máy</th>
        <th class="extra">Chú thích</th>
        <th class="uname">N. dùng</th>
      </tr>
    </thead>
    <tbody>
      {#each data.items as { _ukey, ztext, pdict, mtime, qtran, extra, uname }, idx}
        <tr on:click={() => tlspec.load(_ukey)}>
          <td class="id">{idx + 1 + (data.pgidx - 1) * 50}</td>
          <td class="ztext">
            <div class="txt">{ztext}</div>
            <div class="dic">{pdict}</div>
          </td>
          <td class="qtran">
            <div title={qtran}>{qtran}</div>
          </td>
          <td class="extra">
            <div title={extra}>{extra}</div>
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
    <Mpager {pager} pgidx={data.pgidx} pgmax={data.pgmax} />
  </footer>
</article>

{#if $tlspec.actived}<MtlError {on_destroy} />{/if}

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

  .mtran,
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

  .uname {
    width: 6.5rem;
  }

  .uname {
    font-weight: 500;
  }

  .mtime {
    font-size: 0.9em;
  }

  td.mtran,
  td.match {
    font-size: rem(15px);
  }
</style>

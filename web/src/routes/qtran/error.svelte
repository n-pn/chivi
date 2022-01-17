<script context="module">
  import { page } from '$app/stores'
  import { invalidate } from '$app/navigation'
  import { data as appbar } from '$sects/Appbar.svelte'

  export async function load({ fetch, url }) {
    appbar.set({ left: [['Lỗi máy dịch']] })
    const api_res = await fetch(`/api/tlspecs?${url.search}`)
    return { props: await api_res.json() }
  }
</script>

<script>
  import { get_rtime } from '$atoms/RTime.svelte'
  import Vessel from '$sects/Vessel.svelte'
  import Mpager, { Pager } from '$molds/Mpager.svelte'
  import Tlspec, { ctrl as tlspec } from '$parts/Tlspec.svelte'

  export let pgidx = 1
  export let pgmax = 1
  export let items = []

  const on_destroy = () => invalidate(`/api/tlspecs?${$page.url.search}`)

  $: pager = new Pager($page.url)
</script>

<Vessel>
  <article class="md-article">
    <h1>Lỗi máy dịch</h1>

    <table>
      <thead>
        <tr>
          <th class="id">#</th>
          <th class="ztext">Từ gốc</th>
          <th class="cvmtl">Dịch máy</th>
          <th class="match">Nghĩa đúng</th>
          <th class="d_dub">Bộ truyện</th>
          <th class="uname">N. dùng</th>
          <th class="mtime">Cập nhật</th>
        </tr>
      </thead>
      <tbody>
        {#each items as { _ukey, ztext, d_dub, mtime, uname, match, cvmtl }, idx}
          <tr
            class={cvmtl == match ? 'ok' : 'err'}
            on:click={() => tlspec.load(_ukey)}>
            <td class="id">{idx + 1 + (pgidx - 1) * 50}</td>
            <td class="ztext">{ztext}</td>
            <td class="cvmtl" title={cvmtl}>{cvmtl}</td>
            <td class="match" title={match}>{match}</td>
            <td class="d_dub" title={d_dub}>{d_dub}</td>
            <td class="uname">{uname}</td>
            <td class="mtime">{get_rtime(mtime)}</td>
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
</Vessel>

<style lang="scss">
  article {
    margin: 1rem 0;
    padding: var(--gutter);
    @include bdradi();
    @include bgcolor(tert);
    @include bps(margin-left, calc(var(--gutter) * -1), $pl: 0);
    @include bps(margin-right, calc(var(--gutter) * -1), $pl: 0);
    @include bps(border-radius, 0, $pl: 1rem);

    @include tm-dark {
      @include linesd(--bd-soft, $ndef: true);
    }
  }

  table {
    margin: 1rem 0;
  }

  tr {
    cursor: pointer;

    &:hover {
      @include bgcolor(primary, 5, 1);
    }
  }

  td {
    text-align: center;
    @include ftsize(sm);
    @include clamp($width: null);
    @include fgcolor(tert);
  }

  th {
    text-align: center;
    @include ftsize(xs);
    @include clamp($width: null);
  }

  .ztext,
  .d_dub,
  .mtime {
    max-width: 6rem;
  }

  .cvmtl,
  .match {
    max-width: 10rem;

    tr.ok & {
      @include fgcolor(success, 5);
    }

    tr.err & {
      @include fgcolor(harmful);
    }
  }

  .uname {
    max-width: 4.5rem;
  }

  td.cvmtl,
  td.match {
    font-size: rem(15px);
  }
</style>

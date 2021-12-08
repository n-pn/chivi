<script context="module">
  import { page } from '$app/stores'

  export async function load({ fetch, page: { query } }) {
    const res = await fetch(`/api/tlspecs?${query.toString()}`)
    return { props: await res.json() }
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import { get_rtime } from '$atoms/RTime.svelte'

  import Appbar from '$sects/Appbar.svelte'
  import Vessel from '$sects/Vessel.svelte'
  import Mpager, { Pager } from '$molds/Mpager.svelte'
  export let pgidx = 1
  export let pgmax = 1
  export let items = []

  $: pager = new Pager($page.path, $page.query, { page: 1 })
</script>

<Appbar>
  <svelte:fragment slot="left">
    <span class="header-item _active">
      <SIcon name="messages" />
      <span class="header-text">Máy dịch</span>
    </span>
  </svelte:fragment>
</Appbar>

<Vessel>
  <article class="md-article">
    <h1>Lỗi máy dịch</h1>

    <table>
      <thead>
        <tr>
          <th class="ztext">Từ gốc</th>
          <th class="cvmtl">Dịch máy</th>
          <th class="match">Nghĩa chuẩn</th>
          <th class="d_dub">Bộ truyện</th>
          <th class="uname">Người báo</th>
          <th class="mtime">Thời gian</th>
        </tr>
      </thead>
      <tbody>
        {#each items as { ztext, d_dub, mtime, uname, match, cvmtl }}
          <tr class={cvmtl == match ? 'ok' : 'err'}>
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

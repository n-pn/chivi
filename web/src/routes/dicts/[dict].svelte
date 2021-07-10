<script context="module">
  import { labels } from '$lib/postag'

  export async function load({ fetch, page: { path, query } }) {
    const url = `/api/${path}?${query.toString()}`
    const res = await fetch(url)
    return { props: await res.json() }
  }
</script>

<script>
  import { page } from '$app/stores'

  import Vessel from '$lib/layouts/Vessel.svelte'
  import CPagi, { Pager } from '$lib/blocks/CPagi.svelte'
  import SIcon from '$lib/blocks/SIcon.svelte'
  import { get_rtime_short } from '$lib/blocks/RTime.svelte'

  export let label = 'Thông dụng'
  export let dname = 'regular'
  export let p_min = 1
  export let terms = []
  export let total = 1
  export let pgidx = 1
  export let pgmax = 1

  $: offset = (pgidx - 1) * 30 + 1
  function render_time(mtime) {
    return mtime > 1577836800 ? get_rtime_short(mtime) : '~'
  }

  $: pager = new Pager($page.path, $page.query)

  function render_ptag(tag) {
    return labels[tag] || tag || '~'
  }

  function render_rank(wgt) {
    switch (wgt) {
      case 1:
        return '-2'
      case 2:
        return '-1'
      case 4:
        return '+1'
      case 5:
        return '+2'
      default:
        return '~'
    }
  }

  function render_privi(privi) {
    if (p_min == privi) return '~'
    if (p_min > privi) return 'v' + (p_min - privi)
    return '^' + (privi - p_min)
  }
</script>

<svelte:head>
  <title>Từ điển: {label} - Chivi</title>
</svelte:head>

<Vessel>
  <svelte:fragment slot="header-left">
    <a href="/dicts" class="header-item">
      <SIcon name="box" />
      <span class="header-text">Từ điển</span>
    </a>

    <span class="header-item _active _title">
      <span class="header-text _show-md _title">{label}</span>
    </span>
  </svelte:fragment>

  <article class="m-article">
    <h1>{label}</h1>
    <p>Entries: {total}</p>

    <div class="table">
      <table>
        <thead>
          <tr>
            <th>#</th>
            <th>Trung</th>
            <th>Nghĩa Việt</th>
            <th>Phân loại</th>
            <th>Ư.t</th>
            <th>Người dùng</th>
            <th>Q.</th>
            <th>Cập nhật</th>
          </tr>
        </thead>

        <tbody>
          {#each terms as { key, val, tag, wgt, mtime, uname, privi }, idx}
            <tr>
              <td class="-idx">{offset + idx}</td>
              <td class="-key">{key}</td>
              <td class="-val">{val.join(' / ')}</td>
              <td class="-tag"
                ><a href="{$page.path}?tag={tag || '!'}">{render_ptag(tag)}</a
                ></td>
              <td class="-wgt">
                <a href="{$page.path}?wgt={wgt}">{render_rank(wgt)}</a>
              </td>
              <td class="-uname">
                <a href="{$page.path}?uname={uname}"
                  >{uname == '_' ? '~' : uname}</a>
              </td>
              <td class="-privi" class:_gt={privi > p_min}>
                <a href="{$page.path}?privi={privi}">{render_privi(privi)}</a>
              </td>
              <td class="-mtime">{render_time(mtime)}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>

    <footer class="foot">
      <CPagi {pager} {pgidx} {pgmax} />
    </footer>
  </article>
</Vessel>

<style lang="scss">
  article {
    margin: 1rem 0;
    padding: 1rem;
    background: #fff;
    @include shadow();
    @include radius();
    @include fgcolor(neutral, 8);
  }

  .pagi {
    display: flex;
    justify-content: center;

    .m-button + .m-button {
      // width: 5rem;
      // text-align: center;
      margin-left: 0.5rem;
    }
  }

  .table {
    display: block;
    width: 100%;
    overflow-x: auto;
    white-space: nowrap;
  }

  table {
    width: 100%;
    max-width: 100%;
  }

  th,
  td {
    text-align: center;
    line-height: 1.5rem;
    padding: 0.375rem 0.5rem;
  }

  tbody > tr:hover {
    cursor: pointer;
    background-color: color(primary, 4, 0.1);
  }

  td > a {
    @include fgcolor(neutral, 6);
    &:hover {
      @include fgcolor(primary, 6);
    }
  }

  .-idx,
  .-wgt,
  .-tag,
  .-mtime,
  .-privi,
  .-uname {
    font-size: rem(14px);
    @include truncate(null);
    @include fgcolor(neutral, 6);
  }

  .-privi._gt {
    @include fgcolor(primary, 6);
  }

  .-val {
    font-size: rem(14px);
    @include truncate(null);
  }
</style>

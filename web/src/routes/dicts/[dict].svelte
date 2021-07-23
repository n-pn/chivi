<script context="module">
  import Lookup, {
    activate as lookup_activate,
    enabled as lookup_enabled,
  } from '$parts/Lookup.svelte'

  import Upsert, {
    activate as upsert_activate,
    state as upsert_state,
  } from '$parts/Upsert.svelte'

  import Postag from '$parts/Postag.svelte'
  import { tag_label } from '$lib/pos_tag'

  export async function load({ fetch, page: { path, query } }) {
    const url = `/api/${path}?${query.toString()}`
    const res = await fetch(url)
    return {
      props: { ...(await res.json()), query: Object.fromEntries(query) },
    }
  }
</script>

<script>
  import { page } from '$app/stores'

  import SIcon from '$atoms/SIcon.svelte'
  import { get_rtime_short } from '$atoms/RTime.svelte'

  import { MtData } from '$lib/mt_data'

  import Mpager, { Pager } from '$molds/Mpager.svelte'
  import Vessel from '$sects/Vessel.svelte'

  export let label = ''
  export let dname = ''

  export let p_min = 1
  export let terms = []

  export let total = 1
  export let pgidx = 1
  export let pgmax = 1

  export let query = { key: '', val: '', ptag: '', rank: '' }

  $: offset = (pgidx - 1) * 30 + 1
  function render_time(mtime) {
    return mtime > 1577836800 ? get_rtime_short(mtime) + ' trước' : '~'
  }

  let postag_state = 1

  let _dirty = false
  $: if (_dirty) window.location.reload()

  $: pager = new Pager($page.path, $page.query)

  function render_rank(rank) {
    switch (rank) {
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

  function upsert_dict(dname, label) {
    if (dname == 'regular' || dname == 'hanviet') {
      return { dname: 'combine', label: 'Tổng hợp' }
    } else {
      return { dname, label }
    }
  }

  function reset_query() {
    for (let key in query) query[key] = ''
    query = query
  }
</script>

<svelte:head>
  <title>Từ điển: {label} - Chivi</title>
</svelte:head>

<Vessel>
  <svelte:fragment slot="header-left">
    <a href="/dicts" class="header-item">
      <SIcon name="box" />
      <span class="header-text _show-md">Từ điển</span>
    </a>

    <a href={$page.path} class="header-item _active _title">
      <span class="header-text _title">{label}</span>
    </a>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <button
      class="header-item"
      class:_active={$lookup_enabled}
      on:click={() => lookup_enabled.update((x) => !x)}
      data-kbd="\">
      <SIcon name="compass" />
      <span class="header-text _show-md">Giải nghĩa</span>
    </button>
  </svelte:fragment>

  <article class="m-article">
    <h1 class="h3">{label}</h1>
    <p>Entries: {total}</p>

    <div class="body">
      <table>
        <thead>
          <tr class="thead">
            <th>#</th>
            <th>Trung</th>
            <th>Nghĩa Việt</th>
            <th>Phân loại</th>
            <th>Ư.t</th>
            <th>Người dùng</th>
            <th>Q.</th>
            <th>Cập nhật</th>
          </tr>

          <tr class="tquery">
            <td><SIcon name="search" /></td>
            <td
              ><input type="text" placeholder="-" bind:value={query.key} /></td>
            <td
              ><input type="text" placeholder="-" bind:value={query.val} /></td>
            <td>
              <button
                class="m-button btn-sm"
                on:click={() => (postag_state = 2)}
                >{tag_label(query.ptag) || '-'}</button>
            </td>
            <td
              ><input
                type="text"
                placeholder="-"
                bind:value={query.rank} /></td>
            <td
              ><input
                type="text"
                placeholder="-"
                bind:value={query.uname} /></td>
            <td
              ><input
                type="text"
                placeholder="-"
                bind:value={query.privi} /></td>
            <td>
              <button class="m-button btn-sm" on:click={reset_query}>
                <SIcon name="erase" />
              </button>
              <a
                class="m-button btn-sm"
                data-kbd="ctrl+enter"
                href={pager.url({ ...query, page: 1 })}>
                <SIcon name="search" />
              </a>
            </td>
          </tr>
        </thead>

        <tbody>
          {#each terms as { key, val, ptag, rank, mtime, uname, privi }, idx}
            <tr>
              <td class="-idx">{offset + idx}</td>
              <td
                class="-key"
                on:click={() =>
                  lookup_activate(true, new MtData([[key, val, ptag, 1]]))}>
                <span>{key}</span>
                <div class="hover">
                  <span class="m-button btn-xs _active">
                    <SIcon name="compass" />
                  </span>

                  <button
                    class="m-button btn-xs"
                    on:click|stopPropagation={() => (query.key = key)}>
                    <SIcon name="search" />
                  </button>
                </div>
              </td>
              <td
                class="-val"
                class:_del={!val[0]}
                on:click={() => upsert_activate(key)}>
                <span>
                  {val[0] || 'Đã xoá'}
                </span>

                <div class="hover">
                  <span class="m-button btn-xs _active">
                    <SIcon name="edit-2" />
                  </span>
                  <button
                    class="m-button btn-xs"
                    on:click|stopPropagation={() => (query.val = val[0])}>
                    <SIcon name="search" />
                  </button>
                </div>
              </td>
              <td class="-ptag">
                <span on:click={() => upsert_activate(key, 0, 2)}>
                  {tag_label(ptag) || '~'}
                </span>
                <div class="hover">
                  <button
                    on:click={() => upsert_activate(key, 0, 2)}
                    class="m-button btn-xs _active">
                    <SIcon name="edit-2" />
                  </button>
                  <a
                    class="m-button btn-xs"
                    href={pager.url({ ptag: ptag || '~' })}>
                    <SIcon name="search" />
                  </a>
                </div>
              </td>
              <td class="-rank">
                <a href="{$page.path}?rank={rank}">{render_rank(rank)}</a>
              </td>
              <td class="-uname">
                <a href="{$page.path}?uname={uname}"
                  >{uname == '_' ? '~' : uname}</a>
              </td>
              <td class="-privi" class:_gt={privi > p_min}>
                <a href="{$page.path}?privi={privi}">{render_privi(privi)}</a>
              </td>
              <td class="-mtime">{render_time(mtime)} </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>

    <footer class="foot">
      <Mpager {pager} {pgidx} {pgmax} />
    </footer>
  </article>
</Vessel>

{#if $lookup_enabled}
  <Lookup {dname} />
{/if}

{#if $upsert_state > 0}
  <Upsert bind:_dirty {...upsert_dict(dname, label)} />
{/if}

{#if postag_state > 1}
  <Postag bind:state={postag_state} bind:ptag={query.ptag} />
{/if}

<style lang="scss">
  article {
    // padding: var;
    @include bgcolor(main);
    // @include fgcolor(main);
    @include shadow(1);
    @include bdradi();
  }

  .body {
    display: block;
    width: 100%;
    overflow-x: auto;
    white-space: nowrap;
  }

  table {
    width: 100%;
    max-width: 100%;
    color: var(--fg-secd);
    @include ftsize(sm);
  }

  th,
  td {
    text-align: center;
    line-height: 1.5rem;
    padding: 0.375rem 0.5rem;
    @include clamp($width: null);
  }

  tbody {
    tr:hover {
      cursor: pointer;
      background-color: color(primary, 5, 1);
    }

    td {
      position: relative;
    }

    td > a {
      color: inherit;
      display: block;
      &:hover {
        @include fgcolor(primary, 5);
      }
    }
  }

  .hover {
    position: absolute;
    right: 0;
    top: 0;
    padding: 0.325rem;

    visibility: hidden;
    z-index: 99;
    // prettier-ignore
    td:hover > & { visibility: visible; }
  }

  .-key {
    @include ftsize(md);
  }

  .-idx,
  .-rank,
  .-mtime,
  .-privi,
  .-uname {
    @include fgcolor(tert);
  }

  .-privi._gt {
    @include fgcolor(primary, 5);
  }

  .-val {
    font-size: rem(14px);
    max-width: 12rem;

    &._del {
      font-style: italic;
      @include fgcolor(mute);
    }
  }

  .tquery {
    input {
      margin: 0;
      padding: 0 0.5rem;
      border: 0;
      width: 100%;
      height: 2rem;
      text-align: center;

      @include bdradi();
      @include fgcolor(secd);
      @include bgcolor(tert);
      @include linesd(--bd-main);

      &:focus {
        @include bgcolor(secd);
        @include linesd(primary, 5, $ndef: false);
      }
    }
  }
</style>

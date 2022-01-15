<script context="module">
  import { page, session } from '$app/stores'
  import { invalidate } from '$app/navigation'

  import { ztext, vdict } from '$lib/stores'

  import Lookup, { ctrl as lookup } from '$parts/Lookup.svelte'
  import Upsert, { ctrl as upsert } from '$parts/Upsert.svelte'

  import Postag, { ptnames } from '$parts/Postag.svelte'

  export async function load({ fetch, url }) {
    const api_url = `/api/${url.pathname}?${url.searchParams.toString()}`
    const res = await fetch(api_url)
    return {
      props: {
        ...(await res.json()),
        query: Object.fromEntries(url.searchParams),
      },
    }
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import { get_rtime_short } from '$atoms/RTime.svelte'

  import Mpager, { Pager } from '$molds/Mpager.svelte'
  import { data as appbar } from '$sects/Appbar.svelte'
  import Vessel from '$sects/Vessel.svelte'

  export let dname = 'combine'
  export let d_dub = 'Tổng hợp'

  $: {
    if (dname == 'regular' || dname == 'hanviet') {
      vdict.set({ dname: 'combine', d_dub: 'Tổng hợp' })
    } else {
      vdict.set({ dname, d_dub })
    }
  }
  $: d_tab = dname == 'regular' ? 1 : dname == 'hanviet' ? 2 : 0

  // export let p_min = 1
  export let terms = []

  export let total = 1
  export let pgidx = 1
  export let pgmax = 1

  export let query = { key: '', val: '', ptag: '', rank: '', uname: '' }

  $: offset = (pgidx - 1) * 30 + 1
  function render_time(mtime) {
    return mtime > 1577836800 ? get_rtime_short(mtime) + ' trước' : '~'
  }

  let postag_state = 1

  const on_change = () =>
    invalidate(
      `/api/${$page.url.pathname}?${$page.url.searchParams.toString()}`
    )

  $: pager = new Pager($page.url)

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

  function reset_query() {
    for (let key in query) query[key] = ''
    query = query
  }

  function special_type(uname) {
    if (!uname) return 'a'
    if (uname.charAt(0) != '!') return uname == $session.uname ? 'b' : 'c'
    return uname == '!' + $session.uname ? 'd' : 'e'
  }

  function show_lookup(key) {
    ztext.put(key)
    lookup.show(true)
  }

  function show_upsert(key, state = 1) {
    ztext.put(key)
    upsert.show(d_tab, state)
  }

  $: appbar.set({
    left: [
      ['Từ điển', 'package', '/dicts', null, '_show-md'],
      [d_dub, null, $page.url.pathname, '_title', '_title'],
    ],
  })
</script>

<svelte:head>
  <title>Từ điển: {d_dub} - Chivi</title>
</svelte:head>

<Vessel>
  <article class="m-article">
    <h1 class="h3">{d_dub}</h1>
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
            <th>Cập nhật</th>
          </tr>

          <tr class="tquery">
            <td><SIcon name="search" /></td>
            <td
              ><input type="text" placeholder="-" bind:value={query.key} /></td>
            <td
              ><input type="text" placeholder="-" bind:value={query.val} /></td>
            <td>
              <button class="m-btn _sm" on:click={() => (postag_state = 2)}
                >{ptnames[query.ptag] || '-'}</button>
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
            <td>
              <button class="m-btn _sm" on:click={reset_query}>
                <SIcon name="eraser" />
              </button>
              <a
                class="m-btn _sm"
                data-kbd="ctrl+enter"
                href={pager.make_url({ ...query, page: 1 })}>
                <SIcon name="search" />
              </a>
            </td>
          </tr>
        </thead>

        <tbody>
          {#each terms as { key, val, ptag, rank, mtime, uname, _flag }, idx}
            <tr class="term _{_flag}">
              <td class="-idx">{offset + idx}</td>
              <td class="-key" on:click={() => show_lookup(key)}>
                <span>{key}</span>
                <div class="hover">
                  <span class="m-btn _xs _active">
                    <SIcon name="compass" />
                  </span>

                  <button
                    class="m-btn _xs"
                    on:click|stopPropagation={() => (query.key = key)}>
                    <SIcon name="search" />
                  </button>
                </div>
              </td>
              <td
                class="-val"
                class:_del={!val[0]}
                on:click={() => show_upsert(key, 1)}>
                <span>
                  {val[0] || 'Đã xoá'}
                </span>

                <div class="hover">
                  <span class="m-btn _xs _active">
                    <SIcon name="pencil" />
                  </span>
                  <button
                    class="m-btn _xs"
                    on:click|stopPropagation={() => (query.val = val[0])}>
                    <SIcon name="search" />
                  </button>
                </div>
              </td>
              <td class="-ptag">
                <span on:click={() => show_upsert(key, 2)}>
                  {ptnames[ptag] || '~'}
                </span>
                <div class="hover">
                  <button
                    on:click={() => show_upsert(key, 2)}
                    class="m-btn _xs _active">
                    <SIcon name="pencil" />
                  </button>
                  <a
                    class="m-btn _xs"
                    href={pager.make_url({ ptag: ptag || '~' })}>
                    <SIcon name="search" />
                  </a>
                </div>
              </td>
              <td class="-rank">
                <a href="{$page.url.pathname}?rank={rank}"
                  >{render_rank(rank)}</a>
              </td>
              <td class="-uname  _{special_type(uname)}">
                <a href="{$page.url.pathname}?uname={uname}">{uname}</a>
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

{#if $lookup.enabled}
  <Lookup />
{/if}

{#if $upsert.state > 0}
  <Upsert {on_change} />
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
  .-uname {
    @include fgcolor(tert);
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

  .term {
    &._1,
    &._2 {
      @include bgcolor(neutral, 5, 3);
      text-decoration: line-through;
      font-style: italic;
    }
  }

  ._b {
    @include fgcolor(success);
  }

  ._c {
    @include fgcolor(primary);
  }

  ._d {
    @include fgcolor(warning);
  }

  ._e {
    @include fgcolor(harmful);
  }
</style>

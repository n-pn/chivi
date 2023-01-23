<script lang="ts">
  import { page } from '$app/stores'
  import { invalidate } from '$app/navigation'
  import { browser } from '$app/environment'

  import { ztext, vdict, session } from '$lib/stores'
  import { rel_time_vp } from '$utils/time_utils'

  import Lookup, { ctrl as lookup } from '$gui/parts/Lookup.svelte'
  import Upsert, { ctrl as upsert } from '$gui/parts/Upsert.svelte'
  import pt_labels from '$lib/consts/postag_labels.json'

  import Postag from '$gui/parts/Postag.svelte'

  import { Crumb, SIcon } from '$gui'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ query, terms, start } = data)

  $: vdict.put(data.dname, data.label)

  let d_tab = 2
  $: {
    if (data.dname == 'generic') d_tab = 1
    else if (data.dname == 'combine' || data.dname.startsWith('-')) d_tab = 0
    else d_tab = 2
  }

  let postag_state = 1

  // prettier-ignore
  const on_change = () => invalidate(`/_db/${$page.url.pathname}${$page.url.search}`)

  $: pager = new Pager($page.url)

  const prio_labels = ['Ẩn', 'Thấp', 'Bình', 'Cao']

  function reset_query() {
    for (let key in query) query[key] = ''
    query = query
  }

  function show_lookup(key: string) {
    ztext.put(key)
    lookup.show(true)
  }

  function show_upsert(key: string, state = 1) {
    ztext.put(key)
    upsert.show(d_tab, state)
  }

  const tab_labels = ['Tự động', 'Chung', 'Nháp', 'Riêng']

  const uname_class = (uname: string) =>
    uname == $session.uname ? '_self' : '_other'
</script>

<Crumb
  tree={[
    ['Từ điển', '/dicts'],
    [data.label, $page.url.pathname],
  ]} />

<article class="article m-article">
  <h1 class="h2">{data.label} <code>[{data.dname}]</code></h1>
  <p class="brief">{data.brief}</p>

  <h2 class="h3">Số lượng từ: {data.dsize}</h2>

  <div class="body">
    <table>
      <thead>
        <tr class="thead">
          <th>#</th>
          <th>Trung</th>
          <th>Nghĩa Việt</th>
          <th>Phân loại</th>
          <th class="prio">Ư.t</th>
          <th class="uname">Người dùng</th>
          <th class="_mode">Cách lưu</th>
          <th>Cập nhật</th>
        </tr>

        <tr class="tquery">
          <td><SIcon name="search" /></td>
          <td><input type="text" placeholder="-" bind:value={query.key} /></td>
          <td><input type="text" placeholder="-" bind:value={query.val} /></td>
          <td>
            <button class="m-btn _sm" on:click={() => (postag_state = 2)}
              >{pt_labels[query.ptag] || '-'}</button>
          </td>
          <td class="prio"
            ><input type="text" placeholder="-" bind:value={query.prio} /></td>
          <td class="uname"
            ><input type="text" placeholder="-" bind:value={query.uname} /></td>
          <td class="_mode"
            ><input type="text" placeholder="-" bind:value={query.tab} /></td>
          <td>
            <button class="m-btn _sm" on:click={reset_query}>
              <SIcon name="eraser" />
            </button>
            <a
              class="m-btn _sm"
              data-kbd="ctrl+enter"
              href={pager.gen_url({ ...query, pg: 1 })}>
              <SIcon name="search" />
            </a>
          </td>
        </tr>
      </thead>

      <tbody>
        {#each terms as { key, vals, ptag, prio, mtime, uname, _flag, tab }, idx}
          <tr class="term _{_flag}">
            <td class="-idx">{start + idx}</td>
            <!-- svelte-ignore a11y-click-events-have-key-events -->
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
            <!-- svelte-ignore a11y-click-events-have-key-events -->
            <td
              class="-val"
              class:_del={!vals[0]}
              on:click={() => show_upsert(key, 1)}>
              <span>{vals.join(' | ') || 'Đã xoá'}</span>

              <div class="hover">
                <span class="m-btn _xs _active">
                  <SIcon name="pencil" />
                </span>
                <button
                  class="m-btn _xs"
                  on:click|stopPropagation={() => (query.val = vals[0])}>
                  <SIcon name="search" />
                </button>
              </div>
            </td>
            <td class="-tag">
              <!-- svelte-ignore a11y-click-events-have-key-events -->
              <span on:click={() => show_upsert(key, 2)}>
                {ptag || '~'}
              </span>
              <div class="hover">
                <button
                  on:click={() => show_upsert(key, 2)}
                  class="m-btn _xs _active">
                  <SIcon name="pencil" />
                </button>
                <a
                  class="m-btn _xs"
                  href={pager.gen_url({ ptag: ptag || '~' })}>
                  <SIcon name="search" />
                </a>
              </div>
            </td>
            <td class="prio">
              <a href="{$page.url.pathname}?prio={prio}">{prio_labels[prio]}</a>
            </td>
            <td class="uname {uname_class(uname)}">
              <a href="{$page.url.pathname}?uname={uname}">{uname}</a>
            </td>
            <td class="_mode _{tab}">{tab_labels[tab]} </td>
            <td class="mtime">{rel_time_vp(mtime)} </td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>

  <footer class="foot">
    <Mpager {pager} pgidx={data.pgidx} pgmax={data.pgmax} />
  </footer>
</article>

{#if browser}
  <Lookup />

  {#if $upsert.state > 0}<Upsert {on_change} />{/if}

  {#if postag_state > 1}
    <Postag bind:state={postag_state} bind:ptag={query.ptag} />
  {/if}
{/if}

<style lang="scss">
  .brief {
    font-style: italic;
    margin-top: 1rem;
    @include fgcolor(tert);
  }

  .h3 {
    margin-top: 1rem;
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
    max-width: 4rem;
    @include ftsize(md);
  }

  .-idx,
  .prio,
  .mtime,
  .uname {
    @include fgcolor(tert);
  }

  .prio {
    width: 3rem;
  }

  .uname {
    width: 6rem;

    &._self {
      @include fgcolor(harmful);
    }

    &._other {
      @include fgcolor(primary);
    }
  }

  ._mode {
    width: 4rem;
    @include ftsize(xs);

    &._0 {
      @include fgcolor(success);
    }

    &._1 {
      @include fgcolor(neutral);
    }

    &._2 {
      @include fgcolor(private);
    }
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

  thead .m-btn {
    background: transparent;

    &:hover {
      @include bgcolor(main);
    }
  }
</style>

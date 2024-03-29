<script lang="ts">
  import { page } from '$app/stores'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { rel_time_vp } from '$utils/time_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ dinfo, table } = data)

  $: filter = data.filter

  $: pager = new Pager($page.url)
  $: root_path = $page.url.pathname

  function reset_filter() {
    for (let key in filter) filter[key] = ''
    filter = filter
  }
</script>

<article class="article m-article">
  <header>
    <h1 class="h2">{dinfo.label} <small>Số lượng từ: {dinfo.total}</small></h1>
  </header>

  <div class="body">
    <table>
      <thead>
        <tr class="thead">
          <th>#</th>
          <th class="zstr">Trung</th>
          <th class="vstr">Nghĩa</th>
          <th class="cpos">Từ loại</th>
          <th class="attr">Thuộc tính</th>
          <th class="user">Người dùng</th>
          <th class="scope">Khóa</th>
          <th>Cập nhật</th>
        </tr>

        <tr class="filter">
          <td><SIcon name="search" /></td>
          <td><input type="text" placeholder="-" bind:value={filter.zstr} /></td>
          <td><input type="text" placeholder="-" bind:value={filter.vstr} /></td>
          <td>
            <button class="m-btn _sm">{filter.cpos || '-'}</button>
          </td>
          <td class="attr"><input type="text" placeholder="-" bind:value={filter.attr} /></td>
          <td class="user"><input type="text" placeholder="-" bind:value={filter.user} /></td>
          <td class="lock"><input type="text" placeholder="-" bind:value={filter.lock} /></td>
          <td>
            <button class="m-btn _sm" on:click={reset_filter}>
              <SIcon name="eraser" />
            </button>
            <a class="m-btn _sm" data-kbd="ctrl+enter" href={pager.gen_url({ ...filter, pg: 1 })}>
              <SIcon name="search" />
            </a>
          </td>
        </tr>
      </thead>

      <tbody>
        {#each table.items as { zstr, vstr, cpos, attr, time, user, lock }, idx}
          {@const edit_url = `/mt/dicts/${data.dict}/+defn?zstr=${zstr}&cpos=${cpos}`}
          <tr class="defn">
            <td class="-idx">
              <a href={edit_url}>{table.start + idx}</a>
            </td>
            <!-- svelte-ignore a11y-click-events-have-zstr-events -->
            <td class="-zstr">
              <span>{zstr}</span>
              <div class="hover">
                <button class="m-btn _xs" on:click|stopPropagation={() => (filter.zstr = zstr)}>
                  <SIcon name="search" />
                </button>
              </div>
            </td>

            <!-- svelte-ignore a11y-click-events-have-zstr-events -->
            <td class="-vstr">
              <span>{vstr}</span>

              <div class="hover">
                <a class="m-btn _xs _active" href={edit_url}><SIcon name="pencil" /></a>
                <button class="m-btn _xs" on:click|stopPropagation={() => (filter.vstr = vstr)}>
                  <SIcon name="search" />
                </button>
              </div>
            </td>
            <td class="cpos">
              <button type="button" class="m-as-btn">
                {cpos}
              </button>
              <div class="hover">
                <a class="m-btn _xs" href={pager.gen_url({ cpos: cpos })}>
                  <SIcon name="search" />
                </a>
              </div>
            </td>
            <td class="attr">
              <span class="flex">
                {#if attr}
                  {#each attr.split(' ') as a}
                    <a href="{root_path}?attr={a}"><code>{a}</code></a>
                  {/each}
                {:else}
                  <code>None</code>
                {/if}
              </span>
            </td>
            <td class="user" class:_self={user == $_user.uname}>
              <a href="{root_path}?user={user}">{user}</a>
            </td>
            <td class="lock _{lock}">
              <a href="{root_path}?lock={lock}">
                <SIcon name="plock-{lock}" iset="icons" />
              </a>
            </td>
            <td class="time">{rel_time_vp(time)} </td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>

  <footer class="foot">
    <Mpager {pager} pgidx={table.pgidx} pgmax={table.pgmax} />
  </footer>
</article>

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
    @include border(--bd-soft, $loc: top-bottom);
    border-left: none;
    border-right: none;
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

  .-zstr {
    max-width: 4rem;
    @include ftsize(md);
  }

  .-idx,
  .time,
  .user {
    @include fgcolor(tert);
  }

  .attr {
    width: 3rem;

    a {
      @include fgcolor(tert);
      &:hover {
        @include fgcolor(primary, 5);
      }
    }
  }

  .user {
    width: 6rem;
    font-weight: 500;

    &._self {
      font-style: italic;
    }
  }

  .scope {
    width: 4rem;
    @include ftsize(xs);

    &._1 {
      @include fgcolor(success);
    }

    &._2 {
      @include fgcolor(neutral);
    }

    &._3 {
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

  .filter {
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

  .defn._mute {
    @include bgcolor(neutral, 5, 3);
    text-decoration: line-through;
    font-style: italic;
  }

  .defn._temp {
    @include fgcolor(tert);
    font-style: italic;
  }

  thead .m-btn {
    background: transparent;

    &:hover {
      @include bgcolor(main);
    }
  }

  .lock {
    &._0 {
      @include fgcolor(success);
    }

    &._1 {
      @include fgcolor(primary);
    }

    &._2 {
      @include fgcolor(warning);
    }
  }
</style>

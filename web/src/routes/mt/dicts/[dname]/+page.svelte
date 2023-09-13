<script lang="ts">
  import { page } from '$app/stores'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { rel_time_vp } from '$utils/time_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ dinfo, terms } = data)

  $: query = data.query

  $: pager = new Pager($page.url)
  $: root_path = $page.url.pathname

  function reset_query() {
    for (let key in query) query[key] = ''
    query = query
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
          <th class="uname">Người dùng</th>
          <th class="scope">Khóa</th>
          <th>Cập nhật</th>
        </tr>

        <tr class="tquery">
          <td><SIcon name="search" /></td>
          <td><input type="text" placeholder="-" bind:value={query.zstr} /></td>
          <td><input type="text" placeholder="-" bind:value={query.vstr} /></td>
          <td>
            <button class="m-btn _sm">{query.cpos || '-'}</button>
          </td>
          <td class="attr"
            ><input type="text" placeholder="-" bind:value={query.attr} /></td>
          <td class="uname"
            ><input type="text" placeholder="-" bind:value={query.uname} /></td>
          <td class="plock"
            ><input type="text" placeholder="-" bind:value={query.plock} /></td>
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
        {#each terms.items as { zstr, vstr, cpos, attr, mtime, uname, plock }, idx}
          <tr class="term">
            <td class="-idx">
              <a href="/mt/dicts/{data.dname}/+term?zstr={zstr}&cpos={cpos}">
                {terms.start + idx}</a>
            </td>
            <!-- svelte-ignore a11y-click-events-have-zstr-events -->
            <td class="-zstr">
              <span>{zstr}</span>
              <div class="hover">
                <button
                  class="m-btn _xs"
                  on:click|stopPropagation={() => (query.zstr = zstr)}>
                  <SIcon name="search" />
                </button>
              </div>
            </td>

            <!-- svelte-ignore a11y-click-events-have-zstr-events -->
            <td class="-vstr">
              <span>{vstr}</span>

              <div class="hover">
                <span class="m-btn _xs _active">
                  <SIcon name="pencil" />
                </span>
                <button
                  class="m-btn _xs"
                  on:click|stopPropagation={() => (query.vstr = vstr)}>
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
              <span class="flex"
                >{#each attr.split(' ') as a}
                  <a href="{root_path}?attr={a}">{a}</a>
                {/each}</span>
            </td>
            <td class="uname" class:_self={uname == $_user.uname}>
              <a href="{root_path}?uname={uname}">{uname}</a>
            </td>
            <td class="plock _{plock}">
              <a href="{root_path}?plock={plock}">
                <SIcon name="plock-{plock}" iset="icons" />
              </a>
            </td>
            <td class="mtime">{rel_time_vp(mtime)} </td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>

  <footer class="foot">
    <Mpager {pager} pgidx={terms.pgidx} pgmax={terms.pgmax} />
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
  .mtime,
  .uname {
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

  .uname {
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

  .term._mute {
    @include bgcolor(neutral, 5, 3);
    text-decoration: line-through;
    font-style: italic;
  }

  .term._temp {
    @include fgcolor(tert);
    font-style: italic;
  }

  thead .m-btn {
    background: transparent;

    &:hover {
      @include bgcolor(main);
    }
  }

  .plock {
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

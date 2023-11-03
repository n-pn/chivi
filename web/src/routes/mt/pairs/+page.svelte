<script lang="ts" context="module">
  import { dnames } from '$lib/consts/pair_dicts'
</script>

<script lang="ts">
  import { page } from '$app/stores'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { rel_time_vp } from '$utils/time_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: query = data.query

  $: pager = new Pager($page.url)

  function reset_query() {
    for (let key in query) query[key] = ''
    query = query
  }
</script>

<article class="article m-article">
  <header>
    <h1 class="h2">Nghĩa cặp từ</h1>
  </header>

  <div class="body">
    <table>
      <thead>
        <tr class="thead">
          <th class="dname">Loại</th>
          <th class="a_key">Gốc A</th>
          <th class="b_key">Gốc B</th>
          <th class="a_vstr">Nghĩa A</th>
          <th class="a_attr">Từ tính A</th>
          <th class="b_vstr">Nghĩa B</th>
          <th class="b_attr">Từ tính B</th>
          <th class="uname">Người dùng</th>
          <th>Cập nhật</th>
        </tr>

        <tr class="tquery">
          <td><SIcon name="search" /></td>
          <td
            ><input type="text" placeholder="-" bind:value={query.dname} /></td>
          <td
            ><input type="text" placeholder="-" bind:value={query.a_key} /></td>
          <td
            ><input type="text" placeholder="-" bind:value={query.b_key} /></td>
          <td><input type="text" placeholder="-" disabled /></td>
          <td><input type="text" placeholder="-" disabled /></td>
          <td><input type="text" placeholder="-" disabled /></td>
          <td
            ><input type="text" placeholder="-" bind:value={query.uname} /></td>

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
        {#each data.items as { dname, a_key, b_key, a_vstr, a_attr, b_vstr, b_attr, uname, mtime }, idx}
          {@const a_attrs = a_attr ? a_attr.split(' ') : []}
          {@const b_attrs = b_attr ? b_attr.split(' ') : []}

          <tr class="term">
            <td class="dname">
              <a href="?dname={dname}">{dnames[dname] || dname}</a>
            </td>

            <td class="a_key">
              <a href="?a_key={a_key}">{a_key}</a>
            </td>

            <td class="b_key">
              <a href="?b_key={b_key}">{b_key}</a>
            </td>

            <td class="a_vstr">{a_vstr}</td>

            <td class="attr">
              {#each a_attrs as attr}
                <code>{attr}</code>
              {:else}
                <code>None</code>
              {/each}
            </td>

            <td class="b_vstr">{b_vstr || '-'}</td>

            <td class="attr">
              {#each b_attrs as attr}
                <code>{attr}</code>
              {:else}
                <code>None</code>
              {/each}
            </td>

            <td class="uname" class:_self={uname == $_user.uname}>
              <a href="?uname={uname}">{uname || '-'}</a>
            </td>

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

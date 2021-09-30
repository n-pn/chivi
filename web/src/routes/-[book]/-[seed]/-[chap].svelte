<script context="module">
  import { api_call, put_fetch } from '$api/_api_call'
  import { enabled as lookup_enabled } from '$parts/Lookup.svelte'

  export async function load({ fetch, page: { params }, context }) {
    const { cvbook, ubmemo } = context

    const { seed: sname, chap } = params
    const [chidx, cpart = 0] = chap.split('-').pop().split('.')

    const url = `chaps/${cvbook.id}/${sname}/${chidx}/${+cpart}`
    const [status, chinfo] = await api_call(fetch, url)
    if (status) return { status, error: chinfo }
    return { props: { cvbook, ubmemo, chinfo } }
  }
</script>

<script>
  import { browser } from '$app/env'
  import { session } from '$app/stores'
  import { invalidate } from '$app/navigation'

  import SIcon from '$atoms/SIcon.svelte'
  import CMenu from '$molds/CMenu.svelte'
  import Notext from '$parts/Notext.svelte'
  import Vessel from '$sects/Vessel.svelte'
  import Cvdata from '$sects/Cvdata.svelte'

  export let cvbook
  export let ubmemo
  export let chinfo

  let _dirty = false
  $: if (_dirty) reload_chap(false)

  $: [book_path, list_path, prev_path, next_path] = gen_paths(cvbook, chinfo)

  $: api_url = gen_api_url(cvbook, chinfo)

  function gen_api_url({ id: book_id }, { sname, chidx, cpart }) {
    return `/api/chaps/${book_id}/${sname}/${chidx}/${cpart}`
  }

  async function reload_chap(full = false) {
    _dirty = false
    if ($session.privi < 1) return

    if (full) {
      const res = await fetch(api_url + '?mode=2')
      if (res.ok) chinfo = await res.json()
    } else {
      const res = await fetch(api_url + '/text')
      if (res.ok) chinfo.cvdata = await res.text()
      else console.log(res.status)
    }
  }

  function gen_paths({ bslug }, { sname, chidx, _prev, _next }) {
    const book_path = gen_book_path(bslug, sname, 0)
    const list_path = gen_book_path(bslug, sname, chidx)

    const base_path = `/-${bslug}/-${sname}/`
    const prev_path = _prev ? `${base_path}-${_prev}` : book_path
    const next_path = _next ? `${base_path}-${_next}` : list_path

    return [book_path, list_path, prev_path, next_path]
  }

  function gen_book_path(bslug, sname, chidx) {
    let url = `/-${bslug}/-${sname}`
    const page = Math.floor((chidx - 1) / 32) + 1
    return page > 1 ? url + `?page=${page}` : url
  }

  $: on_memory = ubmemo.chidx == chinfo.chidx
  $: memo_icon = ubmemo.locked ? `bookmark${on_memory ? '' : '-off'}` : 'menu-2'

  $: if (browser && !on_memory) update_history(chinfo, false)

  async function update_history({ sname, chidx, title, uslug }, locking) {
    // console.log(ubmemo)

    // guard checking
    if ($session.privi < 0) {
      // do not save history unless logged in
      return
    } else if (ubmemo.chidx == chidx) {
      // do not save history if there is no change
      if (ubmemo.locked == locking) return
    } else {
      // do not save history if history is locked unless changing lock cursor
      if (ubmemo.locked && !locking) return
    }

    const url = `/api/_self/books/${cvbook.id}/access`
    const params = { sname, chidx, title, uslug, locked: locking }

    const [stt, msg] = await put_fetch(fetch, url, params)
    if (stt) return console.log(`Error update history: ${msg}`)

    // TODO: figure out how to update ubmemo instead of reloading book info everytime
    invalidate(`/api/books/${cvbook.bslug}`)

    ubmemo = msg
    // console.log(ubmemo)
  }
</script>

<svelte:head>
  <title>{chinfo.title} - {cvbook.vtitle} - Chivi</title>
</svelte:head>

<Vessel>
  <svelte:fragment slot="header-left">
    <a href={book_path} class="header-item _title">
      <SIcon name="book" />
      <span class="header-text _show-sm _title">{cvbook.vtitle}</span>
    </a>

    <button class="header-item _active">
      <span class="header-text _seed">[{chinfo.sname}]</span>
    </button>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <button
      class="header-item"
      class:_active={$lookup_enabled}
      on:click={() => lookup_enabled.update((x) => !x)}
      data-kbd="\">
      <SIcon name="compass" />
      <span class="header-text _show-lg">Giải nghĩa</span>
    </button>
  </svelte:fragment>

  <nav class="bread">
    <a href="/-{cvbook.bslug}" class="crumb _link">{cvbook.vtitle}</a>
    <span>/</span>
    <span class="crumb _text">{chinfo.chvol}</span>
  </nav>

  <article class="cvdata">
    {#if chinfo.cvdata}
      <Cvdata
        cvdata={chinfo.cvdata}
        zhtext={chinfo.zhtext}
        dname={cvbook.bhash}
        label={cvbook.vtitle}
        bind:_dirty />
    {:else}
      <Notext {chinfo} />
    {/if}
  </article>

  <div class="navi" slot="footer">
    <a
      href={prev_path}
      class="m-button navi-item"
      class:_disable={!chinfo._prev}
      data-kbd="j">
      <SIcon name="chevron-left" />
      <span>Trước</span>
    </a>

    <CMenu class="navi-item" loc="top">
      <div class="m-button" slot="trigger">
        <SIcon name={memo_icon} />
        <span>{chinfo.chidx}/{chinfo.total}</span>
      </div>

      <svelte:fragment slot="content">
        <button
          class="-item"
          disabled={$session.privi < 1}
          on:click={reload_chap}
          data-kbd="r">
          <SIcon name="rotate-clockwise" />
          <span>Dịch lại</span>
        </button>

        {#if chinfo.clink != '/'}
          <button
            class="-item"
            disabled={$session.privi < 1}
            on:click={() => reload_chap(true)}>
            <SIcon name="rotate-rectangle" />
            <span>Tải lại nguồn</span>
          </button>
        {/if}

        {#if on_memory && ubmemo.locked}
          <button
            class="-item"
            disabled={$session.privi < 0}
            on:click={() => update_history(chinfo, false)}
            data-kbd="p">
            <SIcon name="bookmark-off" />
            <span>Bỏ đánh dấu</span>
          </button>
        {:else}
          <button
            class="-item"
            disabled={$session.privi < 0}
            on:click={() => update_history(chinfo, true)}
            data-kbd="p">
            <SIcon name="bookmark" />
            <span>Đánh dấu</span>
          </button>
        {/if}

        <a href={list_path} class="-item" data-kbd="h">
          <SIcon name="list" />
          <span>Mục lục</span>
        </a>
      </svelte:fragment>
    </CMenu>

    <a
      href={next_path}
      class="m-button _fill navi-item"
      class:_primary={chinfo.next}
      data-kbd="k">
      <span>Kế tiếp</span>
      <SIcon name="chevron-right" />
    </a>
  </div>
</Vessel>

<style lang="scss">
  .navi {
    @include flex($center: horz, $gap: 0.5rem);
  }

  .bread {
    padding: var(--gutter-sm) 0;
    line-height: var(--lh-narrow);

    // @include flow();
    @include ftsize(sm);
    @include fgcolor(secd);
  }

  .crumb {
    // float: left;

    &._link {
      color: inherit;
      &:hover {
        @include fgcolor(primary, 5);
      }
    }
  }
</style>

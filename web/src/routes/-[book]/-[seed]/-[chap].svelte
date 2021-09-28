<script context="module">
  import { api_call, put_fetch } from '$api/_api_call'
  import { enabled as lookup_enabled } from '$parts/Lookup.svelte'

  export async function load({ fetch, page: { params }, context }) {
    const { cvbook, ubmemo } = context

    const { seed: sname, chap } = params
    const chidx = chap.split('-').pop()

    const url = `chaps/${cvbook.id}/${sname}/${chidx}`
    const [status, chinfo] = await api_call(fetch, url)
    if (status) return { status, error: chinfo }

    const txturl = `/api/${url}/${chinfo.schid}`

    const res = await fetch(txturl)
    const cvdata = await res.text()

    return {
      props: { cvbook, ubmemo, chinfo, txturl, cvdata },
    }
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

  export let txturl = ''
  export let cvdata = ''

  let _dirty = false
  $: if (_dirty) reload_chap(1)

  $: [book_path, list_path, prev_path, next_path] = gen_paths(cvbook, chinfo)

  let _reload = false

  async function reload_chap(mode = 1) {
    _dirty = false
    if ($session.privi < 1) return

    _reload = true
    const res = await fetch(txturl + '?mode=' + mode)
    if (res.ok) cvdata = await res.text()
    _reload = false
  }

  function gen_paths({ bslug }, { sname, chidx, prev_url, next_url }) {
    const book_path = gen_book_path(bslug, sname, 0)
    const list_path = gen_book_path(bslug, sname, chidx)

    const prev_path = prev_url ? `/-${bslug}/${prev_url}` : book_path
    const next_path = next_url ? `/-${bslug}/${next_url}` : list_path

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
    <span class="crumb _text">{chinfo.label}</span>
  </nav>

  <article class="cvdata">
    {#if cvdata}
      <Cvdata {cvdata} dname={cvbook.bhash} label={cvbook.vtitle} bind:_dirty />
    {:else}
      <Notext {chinfo} />
    {/if}
  </article>

  <div class="navi" slot="footer">
    <a
      href={prev_path}
      class="m-button navi-item"
      class:_disable={!chinfo.prev_url}
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
          <SIcon name="rotate-clockwise" spin={_reload} />
          <span>Dịch lại</span>
        </button>

        {#if chinfo.clink != '/'}
          <button
            class="-item"
            disabled={$session.privi < 1}
            on:click={() => reload_chap(2)}>
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
      class:_primary={chinfo.next_url}
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

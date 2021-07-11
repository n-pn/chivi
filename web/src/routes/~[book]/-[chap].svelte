<script context="module">
  import Cvdata, { toggle_lookup } from '$lib/layouts/Cvdata.svelte'
  import { state as upsert_state } from '$lib/widgets/Upsert.svelte'

  import { get_chinfo, get_chtext } from '$api/chtext_api'

  import {
    enabled as lookup_enabled,
    actived as lookup_actived,
    sticked as lookup_sticked,
  } from '$lib/widgets/Lookup.svelte'

  export async function load({ fetch, page: { params, query }, context }) {
    const { nvinfo } = context

    const [chidx, sname] = params.chap.split('-').reverse()
    const [snvid] = nvinfo.chseed[sname] || [nvinfo.bhash]
    if (!snvid) {
      return { status: 404, error: new Error('Nguồn truyện không tồn tại!') }
    }

    const chinfo = { sname, snvid, chidx }

    const mode = +query.get('mode') || 0
    const [err, data] = await get_chinfo(fetch, nvinfo.bhash, chinfo, mode)

    if (err) return { status: 404, error: new Error(data) }

    return {
      props: {
        ...data,
        nvinfo,
        dirty: mode < 0,
      },
    }
  }
</script>

<script>
  import { session } from '$app/stores'

  import SIcon from '$lib/blocks/SIcon.svelte'
  import Vessel from '$lib/layouts/Vessel.svelte'
  import Empty from './chaps/_empty.svelte'

  export let nvinfo = {}
  export let chinfo = {}

  export let cvdata = ''

  export let dirty = false
  $: if ($session.privi > 0 && dirty) reload_chap()

  $: [book_path, list_path, prev_path, next_path] = gen_paths(nvinfo, chinfo)

  // $: $lookup_enabled = false
  // $: $lookup_actived = false

  function handle_keypress(evt) {
    if (evt.ctrlKey) return
    if ($upsert_state > 0) return

    switch (evt.key) {
      case '\\':
      case 'x':
      case 'c':
      case 'v':
        break

      case 'h':
      case 'j':
      case 'k':
      case 'r':
        let elm = document.querySelector(`[data-kbd="${evt.key}"]`)
        if (elm) {
          evt.preventDefault()
          elm.click()
        }

        break
    }
  }

  let _reload = false
  async function reload_chap() {
    dirty = false

    _reload = true
    const [_, data] = await get_chtext(window.fetch, nvinfo.bhash, chinfo, 1)
    _reload = false

    cvdata = data
  }

  function gen_paths({ bslug }, { sname, chidx, prev_url, next_url }) {
    const book_path = gen_book_path(bslug, sname, 0)
    const list_path = gen_book_path(bslug, sname, chidx)

    const prev_path = prev_url ? `/~${bslug}/${prev_url}` : book_path
    const next_path = next_url ? `/~${bslug}/${next_url}` : list_path

    return [book_path, list_path, prev_path, next_path]
  }

  function gen_book_path(bslug, sname, chidx) {
    let url = `/~${bslug}/chaps?sname=${sname}`
    const page = Math.floor((chidx - 1) / 30) + 1
    return page > 1 ? url + `&page=${page}` : url
  }
</script>

<svelte:head>
  <title>{chinfo.title} - {nvinfo.btitle_vi} - Chivi</title>
</svelte:head>

<svelte:body on:keydown={handle_keypress} />

<Vessel shift={$lookup_enabled && $lookup_actived && $lookup_sticked}>
  <svelte:fragment slot="header-left">
    <a href={book_path} class="header-item _title">
      <SIcon name="book-open" />
      <span class="header-text _show-md _title">{nvinfo.btitle_vi}</span>
    </a>

    <button class="header-item _active">
      <span class="header-text _seed">[{chinfo.sname}]</span>
    </button>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <button
      class="header-item"
      disabled={$session.privi < 1}
      on:click={reload_chap}
      data-kbd="r">
      <SIcon name="refresh-ccw" spin={_reload} />
    </button>

    <button
      class="header-item"
      class:_active={$lookup_enabled}
      on:click={toggle_lookup}
      data-kbd="\">
      <SIcon name="compass" />
    </button>
  </svelte:fragment>

  <nav class="bread">
    <div class="-crumb _sep">
      <a href="/~{nvinfo.bslug}" class="-link"> {nvinfo.btitle_vi}</a>
    </div>

    <div class="-crumb"><span class="-text">{chinfo.label}</span></div>
  </nav>

  {#if cvdata}
    <Cvdata
      input={cvdata}
      bind:dirty
      dname={nvinfo.bhash}
      label={nvinfo.btitle_vi} />
  {:else}
    <Empty />
  {/if}

  <div class="footer" slot="footer">
    <a
      href={prev_path}
      class="m-button _solid"
      class:_disable={!chinfo.prev_url}
      data-kbd="j">
      <SIcon name="chevron-left" />
      <span>Trước</span>
    </a>

    <a href={list_path} class="m-button _solid" data-kbd="h">
      <SIcon name="list" />
      <span>{chinfo.chidx}/{chinfo.total}</span>
    </a>

    <a
      href={next_path}
      class="m-button _solid _primary"
      class:_disable={!chinfo.next_url}
      data-kbd="k">
      <span>Kế tiếp</span>
      <SIcon name="chevron-right" />
    </a>
  </div>
</Vessel>

<style lang="scss">
  .footer {
    width: 100%;
    padding: 0.5rem 0;
    @include flex($center: content);
    @include flex-gap($gap: 0.5rem, $child: ':global(*)');
  }

  .bread {
    padding: 0.5rem 0;
    line-height: 1.25rem;

    @include font-size(2);
    @include border($sides: bottom);

    @include tm-dark {
      @include bdcolor(neutral, 7);
    }

    .-crumb {
      display: inline;
      // float: left;
      @include fgcolor(neutral, 6);
      @include tm-dark {
        @include fgcolor(neutral, 5);
      }

      &._sep:after {
        content: ' > ';
      }
    }

    .-link {
      color: inherit;
      &:hover {
        @include fgcolor(primary, 6);
      }
    }
  }

  .m-button {
    @include tm-dark {
      @include fgcolor(neutral, 2);
      @include bgcolor(neutral, 7);

      &:hover {
        @include bgcolor(neutral, 6);
      }

      &._primary {
        @include bgcolor(primary, 7);

        &:hover {
          @include bgcolor(primary, 6);
        }
      }
    }
  }
</style>

<script context="module">
  import { get_chinfo, get_chtext } from '$api/chtext_api'
  import { enabled as lookup_enabled } from '$parts/Lookup.svelte'

  export async function load({ fetch, page, context }) {
    const { nvinfo } = context

    const [chidx, sname] = page.params.chap.split('-').reverse()
    const [snvid] = nvinfo.chseed[sname] || [nvinfo.bhash]
    if (!snvid)
      return { status: 404, error: new Error('Nguồn truyện không tồn tại!') }

    const chinfo = { sname, snvid, chidx }

    const mode = +page.query.get('mode') || 0
    const [err, data] = await get_chinfo(fetch, nvinfo.bhash, chinfo, mode)

    if (err) return { status: 404, error: new Error(data) }

    return {
      props: { ...data, nvinfo, _dirty: mode < 0 },
    }
  }
</script>

<script>
  import { session } from '$app/stores'

  import SIcon from '$atoms/SIcon.svelte'
  import Notext from '$parts/Notext.svelte'
  import Vessel from '$sects/Vessel.svelte'
  import Cvdata from '$sects/Cvdata.svelte'

  export let nvinfo = {}
  export let chinfo = {}

  export let cvdata = ''

  export let _dirty = false
  $: if (_dirty) reload_chap()

  $: [book_path, list_path, prev_path, next_path] = gen_paths(nvinfo, chinfo)

  let _reload = false

  async function reload_chap() {
    _dirty = false
    if ($session.privi < 1) return

    _reload = true
    const [err, data] = await get_chtext(window.fetch, nvinfo.bhash, chinfo, 1)
    if (!err) cvdata = data
    _reload = false
  }

  function gen_paths({ bslug }, { sname, chidx, prev_url, next_url }) {
    const book_path = gen_book_path(bslug, sname, 0)
    const list_path = gen_book_path(bslug, sname, chidx)

    const prev_path = prev_url ? `/~${bslug}/${prev_url}` : book_path
    const next_path = next_url ? `/~${bslug}/${next_url}` : list_path

    return [book_path, list_path, prev_path, next_path]
  }

  function gen_book_path(bslug, sname, chidx) {
    let url = `/~${bslug}/chaps/${sname}`
    const page = Math.floor((chidx - 1) / 32) + 1
    return page > 1 ? url + `?page=${page}` : url
  }
</script>

<svelte:head>
  <title>{chinfo.title} - {nvinfo.btitle_vi} - Chivi</title>
</svelte:head>

<Vessel>
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
      on:click={() => lookup_enabled.update((x) => !x)}
      data-kbd="\">
      <SIcon name="compass" />
    </button>
  </svelte:fragment>

  <nav class="bread">
    <a href="/~{nvinfo.bslug}" class="crumb _link">{nvinfo.btitle_vi}</a>
    <span>/</span>
    <span class="crumb _text">{chinfo.label}</span>
  </nav>

  {#if cvdata}
    <Cvdata
      {cvdata}
      dname={nvinfo.bhash}
      label={nvinfo.btitle_vi}
      bind:_dirty />
  {:else}
    <Notext {chinfo} />
  {/if}

  <div class="navi" slot="footer">
    <a
      href={prev_path}
      class="m-button"
      class:_disable={!chinfo.prev_url}
      data-kbd="j">
      <SIcon name="chevron-left" />
      <span>Trước</span>
    </a>

    <a href={list_path} class="m-button" data-kbd="h">
      <SIcon name="list" />
      <span>{chinfo.chidx}/{chinfo.total}</span>
    </a>

    <a
      href={next_path}
      class="m-button _fill"
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

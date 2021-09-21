<script context="module">
  import { api_call } from '$api/_api_call'
  import { enabled as lookup_enabled } from '$parts/Lookup.svelte'

  export async function load({ fetch, page, context: { cvbook } }) {
    const [chidx, sname] = page.params.chap.split('-').reverse()

    const url = `chaps/${cvbook.id}/${sname}/${chidx}`
    const [status, chinfo] = await api_call(fetch, url)
    if (status) return { status, error: chinfo }

    const mode = +page.query.get('mode') || 0
    const txturl = `/api/${url}/${chinfo.schid}`

    const res = await fetch(`${txturl}?mode=${mode}`)
    const cvdata = await res.text()

    return {
      props: { cvbook, chinfo, txturl, cvdata, _dirty: mode < 0 },
    }
  }
</script>

<script>
  import { session } from '$app/stores'

  import SIcon from '$atoms/SIcon.svelte'
  import Notext from '$parts/Notext.svelte'
  import Vessel from '$sects/Vessel.svelte'
  import Cvdata from '$sects/Cvdata.svelte'

  export let cvbook = {}
  export let chinfo = {}

  export let txturl = ''
  export let cvdata = ''

  export let _dirty = false
  $: if (_dirty) reload_chap()

  $: [book_path, list_path, prev_path, next_path] = gen_paths(cvbook, chinfo)

  let _reload = false

  async function reload_chap() {
    _dirty = false
    if ($session.privi < 1) return

    _reload = true
    const res = await fetch(txturl + '?mode=1')
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
    let url = `/-${bslug}/chaps/${sname}`
    const page = Math.floor((chidx - 1) / 32) + 1
    return page > 1 ? url + `?page=${page}` : url
  }
</script>

<svelte:head>
  <title>{chinfo.title} - {cvbook.btitle_vi} - Chivi</title>
</svelte:head>

<Vessel>
  <svelte:fragment slot="header-left">
    <a href={book_path} class="header-item _title">
      <SIcon name="book" />
      <span class="header-text _show-sm _title">{cvbook.btitle_vi}</span>
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
      <SIcon name="rotate-clockwise" spin={_reload} />
      <span class="header-text _show-lg">Dịch lại</span>
    </button>

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
    <a href="/-{cvbook.bslug}" class="crumb _link">{cvbook.btitle_vi}</a>
    <span>/</span>
    <span class="crumb _text">{chinfo.label}</span>
  </nav>

  <article class="cvdata">
    {#if cvdata}
      <Cvdata
        {cvdata}
        dname={cvbook.bhash}
        label={cvbook.btitle_vi}
        bind:_dirty />
    {:else}
      <Notext {chinfo} />
    {/if}
  </article>

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

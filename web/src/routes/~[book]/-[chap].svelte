<script context="module">
  import Cvdata, { toggle_lookup, active_upsert } from '$layout/Cvdata'
  import { active as upsert_active } from '$widget/Upsert'

  import { get_chinfo, get_chtext } from '$api/chtext_api'

  import {
    u_power,
    lookup_dname,
    lookup_enabled,
    lookup_actived,
  } from '$src/stores'

  export async function preload({ params, query }) {
    const bslug = params.book
    const [chidx, sname] = params.chap.split('-').reverse()
    const mode = +query.mode || process.browser ? 1 : 0

    const [err, data] = await get_chinfo(this.fetch, bslug, sname, chidx, mode)
    if (err) this.error(err, data)
    else return data
  }

  function gen_paths({ bslug, sname, chidx, prev_url, next_url }) {
    const book_path = gen_book_path(bslug, sname, 0)
    const list_path = gen_book_path(bslug, sname, chidx)

    const prev_path = prev_url || book_path
    const next_path = next_url || list_path

    return [book_path, list_path, prev_path, next_path]
  }

  function gen_book_path(bslug, sname, chidx) {
    let url = `/~${bslug}/content?sname=${sname}`
    const page = Math.floor(chidx / 30) + 1
    return page > 1 ? url + `&page=${page}` : url
  }
</script>

<script>
  import SIcon from '$blocks/SIcon'
  import Vessel from '$layout/Vessel'

  export let chinfo = {}
  export let cvdata = ''

  $: [book_path, list_path, prev_path, next_path] = gen_paths(chinfo)

  $: $lookup_dname = chinfo.bhash

  let changed = false
  $: if (changed) reload_chap(1)

  $: $lookup_enabled = false
  $: $lookup_actived = false

  function handle_keypress(evt) {
    if (evt.ctrlKey) return
    if ($upsert_active) return

    switch (evt.key) {
      case '\\':
        evt.preventDefault()
        toggle_lookup()
        break

      case 'x':
        evt.preventDefault()
        active_upsert(0)
        break

      case 'c':
        evt.preventDefault()
        active_upsert(1)
        break

      case 'v':
        evt.preventDefault()
        active_upsert(3)
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
      default:
        if (evt.keyCode == 13) {
          evt.preventDefault()
          active_upsert()
        }
    }
  }

  async function reload_chap(mode = 1) {
    if (mode > $u_power) mode = $u_power
    if (mode < 1) return

    const [_err, data] = await get_chtext(window.fetch, chinfo, mode)
    cvdata = data
    changed = false
  }
</script>

<svelte:head>
  <title>{chinfo.title} - {chinfo.bname} - Chivi</title>
</svelte:head>

<svelte:body on:keydown={handle_keypress} />

<Vessel shift={$lookup_enabled && $lookup_actived}>
  <a slot="header-left" href={book_path} class="header-item _title">
    <SIcon name="book-open" />
    <span class="header-text _show-md _title">{chinfo.sname}</span>
  </a>

  <button slot="header-left" class="header-item _active">
    <span class="header-text _seed">[{chinfo.sname}]</span>
  </button>

  <button
    slot="header-right"
    class="header-item"
    disabled={$u_power < 1}
    on:click={() => (changed = true)}
    data-kbd="r">
    <SIcon name="refresh-ccw" spin={changed} />
  </button>

  <button
    slot="header-right"
    class="header-item"
    class:_active={$lookup_enabled}
    on:click={toggle_lookup}
    data-kbd="\">
    <SIcon name="compass" />
  </button>

  <nav class="bread">
    <div class="-crumb _sep">
      <a href="/~{chinfo.bslug}" class="-link"> {chinfo.bname}</a>
    </div>

    <div class="-crumb"><span class="-text">{chinfo.label}</span></div>
  </nav>

  {#if cvdata}
    <Cvdata {cvdata} bind:changed dname={chinfo.bhash} bname={chinfo.bname} />
  {:else}
    <div class="empty">
      Chương tiết không có nội dung, mời liên hệ ban quản trị.
    </div>
  {/if}

  <div slot="footer" class="footer">
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

    .-crumb {
      display: inline;
      // float: left;
      @include fgcolor(neutral, 6);

      &._sep:after {
        content: '>';
        @include fgcolor(neutral, 5);
        padding: 0 0.25rem;
      }
    }

    .-link {
      color: inherit;
      &:hover {
        @include fgcolor(primary, 6);
      }
    }

    :global(svg) {
      margin-top: -0.25rem;
    }
  }

  .empty {
    height: 70vh;

    font-style: italic;
    @include flex($center: both);
    @include fgcolor(neutral, 6);
    @include font-size(4);
  }
</style>

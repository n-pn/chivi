<script context="module">
  import SvgIcon from '$atoms/SvgIcon'

  import Vessel from '$parts/Vessel'
  import Convert, { toggle_lookup, active_upsert } from '$parts/Convert'

  import { get_chinfo, get_chtext } from '$utils/api_calls'

  import {
    self_power,
    upsert_dicts,
    lookup_dname,
    upsert_actived,
    lookup_enabled,
    lookup_actived,
  } from '$src/stores'

  export async function preload({ params }) {
    const bslug = params.book

    const cols = params.chap.split('-')
    const seed = cols[cols.length - 2]
    const scid = cols[cols.length - 1]

    const [ok, data] = await get_chinfo(this.fetch, bslug, seed, scid)

    if (ok) return data
    else this.error(data.status, data.message)
  }

  function gen_paths({ bslug, seed, ch_index, prev_url, next_url }) {
    const book_path = gen_book_path(bslug, seed, 0)
    const list_path = gen_book_path(bslug, seed, ch_index)

    const prev_path = prev_url || book_path
    const next_path = next_url || list_path

    return [book_path, list_path, prev_path, next_path]
  }

  function gen_book_path(bslug, seed, index) {
    let url = `/~${bslug}/content?seed=${seed}`
    const page = Math.floor(index / 30) + 1
    return page > 1 ? url + `&page=${page}` : url
  }
</script>

<script>
  export let chinfo = {}
  export let cvdata = ''

  $: [book_path, list_path, prev_path, next_path] = gen_paths(chinfo)

  $: $upsert_dicts = [
    [chinfo.bhash, chinfo.bname, true],
    ['generic', 'Thông dụng'],
    ['hanviet', 'Hán việt'],
  ]
  $: $lookup_dname = chinfo.bhash

  let dirty = false
  $: if (dirty) reload_chap(1)

  $: $lookup_enabled = false
  $: $lookup_actived = false

  function handle_keypress(evt) {
    if (evt.ctrlKey) return
    if ($upsert_actived) return

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
    if (mode > $self_power) mode = $self_power
    if (mode < 1) return

    const [ok, data] = await get_chtext(window.fetch, chinfo, mode)
    cvdata = ok ? data.cvdata : data.message
    dirty = false
  }
</script>

<svelte:head>
  <title>{chinfo.title} - {chinfo.bname} - Chivi</title>
</svelte:head>

<svelte:body on:keydown={handle_keypress} />

<Vessel shift={$lookup_enabled && $lookup_actived}>
  <a slot="header-left" href={book_path} class="header-item _title">
    <SvgIcon name="book-open" />
    <span class="header-text _show-md _title">{chinfo.bname}</span>
  </a>

  <button slot="header-left" class="header-item _active">
    <span class="header-text _seed">[{chinfo.seed}]</span>
  </button>

  <button
    slot="header-right"
    class="header-item"
    disabled={$self_power < 1}
    on:click={() => (dirty = true)}
    data-kbd="r">
    <SvgIcon name="refresh-ccw" spin={dirty} />
  </button>

  <button
    slot="header-right"
    class="header-item"
    class:_active={$lookup_enabled}
    on:click={toggle_lookup}
    data-kbd="\">
    <SvgIcon name="compass" />
  </button>

  <nav class="bread">
    <div class="-crumb _sep">
      <a href="/~{chinfo.bslug}" class="-link"> {chinfo.bname}</a>
    </div>

    <div class="-crumb"><span class="-text">{chinfo.label}</span></div>
  </nav>

  {#if cvdata}
    <Convert input={cvdata} bind:dirty />
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
      <SvgIcon name="chevron-left" />
      <span>Trước</span>
    </a>

    <a href={list_path} class="m-button _solid">
      <SvgIcon name="list" />
      <span>{chinfo.ch_index}/{chinfo.ch_total}</span>
    </a>

    <a
      href={next_path}
      class="m-button _solid _primary"
      class:_disable={!chinfo.next_url}
      data-kbd="k">
      <span>Kế tiếp</span>
      <SvgIcon name="chevron-right" />
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

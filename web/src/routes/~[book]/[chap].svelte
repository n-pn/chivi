<script context="module">
  export async function preload({ params, query }) {
    const bslug = params.book

    const cols = params.chap.split('-')
    const seed = cols[cols.length - 2]
    const scid = cols[cols.length - 1]

    const mode = +query.mode || 0
    const data = await load_chap(this.fetch, bslug, seed, scid, mode)

    return data
  }

  async function load_chap(fetch, bslug, seed, scid, mode = 0) {
    const url = `/_texts/${bslug}/${seed}/${scid}?mode=${mode}`

    try {
      const res = await fetch(url)
      const data = await res.json()

      if (res.status == 200) return data
      else this.error(res.status, data._msg)
    } catch (err) {
      this.error(500, err.message)
    }
  }

  import SvgIcon from '$atoms/SvgIcon'
  import RelTime from '$atoms/RelTime'

  import Vessel from '$parts/Vessel'
  import Convert, { toggle_lookup, active_upsert } from '$parts/Convert'

  import {
    // self_uname,
    self_power,
    upsert_dicts,
    lookup_dname,
    upsert_actived,
    lookup_enabled,
    lookup_actived,
  } from '$src/stores'
</script>

<script>
  export let bslug = ''
  export let bname = ''

  export let ubid = ''
  export let seed = ''
  export let scid = ''

  export let mftime = 0
  export let cvdata = ''

  export let ch_total = 1
  export let ch_index = 1

  export let ch_title = ''
  export let ch_label = ''

  export let curr_url = ''
  export let prev_url = ''
  export let next_url = ''

  $: book_path = `/~${bslug}?tab=content&seed=${seed}`
  // $: curr_path = `/~${bslug}/${curr_url}`
  $: prev_path = prev_url ? `/~${bslug}/${prev_url}` : book_path
  $: next_path = next_url ? `/~${bslug}/${next_url}` : book_path

  $: $upsert_dicts = [
    [ubid, bname, true],
    ['generic', 'Thông dụng'],
    ['hanviet', 'Hán việt'],
  ]
  $: $lookup_dname = ubid

  let dirty = false
  $: if (dirty) reload_chap(1)

  $: $lookup_enabled = false
  $: $lookup_actived = false

  function handle_keypress(evt) {
    if ($upsert_actived) return
    if (evt.ctrlKey) return

    switch (evt.key) {
      case '\\':
        toggle_lookup()
        break

      case 'x':
        active_upsert(0)
        break

      case 'c':
        active_upsert(1)
        break

      case 'h':
      case 'j':
      case 'k':
      case 'r':
        let elm = document.querySelector(`[data-kbd="${evt.key}"]`)
        if (elm) {
          evt.stopPropagation()
          elm.click()
        }

        break
    }
  }

  let _load = false
  async function reload_chap(mode = 1) {
    if ($self_power < 1) return

    _load = true
    const data = await load_chap(window.fetch, bslug, seed, scid, mode)

    mftime = data.mftime
    cvdata = data.cvdata

    dirty = false
    _load = false
  }
</script>

<svelte:head>
  <title>{ch_title} - {bname} - Chivi</title>
  <meta property="og:url" content="{bslug}/{curr_url}" />
</svelte:head>

<svelte:body on:keydown={handle_keypress} />

<Vessel shift={$lookup_enabled && $lookup_actived}>
  <a
    slot="header-left"
    href={book_path}
    class="header-item _title"
    rel="external">
    <SvgIcon name="book-open" />
    <span class="header-text _show-sm _title">{bname}</span>
  </a>

  <span slot="header-left" class="header-item _active">
    <span class="header-text">{ch_index}</span>
    <span class="header-text _show-md">/{ch_total}</span>
  </span>

  <button
    slot="header-right"
    type="button"
    class="header-item"
    disabled={$self_power < 1}
    on:click={() => reload_chap(1)}
    data-kbd="r">
    <SvgIcon name="refresh-ccw" spin={_load} />
  </button>

  <button
    slot="header-right"
    type="button"
    class="header-item"
    class:_active={$upsert_actived}
    on:click={() => active_upsert(0)}
    data-kbd="x">
    <SvgIcon name="plus-circle" />
  </button>

  <button
    slot="header-right"
    type="button"
    class="header-item"
    class:_active={$lookup_enabled}
    on:click={toggle_lookup}
    data-kbd="\">
    <SvgIcon name="compass" />
  </button>

  <nav class="bread">
    <div class="-crumb _sep">
      <a href="/" class="-link" rel="external"><SvgIcon name="home" /></a>
    </div>

    <div class="-crumb _sep">
      <a href="/~{bslug}" class="-link" rel="external">{bname}</a>
    </div>

    <div class="-crumb _sep">
      <a href={book_path} class="-link" rel="external">[{seed}]</a>
    </div>

    <div class="-crumb"><span class="-text">{ch_label}</span></div>

    <div class="-right">
      <span><RelTime time={mftime} /></span>
    </div>
  </nav>

  <Convert input={cvdata} bind:dirty />

  <footer class="footer">
    {#if prev_url}
      <a
        href={prev_path}
        class="m-button _line"
        class:_disable={!prev_url}
        rel="external"
        data-kbd="j">
        <SvgIcon name="chevron-left" />
        <span>Trước</span>
      </a>
    {/if}

    <a href={book_path} class="m-button _line" rel="external" data-kbd="h">
      <SvgIcon name="list" />
      <span>Mục lục</span>
    </a>

    <a
      href={next_path}
      class="m-button _line _primary"
      class:_disable={!next_url}
      rel="external"
      data-kbd="k">
      <span>Kế tiếp</span>
      <SvgIcon name="chevron-right" />
    </a>
  </footer>
</Vessel>

<style lang="scss">
  .footer {
    margin: 0.75rem 0 1.75rem;
    @include flex($gap: 0.375rem);
    justify-content: center;
  }

  .bread {
    // display: flex;
    // flex-wrap: wrap;

    padding: 0.5rem 0;
    line-height: 1.25rem;

    @include font-size(2);
    @include border($sides: bottom);
    @include clearfix;

    .-crumb {
      float: left;
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

    .-right {
      float: right;
      // margin-left: auto;
      font-style: italic;
      @include fgcolor(neutral, 5);
    }

    :global(svg) {
      margin-top: -0.25rem;
    }
  }
</style>

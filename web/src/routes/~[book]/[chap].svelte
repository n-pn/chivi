<script context="module">
  export async function preload({ params, query }) {
    const bslug = params.book

    const cols = params.chap.split('-')
    const seed = cols[cols.length - 2]
    const scid = cols[cols.length - 1]

    const mode = +query.mode || 0
    const data = await load_chtext(this.fetch, bslug, seed, scid, mode)

    return data
  }

  async function load_chtext(fetch, bslug, seed, scid, mode = 0) {
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

  import MDiglot, { parse as parse_vp_input } from '$melds/MDiglot'
  import UpsertModal, { dict_upsert } from '$melds/UpsertModal'
  import LookupPanel from '$melds/LookupPanel'

  import Vessel from '$parts/Vessel'

  import read_selection from '$utils/read_selection'

  import {
    // self_uname,
    self_power,
    upsert_input,
    upsert_dicts,
    upsert_d_idx,
    upsert_actived,
    lookup_dname,
    lookup_actived,
  } from '$src/stores'

  function make_ads_index(limit = 1, max = 15, min = 5) {
    const res = []
    let idx = 0

    while (idx < limit) {
      idx += random_int(max, min)
      res.push(idx)
    }

    return res
  }

  function random_int(max = 15, min = 5) {
    return Math.floor(Math.random() * (max - min)) + min
  }

  let view_count = 0
  let older_chap = ''
  let anchor_rel = ''
</script>

<script>
  import { onMount } from 'svelte'
  import AdBanner from '$atoms/AdBanner'

  export let bslug = ''
  export let bname = ''

  export let ubid = ''
  export let seed = ''
  export let scid = ''

  export let mftime = 0
  export let cvdata = ''

  $: if (scid != older_chap) {
    older_chap = scid
    if (view_count++ >= 4) anchor_rel = 'external'
    // console.log({ older_chap, anchor_rel })
  }

  $: cvlines = cvdata.split('\n').map((x) => parse_vp_input(x))
  $: ads_idx = make_ads_index(cvlines.length)

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

  $: power_user = $self_power > 0

  $: $upsert_dicts = [
    [ubid, bname, true],
    ['generic', 'Thông dụng'],
    ['hanviet', 'Hán việt'],
  ]

  $: $lookup_dname = ubid

  let dirty = false
  $: if (dirty) reload_content(1)

  let line_hover = 0
  let line_focus = 0
  let cursor

  let lookup_enabled = false

  function handle_keypress(evt) {
    if ($upsert_actived) return
    if (evt.ctrlKey) return

    switch (evt.key) {
      case '\\':
        trigger_lookup()
        break

      case 'h':
      case 'j':
      case 'k':
      case 'r':
      case 'x':
        let elm = document.querySelector(`[data-kbd="${evt.key}"]`)
        if (elm) {
          evt.preventDefault()
          elm.click()
        }

        break

      case 'c':
        show_upsert_modal(1)
        break

      default:
        if (evt.keyCode == 13) show_upsert_modal()
        else if (evt.keycode == 46 && evt.shiftKey) deleteFocusedWord()
    }
  }

  async function deleteFocusedWord() {
    if (!focused_elem || $self_power < 1) return

    const dic = +focused_elem.dataset.d == 3 ? ubid : 'generic'
    const key = focused_elem.dataset.k

    const res = await dict_upsert(fetch, dic, key, '')
    dirty = res.ok
  }

  onMount(() => {
    const evt = document.addEventListener('selectionchange', () => {
      const input = read_selection()
      if (input) {
        $upsert_input = input
        $upsert_d_idx = 0
      }
    })

    return () => document.removeEventListener('selectionchange', evt)
  })

  function trigger_lookup() {
    lookup_enabled = !lookup_enabled
    lookup_actived.set(lookup_enabled)
  }

  function show_upsert_modal(new_tab = null) {
    upsert_d_idx.update((x) => new_tab || x)
    upsert_actived.set(true)
  }

  let _load = false
  async function reload_content(mode = 1) {
    if (!power_user) return

    _load = true
    const data = await load_chtext(window.fetch, bslug, seed, scid, mode)

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

<Vessel shift={lookup_enabled && $lookup_actived}>
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
    disabled={!power_user}
    on:click={() => reload_content(1)}
    data-kbd="r">
    <SvgIcon name="refresh-ccw" spin={_load} />
  </button>

  <button
    slot="header-right"
    type="button"
    class="header-item"
    class:_active={$upsert_actived}
    on:click={() => show_upsert_modal(0)}
    data-kbd="x">
    <SvgIcon name="plus-circle" />
  </button>

  <button
    slot="header-right"
    type="button"
    class="header-item"
    class:_active={lookup_enabled}
    on:click={trigger_lookup}
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

  <article class="convert" class:_load>
    {#each cvlines as nodes, index (index)}
      {#if ads_idx.includes(index)}
        <AdBanner type="in-article" />
      {/if}

      {#if index == 0}
        <h1>
          <MDiglot
            {nodes}
            {index}
            bind:focus={line_focus}
            bind:cursor
            bind:hover={line_hover} />
        </h1>
      {:else}
        <p>
          <MDiglot
            {nodes}
            {index}
            bind:focus={line_focus}
            bind:cursor
            bind:hover={line_hover} />
        </p>
      {/if}
    {/each}
  </article>

  <footer class="footer">
    {#if prev_url}
      <a
        href={prev_path}
        class="m-button _line"
        class:_disable={!prev_url}
        rel={anchor_rel}
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
      rel={anchor_rel}
      data-kbd="k">
      <span>Kế tiếp</span>
      <SvgIcon name="chevron-right" />
    </a>
  </footer>

  {#if lookup_enabled}
    <LookupPanel on_top={!$upsert_actived} />
  {/if}

  {#if $upsert_actived}
    <UpsertModal bind:dirty />
  {/if}
</Vessel>

<style lang="scss">
  article {
    padding: 0.75rem 0;
    word-wrap: break-word;

    // &._load {
    //   @include fgcolor(neutral, 6);
    // }

    :global(cite) {
      text-transform: capitalize;
      font-style: normal;
      // font-variant: small-caps;
    }

    h1 {
      font-weight: 300;
      @include fgcolor(neutral, 9);

      $font-sizes: screen-vals(
        rem(24px),
        rem(25px),
        rem(26px),
        rem(28px),
        rem(30px)
      );
      $line-heights: screen-vals(1.75rem, 1.875rem, 2rem, 2.25rem, 2.5rem);

      @include apply(font-size, $font-sizes);
      @include apply(line-height, $line-heights);
    }

    p,
    > :global(section) {
      $margin-tops: screen-vals(1rem, 1.125rem, 1.25rem, 1.375rem, 1.5rem);
      @include apply(margin-top, $margin-tops);
    }

    p {
      text-align: justify;
      text-justify: auto;

      $font-sizes: screen-vals(
        rem(18px),
        rem(19px),
        rem(20px),
        rem(21px),
        rem(22px)
      );
      @include apply(font-size, $font-sizes);
    }
  }

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

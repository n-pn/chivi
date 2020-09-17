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
</script>

<script>
  import { onMount } from 'svelte'

  import AIcon from '$atoms/AIcon'
  import ARtime from '$atoms/ARtime'

  import Vessel from '$parts/Vessel'
  import Clavis from '$parts/Clavis'
  import Upsert, { dict_upsert } from '$parts/Upsert'

  import read_selection from '$utils/read_selection'
  import { render_convert, parse_content } from '$utils/render_convert'

  import {
    self_uname,
    self_power,
    upsert_input,
    upsert_lower,
    upsert_upper,
    upsert_atab,
    upsert_udic,
    upsert_actived,
    upsert_changed,
  } from '$src/stores'

  export let bslug = ''
  export let bname = ''

  export let ubid = ''
  export let seed = ''
  export let scid = ''

  export let mftime = 0
  export let cvdata = ''
  $: [vp_data, zh_data] = parse_content(cvdata)

  export let ch_total = 1
  export let ch_index = 1

  export let ch_title = ''
  export let ch_label = ''

  export let curr_url = ''
  export let prev_url = ''
  export let next_url = ''

  $: book_path = `/~${bslug}?tab=content&seed=${seed}`
  $: curr_path = `/~${bslug}/${curr_url}`
  $: prev_path = prev_url ? `/~${bslug}/${prev_url}` : book_path
  $: next_path = next_url ? `/~${bslug}/${next_url}` : book_path

  $: $upsert_udic = ubid
  $: if ($upsert_changed) reconvert(1)

  let hovered_line = 0
  let focused_line = 0

  let focused_elem = null

  let clavis_enabled = false
  let clavis_actived = false
  let clavis_line = ''
  let clavis_from = 0

  function handleKeypress(evt) {
    if ($upsert_actived) return
    if (evt.ctrlKey) return

    // if (!evt.altKey) return

    switch (evt.keyCode) {
      case 220:
        triggerClavisSidebar()
        break

      case 72:
        evt.preventDefault()
        _goto(book_path)
        break

      // case 37:
      case 74:
        if (!evt.altKey) {
          evt.preventDefault()
          _goto(prev_path)
        }
        break

      // case 39:
      case 75:
        if (!evt.altKey) {
          evt.preventDefault()
          _goto(next_path)
        }
        break

      case 46:
        evt.preventDefault()
        if (evt.shiftKey) deleteFocusedWord()
        break

      case 13:
      case 90:
        evt.preventDefault()
        show_upsert_modal()
        break

      case 88:
        evt.preventDefault()
        show_upsert_modal('special')
        break

      case 67:
        evt.preventDefault()
        show_upsert_modal('generic')
        break

      case 82:
        if ($self_power > 0) {
          evt.preventDefault()
          reconvert(1)
        }

        break

      default:
        break
    }
  }

  async function deleteFocusedWord() {
    if (!focused_elem || $self_power < 1) return

    const dic = +focused_elem.dataset.d == 3 ? ubid : 'generic'
    const key = focused_elem.dataset.k

    const res = await dict_upsert(fetch, dic, key, '')
    should_reload = res == 'ok'
  }

  onMount(() => {
    const evt = document.addEventListener('selectionchange', () => {
      const [input, lower, upper] = read_selection()
      if (input) {
        $upsert_input = input
        $upsert_lower = lower
        $upsert_upper = upper
        $upsert_atab = 'special'
      }
    })

    return () => {
      document.removeEventListener('selectionchange', evt)
    }
  })

  function truncate_line(input, lower, length = 1) {
    if (lower >= 4) {
      const caret = lower - 4
      input = input.substr(caret, length + 10)
      lower = 4
    } else {
      input = input.substr(0, length + 10)
    }

    return [input, lower]
  }

  function handle_click({ target }, idx) {
    if (target.nodeName !== 'X-V') return

    const zh_line = zh_data[idx]

    // TODO: import from target

    if (target === focused_elem) {
      const key = target.dataset.k
      const pos = +target.dataset.p
      const dic = +target.dataset.d

      const [input, lower] = truncate_line(zh_line, pos, key.length)

      $upsert_input = input
      $upsert_lower = lower
      $upsert_upper = lower + key.length

      $upsert_atab = dic > 2 ? 'special' : 'generic'
      $upsert_actived = true

      return
    }

    if (focused_elem) focused_elem.classList.remove('_active')

    focused_line = idx
    focused_elem = target
    focused_elem.classList.add('_active')

    clavis_line = zh_line
    clavis_from = +focused_elem.dataset.p
    if (clavis_enabled) clavis_actived = true
  }

  function triggerClavisSidebar() {
    clavis_enabled = !clavis_enabled
    clavis_actived = clavis_enabled
  }

  function render_mode(idx, hover, focus) {
    if (idx == focus || idx == hover) return 2
    return 1
    // if (idx < hover - 5) return 1
    // if (idx > hover + 5) return 1
    // return 2
  }

  // $: console.log({ upsert_key, upsert_tab })

  function show_upsert_modal(new_tab = null) {
    upsert_atab.update((atab) => new_tab || atab)
    $upsert_actived = true
  }

  let _reloading = false
  async function reconvert(mode = 1) {
    // console.log(`reloading page with mode: ${mode}`)

    _reloading = true
    const data = await load_chtext(window.fetch, bslug, seed, scid, mode)

    $upsert_changed = false
    mftime = data.mftime
    cvdata = data.cvdata
    _reloading = false
  }
</script>

<svelte:head>
  <title>{ch_title} - {bname} - Chivi</title>
  <meta property="og:url" content="{bslug}/{curr_url}" />
</svelte:head>

<svelte:window on:keydown={handleKeypress} />

<Vessel shift={clavis_actived}>
  <a slot="header-left" href={book_path} class="header-item _title">
    <AIcon name="book-open" />
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
    on:click={() => reconvert(1)}>
    <AIcon name="refresh-ccw" spin={_reloading} />
  </button>

  <button
    slot="header-right"
    type="button"
    class="header-item"
    class:_active={$upsert_actived}
    on:click={() => show_upsert_modal()}>
    <AIcon name="plus-circle" />
  </button>

  <button
    slot="header-right"
    type="button"
    class="header-item"
    class:_active={clavis_enabled}
    on:click={triggerClavisSidebar}>
    <AIcon name="compass" />
  </button>

  <nav class="bread">
    <div class="-crumb _sep"><a href="/" class="-link">Chivi</a></div>

    <div class="-crumb _sep"><a href="/~{bslug}" class="-link">{bname}</a></div>

    <div class="-crumb _sep">
      <a href={book_path} class="-link">[{seed}]</a>
    </div>

    <div class="-crumb"><span class="-text">{ch_label}</span></div>

    <div class="-right">
      <span><ARtime time={mftime} /></span>
    </div>
  </nav>

  <article class="convert" class:_reload={_reloading}>
    {#each vp_data as data, idx}
      <p
        class="line"
        class:_head={idx == 0}
        class:_para={idx != 0}
        class:_focus={idx == focused_line}
        class:_hover={idx == hovered_line}
        on:mouseenter={() => (hovered_line = idx)}
        on:click={(event) => handle_click(event, idx)}>
        {@html render_convert(data, render_mode(idx, hovered_line, focused_line))}
      </p>
    {/each}
  </article>

  <footer class="footer">
    {#if prev_url}
      <a class="m-button _line" class:_disable={!prev_url} href={prev_path}>
        <AIcon name="chevron-left" />
        <span>Trước</span>
      </a>
    {/if}

    <a class="m-button _line" href={book_path}>
      <AIcon name="list" />
      <span>Mục lục</span>
    </a>

    <a
      class="m-button _line _primary"
      class:_disable={!next_url}
      href={next_path}>
      <span>Kế tiếp</span>
      <AIcon name="chevron-right" />
    </a>
  </footer>

  {#if clavis_enabled}
    <Clavis
      on_top={!upsert_actived}
      bind:active={clavis_actived}
      input={clavis_line}
      dname={ubid}
      from={clavis_from} />
  {/if}

  <Upsert />
</Vessel>

<style lang="scss">
  .convert {
    padding: 0.75rem 0;
    word-wrap: break-word;

    // &._reload {
    //   @include fgcolor(neutral, 6);
    // }

    .line {
      &._head {
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

      &._para {
        $font-sizes: screen-vals(
          rem(18px),
          rem(19px),
          rem(20px),
          rem(21px),
          rem(22px)
        );
        $margin-tops: screen-vals(1rem, 1.125rem, 1.25rem, 1.375rem, 1.5rem);

        text-align: justify;
        text-justify: auto;

        @include apply(font-size, $font-sizes);
        @include apply(margin-top, $margin-tops);
      }
    }

    :global(cite) {
      text-transform: capitalize;
      font-style: normal;
      // font-variant: small-caps;
    }
  }

  .footer {
    margin: 0.75rem 0 1.75rem;
    @include flex($gap: 0.375rem);
    justify-content: center;
  }

  @mixin token($color: blue) {
    &._active,
    &:hover {
      @include fgcolor($color, 6);
    }

    ._hover & {
      @include border($color: $color, $shade: 3, $sides: bottom);
    }
  }

  :global(x-v) {
    cursor: pointer;
    position: relative;

    &[data-d='1'] {
      @include token(teal);
    }

    &[data-d='2'] {
      @include token(blue);
    }

    &[data-d='3'] {
      @include token(green);
    }

    &[data-d='9'] {
      @include token(gray);
    }

    // .line > &._active {
    //   &:before {
    //     position: absolute;
    //     display: inline-block;
    //     content: attr(data-k);

    //     left: 0;
    //     top: -1.5em;
    //     width: 100%;
    //     text-align: center;
    //     overflow: hidden;

    //     font-size: 0.75em;
    //     line-height: 1.5em;
    //     font-style: normal;

    //     @include radius();
    //     @include fgcolor(neutral, 2);
    //     @include bgcolor(neutral, 7);
    //   }
    // }
  }

  .bread {
    // display: flex;
    // flex-wrap: wrap;

    margin: 0.375rem 0;
    line-height: 1.5rem;
    padding-bottom: 0.375rem;

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
  }
</style>

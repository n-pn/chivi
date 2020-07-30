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
</script>

<script>
  import { onMount } from 'svelte'

  import MIcon from '$mould/MIcon.svelte'
  import Vessel from '$layout/Vessel.svelte'
  import Clavis from '$layout/Clavis.svelte'
  import Upsert from '$layout/Upsert.svelte'

  import relative_time from '$utils/relative_time'
  import read_selection from '$utils/read_selection'
  import { render_convert, parse_content } from '$utils/render_convert'

  import { user } from '$src/stores'
  import { dict_upsert, load_chtext } from '$src/api'

  export let bslug = ''
  export let bname = ''

  export let ubid = ''
  export let seed = ''
  export let scid = ''

  export let mftime = 0
  export let cvdata = ''
  $: lines = parse_content(cvdata)

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

  let hovered_line = 0
  let focused_line = 0

  let focused_elem = null

  let clavis_enabled = false
  let clavis_actived = false
  let clavis_line = ''
  let clavis_from = 0

  let upsert_actived = false
  let upsert_key = ''
  let upsert_tab = 'special'

  let should_reload = false
  $: if (should_reload) reconvert(1)

  function handleKeypress(evt) {
    if (upsert_actived) return
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
        showUpsertModal()
        break

      case 88:
        evt.preventDefault()
        showUpsertModal('special')
        break

      case 67:
        evt.preventDefault()
        showUpsertModal('generic')
        break

      case 82:
        if ($user.power > 0) {
          evt.preventDefault()
          reconvert(1)
        }

        break

      default:
        break
    }
  }

  async function deleteFocusedWord() {
    if (!focused_elem || $user.power < 1) return

    const dic = +focused_elem.dataset.d == 3 ? ubid : 'generic'
    const key = focused_elem.dataset.k

    const res = await dict_upsert(fetch, dic, key, '')
    should_reload = res == 'ok'
  }

  function handleClick(evt, idx) {
    const target = evt.target
    if (target === focused_elem) return showUpsertModal()

    if (target.nodeName !== 'X-V') return
    if (focused_elem) focused_elem.classList.remove('_active')

    focused_line = idx
    clavis_line = lines[idx].map((x) => x[0]).join('')

    focused_elem = target
    focused_elem.classList.add('_active')

    clavis_from = +focused_elem.dataset['p']
    if (clavis_enabled) clavis_actived = true
  }

  function triggerClavisSidebar() {
    clavis_enabled = !clavis_enabled
    clavis_actived = clavis_enabled
  }

  function renderMode(idx, hover, focus) {
    if (idx == focus || idx == hover) return 2
    return 1
    // if (idx < hover - 5) return 1
    // if (idx > hover + 5) return 1
    // return 2
  }

  function showUpsertModal(tab = null) {
    const selection = read_selection()

    if (selection !== '') upsert_key = selection
    else if (focused_elem) {
      upsert_key = focused_elem.dataset.k

      if (tab == null) {
        const dic = +focused_elem.dataset.d
        tab = dic === 3 ? 'special' : 'generic'
      }
    }

    upsert_tab = tab || 'special'
    upsert_actived = true
  }

  let __reloading = false
  async function reconvert(mode = 1) {
    // console.log(`reloading page with mode: ${mode}`)

    __reloading = true
    const data = await load_chtext(window.fetch, bslug, seed, scid, mode)

    should_reload = false
    mftime = data.mftime
    cvdata = data.cvdata
    __reloading = false
  }
</script>

<style lang="scss">
  .convert {
    padding: 0.75rem 0;
    word-wrap: break-word;

    &._reload {
      @include fgcolor(neutral, 6);
    }

    .line {
      &._head {
        font-weight: 300;
        @include fgcolor(neutral, 9);

        $font-sizes: screen-vals(
          rem(22px),
          rem(24px),
          rem(26px),
          rem(28px),
          rem(30px)
        );
        $line-heights: screen-vals(1.5rem, 1.75rem, 2rem, 2.25rem, 2.5rem);

        @include apply(font-size, $font-sizes);
        @include apply(line-height, $line-heights);
      }

      &._para {
        $font-sizes: screen-vals(
          rem(16px),
          rem(17px),
          rem(18px),
          rem(19px),
          rem(20px)
        );
        $margin-tops: screen-vals(1rem, 1rem, 1.25rem, 1.5rem, 1.5rem);

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
    margin: 0.75rem 0;
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

    &[data-d='1'] {
      @include token(teal);
    }

    &[data-d='2'] {
      @include token(blue);
    }

    &[data-d='3'] {
      @include token(red);
    }
  }

  @keyframes spin {
    from {
      transform: rotate(0deg);
    }
    to {
      transform: rotate(360deg);
    }
  }

  :global(.m-icon._reload) {
    animation-name: spin;
    animation-duration: 0.5s;
    animation-iteration-count: infinite;
    animation-timing-function: linear;
  }

  .bread {
    // display: flex;
    // flex-wrap: wrap;

    margin: 0.375rem 0;
    line-height: 1.5rem;
    padding-bottom: 0.375rem;
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

<svelte:head>
  <title>{ch_title} - {bname} - Chivi</title>
  <meta property="og:url" content="{bslug}/{curr_url}" />
</svelte:head>

<svelte:window on:keydown={handleKeypress} />

<Vessel shift={clavis_actived}>
  <a slot="header-left" href={book_path} class="header-item _title">
    <MIcon class="m-icon _book-open" name="book-open" />
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
    disabled={$user.power < 1}
    on:click={() => reconvert(1)}>
    <MIcon
      class="m-icon _refresh-ccw {__reloading ? '_reload' : ''}"
      name="refresh-ccw" />
  </button>

  <button
    slot="header-right"
    type="button"
    class="header-item"
    class:_active={upsert_actived}
    on:click={() => showUpsertModal()}>
    <MIcon class="m-icon _plus-circle" name="plus-circle" />
  </button>

  <button
    slot="header-right"
    type="button"
    class="header-item"
    class:_active={clavis_enabled}
    on:click={triggerClavisSidebar}>
    <MIcon class="m-icon _compass" name="compass" />
  </button>

  <nav class="bread">
    <div class="-crumb _sep">
      <a href="/" class="-link">Chivi</a>
    </div>

    <div class="-crumb _sep">
      <a href="/~{bslug}" class="-link">{bname}</a>
    </div>

    <div class="-crumb _sep">
      <a href={book_path} class="-link">[{seed}]</a>
    </div>

    <div class="-crumb">
      <span class="-text">{ch_label}</span>
    </div>

    <div class="-right">
      <span>{relative_time(mftime)}</span>
    </div>
  </nav>

  <article class="convert" class:_reload={__reloading}>
    {#each lines as line, idx}
      <p
        class="line"
        class:_head={idx == 0}
        class:_para={idx != 0}
        class:_focus={idx == focused_line}
        class:_hover={idx == hovered_line}
        on:mouseenter={() => (hovered_line = idx)}
        on:click={(event) => handleClick(event, idx)}>
        {@html render_convert(line, renderMode(idx, hovered_line, focused_line))}
      </p>
    {/each}
  </article>

  <footer class="footer">
    {#if prev_url}
      <a class="m-button _line" class:_disable={!prev_url} href={prev_path}>
        <MIcon class="m-icon" name="chevron-left" />
        <span>Trước</span>
      </a>
    {/if}

    <a class="m-button _line" href={book_path}>
      <MIcon class="m-icon" name="list" />
      <span>Mục lục</span>
    </a>

    <a
      class="m-button _line _primary"
      class:_disable={!next_url}
      href={next_path}>
      <span>Kế tiếp</span>
      <MIcon class="m-icon" name="chevron-right" />
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

  {#if upsert_actived}
    <Upsert
      tab={upsert_tab}
      key={upsert_key}
      dname={ubid}
      bind:actived={upsert_actived}
      bind:changed={should_reload} />
  {/if}
</Vessel>

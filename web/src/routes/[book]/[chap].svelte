<script context="module">
  export async function preload({ params, query }) {
    const book_slug = params.book

    const cols = params.chap.split('-')
    const seed_name = cols[cols.length - 2]
    const chap_scid = cols[cols.length - 1]

    const mode = +query.mode || 0
    const data = await load_text(
      this.fetch,
      book_slug,
      seed_name,
      chap_scid,
      mode
    )

    return data
  }

  async function load_text(fetch, book_slug, seed_name, chap_scid, mode = 0) {
    const url = `/_load_text?slug=${book_slug}&seed=${seed_name}&scid=${chap_scid}&mode=${mode}`

    try {
      const res = await fetch(url)
      const data = await res.json()

      if (res.status == 200) return data
      else this.error(res.status, data.msg)
    } catch (err) {
      this.error(500, err.message)
    }
  }
</script>

<script>
  import { onMount } from 'svelte'

  import MIcon from '$mould/MIcon.svelte'
  import Header from '$layout/Header.svelte'
  import Lookup from '$layout/Lookup.svelte'
  import Upsert from '$layout/Upsert.svelte'

  import relative_time from '$utils/relative_time'
  import read_selection from '$utils/read_selection'
  import { render_convert, parse_content } from '$utils/render_convert'

  export let book_ubid = ''
  export let book_name = ''
  export let book_slug = ''

  export let ch_total = 1
  export let ch_index = 1

  export let seed_name = ''
  export let chap_scid = ''
  export let chap_time = 0
  export let chap_title = ''
  export let chap_label = ''

  export let prev_url = ''
  export let next_url = ''
  export let curr_url = ''

  export let content = ''
  $: lines = parse_content(content)

  let lineOnHover = 0
  let lineOnFocus = -1

  let elemOnFocus = null

  let lookupEnabled = false
  let lookupActived = false
  let lookupLine = ''
  let lookupFrom = 0

  let upsertEnabled = false
  let upsertKey = ''
  let upsertDic = 'combine'
  let upsertTab = 'generic'

  let shouldReload = false
  $: if (shouldReload) {
    shouldReload = false
    reloadContent(1)
  }

  function handleKeypress(evt) {
    if (upsertEnabled) return
    if (evt.ctrlKey) return

    // if (!evt.altKey) return

    switch (evt.keyCode) {
      case 220:
        triggerLookupSidebar()
        break

      case 72:
        evt.preventDefault()
        _goto(`/${book_slug}?tab=content&seed=${seed}`)
        break

      case 37:
      case 74:
        if (!evt.altKey) {
          evt.preventDefault()
          if (prev_url) _goto(`/${book_slug}/${prev_url}`)
          else _goto(book_slug)
        }
        break

      case 39:
      case 75:
        if (!evt.altKey) {
          evt.preventDefault()
          if (next_url) _goto(`/${book_slug}/${next_url}`)
          else _goto(`${book_slug}?tab=content&seed=${seed}`)
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
        evt.preventDefault()
        reloadContent(1)
        break

      default:
        break
    }
  }

  async function deleteFocusedWord() {
    if (!elemOnFocus) return

    const dname = +elemOnFocus.dataset.d == 3 ? book_ubid : 'generic'
    const key = elemOnFocus.dataset.k

    const url = `/_upsert?dname=${dname}&power=1&key=${key}`
    const res = await fetch(url)

    shouldReload = true
  }

  function handleClick(evt, idx) {
    const target = evt.target
    if (target === elemOnFocus) return showUpsertModal()

    if (target.nodeName !== 'X-V') return
    if (elemOnFocus) elemOnFocus.classList.remove('_active')

    lineOnFocus = idx
    lookupLine = lines[idx].map((x) => x[0]).join('')

    elemOnFocus = target
    elemOnFocus.classList.add('_active')
    lookupFrom = +elemOnFocus.dataset['p']

    if (lookupEnabled) lookupActived = true
  }

  function triggerLookupSidebar() {
    lookupEnabled = !lookupEnabled
    lookupActived = lookupEnabled
  }

  function renderMode(idx, hover, focus) {
    if (idx == focus || idx == hover) return 2
    // return 1
    if (idx < hover - 5) return 1
    if (idx > hover + 5) return 1
    return 2
  }

  function showUpsertModal(tab = null) {
    const selection = read_selection()

    if (selection !== '') upsertKey = selection
    else if (elemOnFocus) {
      upsertKey = elemOnFocus.dataset.k

      if (tab == null) {
        const dict = +elemOnFocus.dataset.d
        tab = dict === 3 ? 'special' : 'generic'
      }
    }

    upsertTab = tab || 'special'
    upsertDic = book_ubid
    upsertEnabled = true
  }

  let pageReloading = false
  async function reloadContent(mode = 1) {
    // console.log(`reloading page with mode: ${mode}`)

    pageReloading = true
    const data = await load_text(
      window.fetch,
      book_slug,
      seed_name,
      chap_scid,
      mode
    )

    lines = parse_content(data.content)
    chap_time = data.chap_time
    pageReloading = false
  }
</script>

<style lang="scss">
  .convert {
    padding: 0.75rem 0;
    word-wrap: break-word;

    &._reload {
      @include fgcolor(neutral, 7);
    }

    :global(h1) {
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

    :global(p) {
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

  .navi {
    // display: flex;
    // flex-wrap: wrap;
    margin: 0.375rem 0;
    line-height: 1.5rem;
    padding-bottom: 0.375rem;
    @include border($sides: bottom);
    @include clearfix;

    .crumb {
      // float: left;
      @include fgcolor(neutral, 6);
    }

    .split {
      // float: left;
      // margin: 0 0.25rem;
      @include fgcolor(neutral, 5);
    }

    a.crumb:hover {
      @include fgcolor(primary, 6);
    }

    .mtime {
      float: right;
      font-style: italic;
      @include fgcolor(neutral, 5);
    }
  }
</style>

<svelte:head>
  <title>{chap_title} - {book_name} - Chivi</title>
  <meta property="og:url" content="{book_slug}/{curr_url}" />
</svelte:head>

<svelte:window on:keydown={handleKeypress} />

<Header shiftLeft={lookupActived}>
  <a
    slot="left"
    href="/{book_slug}?tab=content&seed={seed_name}"
    class="header-item _title">
    <MIcon class="m-icon _book-open" name="book-open" />
    <span class="header-text _show-sm _title">{book_name}</span>
  </a>

  <span slot="left" class="header-item _active">
    <span class="header-text">{ch_index}</span>
    <span class="header-text _show-md">/{ch_total}</span>
  </span>

  <button
    slot="right"
    type="button"
    class="header-item"
    on:click={() => reloadContent()}>
    <MIcon
      class="m-icon _refresh-ccw {pageReloading ? '_reload' : ''}"
      name="refresh-ccw" />
  </button>

  <button
    slot="right"
    type="button"
    class="header-item"
    class:_active={upsertEnabled}
    on:click={() => showUpsertModal()}>
    <MIcon class="m-icon _plus-circle" name="plus-circle" />
  </button>

  <button
    slot="right"
    type="button"
    class="header-item"
    class:_active={lookupEnabled}
    on:click={triggerLookupSidebar}>
    <MIcon class="m-icon _compass" name="compass" />
  </button>
</Header>

<div class="wrapper">
  <nav class="navi">
    <a href="/" class="crumb">Chivi</a>
    <span class="split">&gt;</span>
    <a href="/{book_slug}" class="crumb">{book_name}</a>
    <span class="split">&gt;</span>
    <a href="/{book_slug}?tab=content&seed={seed_name}" class="crumb">
      [{seed_name}]
    </a>
    <span class="split">&gt;</span>
    <span class="crumb">{chap_label}</span>
    <span class="mtime">
      <span>Cập nhật:</span>
      <span>{relative_time(chap_time)}</span>
    </span>
  </nav>

  <article class="convert" class:_reload={pageReloading}>
    {#each lines as line, idx}
      <div
        class="line"
        class:_focus={idx == lineOnFocus}
        class:_hover={idx == lineOnHover}
        on:mouseenter={() => (lineOnHover = idx)}
        on:click={(event) => handleClick(event, idx)}>
        {@html render_convert(line, renderMode(idx, lineOnHover, lineOnFocus), idx == '0' ? 'h1' : 'p')}
      </div>
    {/each}
  </article>

  <footer class="footer">
    {#if prev_url}
      <a
        class="m-button _line"
        class:_disable={!prev_url}
        href="/{book_slug}/{prev_url || ''}">
        <MIcon class="m-icon" name="chevron-left" />
        <span>Trước</span>
      </a>
    {/if}

    <a class="m-button _line" href="/{book_slug}?tab=content&seed={seed_name}">
      <MIcon class="m-icon" name="list" />
      <span>Mục lục</span>
    </a>

    <a
      class="m-button _line _primary"
      class:_disable={!next_url}
      href="/{book_slug}/{next_url || ''}">
      <span>Kế tiếp</span>
      <MIcon class="m-icon" name="chevron-right" />
    </a>
  </footer>
</div>

{#if lookupEnabled}
  <Lookup
    on_top={!upsertEnabled}
    bind:active={lookupActived}
    input={lookupLine}
    dname={book_ubid}
    from={lookupFrom} />
{/if}

{#if upsertEnabled}
  <Upsert
    bind:active={upsertEnabled}
    key={upsertKey}
    dic={upsertDic}
    tab={upsertTab}
    bind:shouldReload />
{/if}

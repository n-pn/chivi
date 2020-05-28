<script context="module">
  export async function preload({ params, query }) {
    const book = params.book

    const slug = params.chap.split('-')
    const site = slug[slug.length - 2]
    const csid = slug[slug.length - 1]

    const mode = +query.mode || 0

    const data = await load_chapter(this.fetch, book, site, csid, mode)
    return { ...data, site, csid }
  }

  async function load_chapter(get, book, site, csid, mode = 0) {
    const url = `api/books/${book}/${site}/${csid}?mode=${mode}`

    try {
      const res = await get(url)
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
  import Layout from '$layout/Layout.svelte'
  import Lookup from '$layout/Lookup.svelte'
  import Upsert from '$layout/Upsert.svelte'

  import { lookup_active, lookup_line, lookup_from } from '$src/stores.js'
  import render_convert from '$utils/render_convert'
  import read_selection from '$utils/read_selection'

  export let book_uuid = ''
  export let book_name = ''
  export let book_slug = ''

  export let site
  export let csid

  export let prev_url = ''
  export let next_url = ''
  export let curr_url = ''

  export let ch_total = 1
  export let ch_index = 1

  export let content = []

  let lineOnHover = 0
  let lineOnFocus = -1

  let elemOnFocus = null

  let lookupEnabled = false
  let upsertEnabled = false

  let upsertKey = ''
  let upsertDic = 'combine'
  let upsertTab = 'generic'

  let upserted = false

  function handleKeypress(evt) {
    if (upsertEnabled) return

    // if (!evt.altKey) return

    switch (evt.keyCode) {
      case 220:
        trigger_lookup()
        break

      case 72:
        evt.preventDefault()
        _goto(book_slug)
        break

      case 37:
      case 74:
        if (!evt.altKey) {
          evt.preventDefault()
          if (prev_url) _goto(`${book_slug}/${prev_url}`)
          else _goto(book_slug)
        }

        break

      case 39:
      case 75:
        if (!evt.altKey) {
          evt.preventDefault()
          if (next_url) _goto(`${book_slug}/${next_url}`)
          else _goto(`${book_slug}`)
        }

        break

      case 88:
        if (evt.altKey && !upsertEnabled) {
          evt.preventDefault()
          active_upsert('special')
        }

        break

      case 67:
        if (evt.altKey && !upsertEnabled) {
          active_upsert('generic')
          evt.preventDefault()
        }

        break

      case 82:
        if (evt.altKey) reload_page(1)
        break

      default:
        break
    }
  }

  function handleClick(evt, idx) {
    const target = evt.target
    if (target === elemOnFocus) return active_upsert()

    if (elemOnFocus) elemOnFocus.classList.remove('_active')

    lineOnFocus = idx
    lookup_line.set(content[idx])

    if (target.nodeName !== 'X-V') {
      elemOnFocus = null
      lookup_from.set(0)
    } else {
      elemOnFocus = target
      elemOnFocus.classList.add('_active')
      lookup_from.set(+elemOnFocus.dataset['p'])
    }

    if (lookupEnabled) lookup_active.set(true)
  }

  function trigger_lookup() {
    lookupEnabled = !lookupEnabled
    lookup_active.set(lookupEnabled)
  }

  function render_mode(idx, hover, focus) {
    if (idx == focus) return 2
    if (idx < hover - 4) return 1
    if (idx > hover + 5) return 1
    return 2
  }

  function active_upsert(tab) {
    if (elemOnFocus) {
      upsertKey = elemOnFocus.dataset.k

      if (!tab) {
        const dict = +elemOnFocus.dataset.d
        tab = dict === 1 ? 'generic' : 'special'
      }
    }

    const selection = read_selection()
    if (selection !== '') upsertKey = selection

    upsertDic = book_uuid
    upsertTab = tab || 'special'
    upsertEnabled = true
  }

  let pageReloading = false
  async function reload_page(mode = 1) {
    pageReloading = true
    const data = await load_chapter(window.fetch, book_slug, site, csid, mode)

    content = data.content
    pageReloading = false
  }
</script>

<svelte:head>
  <title>{render_convert(content[0])} - {book_name} - Chivi</title>
  <meta property="og:url" content="{book_slug}/{curr_url}" />

</svelte:head>

<svelte:window on:keydown={handleKeypress} />

<Layout shiftLeft={$lookup_active}>
  <a slot="header-left" href="/" class="header-item ">
    <img src="/logo.svg" alt="logo" />
  </a>

  <a slot="header-left" href="/{book_slug}" class="header-item _title">
    <span>{book_name}</span>
  </a>

  <span slot="header-left" class="header-item _active _index">
    <!-- <span>{Math.round((ch_index * 10000) / ch_total) / 100}%</span> -->
    <span>{ch_index}/{ch_total}</span>
  </span>

  <button
    slot="header-right"
    type="button"
    class="header-item"
    on:click={() => reload_page()}>
    <MIcon
      class="m-icon _refresh-ccw {pageReloading ? '_reload' : ''}"
      name="refresh-ccw" />
  </button>

  <button
    slot="header-right"
    type="button"
    class="header-item"
    class:_active={upsertEnabled}
    on:click={() => active_upsert()}>
    <MIcon class="m-icon _plus-circle" name="plus-circle" />
  </button>

  <button
    slot="header-right"
    type="button"
    class="header-item"
    class:_active={lookupEnabled}
    on:click={trigger_lookup}>
    <MIcon class="m-icon _compass" name="compass" />
  </button>

  <article class:_reload={pageReloading}>
    {#each content as line, idx}
      <div
        class:_focus={idx == lineOnHover || idx == lineOnFocus}
        on:mouseenter={() => (lineOnHover = idx)}
        on:click={(event) => handleClick(event, idx)}>
        {@html render_convert(line, render_mode(idx, lineOnHover, lineOnFocus), idx == '0' ? 'h1' : 'p')}
      </div>
    {/each}
  </article>

  <footer>
    {#if prev_url}
      <a class="m-button _line" href="/{book_slug}/{prev_url}">
        <MIcon class="m-icon" name="chevron-left" />
        <span>Trước</span>
      </a>
    {:else}
      <a class="m-button _line" href="/{book_slug}">
        <MIcon class="m-icon" name="list" />
        <span>Mục lục</span>
      </a>
    {/if}

    {#if next_url}
      <a class="m-button _line _primary" href="/{book_slug}/{next_url}">
        <span>Kế tiếp</span>
        <MIcon class="m-icon" name="chevron-right" />
      </a>
    {:else if prev_url}
      <a class="m-button _line" href="/{book_slug}">
        <MIcon class="m-icon" name="list" />
        <span>Mục lục</span>
      </a>
    {/if}
  </footer>
</Layout>

{#if lookupEnabled}
  <Lookup />
{/if}

{#if upsertEnabled}
  <Upsert
    bind:active={upsertEnabled}
    key={upsertKey}
    dic={upsertDic}
    tab={upsertTab} />
{/if}

<style lang="scss">
  article {
    padding: 0.75rem 0;
    word-wrap: break-word;

    &._reload {
      @include fgcolor(neutral, 5);
    }

    :global(h1) {
      $font-sizes: attrs(rem(22px), rem(24px), rem(26px), rem(28px), rem(30px));
      $line-heights: attrs(1.5rem, 1.75rem, 2rem, 2.25rem, 2.5rem);

      @include props(font-size, $font-sizes);
      @include props(line-height, $line-heights);

      @include border($pos: bottom);
    }

    :global(p) {
      $font-sizes: attrs(rem(16px), rem(17px), rem(18px), rem(19px), rem(20px));
      $margin-tops: attrs(1rem, 1rem, 1.25rem, 1.5rem, 1.5rem);

      text-align: justify;
      text-justify: auto;

      @include props(font-size, $font-sizes);
      @include props(margin-top, $margin-tops);
    }

    :global(cite) {
      text-transform: capitalize;
      font-style: inherit;
      // font-variant: small-caps;
    }
  }

  footer {
    margin: 0.75rem 0;
    @include flex($gap: 0.375rem);
    justify-content: center;
  }

  @mixin token($color: blue) {
    border-color: color($color, 2);

    &._active {
      color: color($color, 6);
    }

    @include hover {
      color: color($color, 6);
    }
  }

  $token-colors: blue, teal, red, orange;

  :global(x-v) {
    position: relative;
    border-bottom: 1px solid transparent;

    div._focus & {
      cursor: pointer;

      &[data-d='1'] {
        @include token(blue);
      }

      &[data-d='2'] {
        @include token(orange);
      }

      &[data-d='3'] {
        @include token(red);
      }
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
    animation-duration: 1000ms;
    animation-iteration-count: infinite;
    animation-timing-function: linear;
  }
</style>

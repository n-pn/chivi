<script context="module">
  export async function preload({ params, query }) {
    const bslug = params.book

    const slug = params.chap.split('-')
    const site = slug[slug.length - 2]
    const csid = slug[slug.length - 1]

    const data = await load_page(this.fetch, bslug, site, csid)
    return { ...data, bslug, site, csid }
  }

  async function load_page(get, bslug, site, csid, mode = 0) {
    const url = `api/books/${bslug}/${site}/${csid}?mode=${mode}`

    try {
      const res = await get(url)
      const data = await res.json()

      if (res.status == 200) return data

      this.error(res.status, data.msg)
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

  export let bname
  export let bslug

  export let site
  export let csid

  export let prev_url
  export let next_url
  export let curr_url

  export let total
  export let chidx
  export let lines

  let lineOnHover = 0
  let lineOnFocus = -1

  let elemOnFocus = null

  let lookupEnabled = false
  let upsertEnabled = false

  let upsertKey = ''
  let upsertDic = 'combine'
  let upsertTab = 'generic'

  function handleKeypress(evt) {
    if (upsertEnabled) return

    // if (!evt.altKey) return

    switch (evt.keyCode) {
      case 220:
        trigger_lookup()
        // lookup_active.update((x) => !x)
        break

      case 72:
        evt.preventDefault()
        _goto(bslug)
        break

      case 37:
      case 74:
        if (!evt.altKey) {
          evt.preventDefault()
          if (prev_url) _goto(`${bslug}/${prev_url}`)
          else _goto(bslug)
        }

        break

      case 39:
      case 75:
        if (!evt.altKey) {
          evt.preventDefault()
          if (next_url) _goto(`${bslug}/${next_url}`)
          else _goto(`${bslug}`)
        }

        break

      case 88:
        if (!evt.altKey) return

        if (!upsertEnabled) active_upsert('special')
        evt.preventDefault()
        break

      case 67:
        if (!evt.altKey) return

        if (!upsertEnabled) active_upsert('generic')
        evt.preventDefault()
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

    if (target === elemOnFocus) {
      active_upsert()
      return
    }

    if (elemOnFocus) elemOnFocus.classList.remove('_active')

    lineOnFocus = idx
    lookup_line.set(lines[idx])

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
    if (lookupEnabled) {
      lookupEnabled = false
      lookup_active.set(false)
    } else {
      lookupEnabled = true
      lookup_active.set(true)
    }
  }

  function is_active(idx, hover, focus) {
    if (idx == focus) return true
    if (idx < hover - 4) return false
    if (idx > hover + 5) return false
    return true
  }

  function active_upsert(tab = null) {
    const selection = read_selection()

    if (selection !== '') {
      upsertKey = selection
    } else if (elemOnFocus) {
      upsertKey = elemOnFocus.dataset.k
      const dic = +elemOnFocus.dataset.d
      if (dic == 1 || dic == 2) {
        upsertTab = 'generic'
      } else {
        upsertTab = 'special'
      }
    }

    upsertTab = upsertTab || tab || 'special'
    upsertEnabled = true
  }

  let reload = false
  async function reload_page(mode = 1) {
    reload = true
    const data = await load_page(window.fetch, bslug, site, csid, mode)
    lines = data.lines
    reload = false
  }
</script>

<svelte:head>
  <title>{render_convert(lines[0])} - {bname} - Chivi</title>
  <meta property="og:url" content="{bslug}/{curr_url}" />

</svelte:head>

<svelte:window on:keydown={handleKeypress} />

<Layout shiftLeft={$lookup_active}>
  <a slot="header-left" href="/" class="header-item ">
    <img src="/logo.svg" alt="logo" />
  </a>

  <a slot="header-left" href="/{bslug}" class="header-item _title">
    <span>{bname}</span>
  </a>

  <span slot="header-left" class="header-item _active _index">
    <!-- <span>{Math.round((chidx * 10000) / total) / 100}%</span> -->
    <span>{chidx}/{total}</span>
  </span>

  <button
    slot="header-right"
    type="button"
    class="header-item"
    on:click={() => reload_page()}>
    <MIcon class="m-icon _refresh-ccw" name="refresh-ccw" />
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

  <article class:reload>
    {#each lines as line, idx}
      <div
        class:_focus={idx == lineOnHover || idx == lineOnFocus}
        on:mouseenter={() => (lineOnHover = idx)}
        on:click={(event) => handleClick(event, idx)}>
        {#if idx == 0}
          <h1>
            {@html render_convert(line, is_active(idx, lineOnHover, lineOnFocus), true)}
          </h1>
        {:else}
          <p>
            {@html render_convert(line, is_active(idx, lineOnHover, lineOnFocus), true)}
          </p>
        {/if}
      </div>
    {/each}
  </article>

  <footer>
    {#if prev_url}
      <a class="m-button _line" href="/{bslug}/{prev_url}">
        <MIcon class="m-icon" name="chevron-left" />
        <span>Trước</span>
      </a>
    {:else}
      <a class="m-button _line" href="/{bslug}">
        <MIcon class="m-icon" name="list" />
        <span>Mục lục</span>
      </a>
    {/if}

    {#if next_url}
      <a class="m-button _line _primary" href="/{bslug}/{next_url}">
        <span>Kế tiếp</span>
        <MIcon class="m-icon" name="chevron-right" />
      </a>
    {:else if prev_url}
      <a class="m-button _line" href="/{bslug}">
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

    &.reload {
      @include fgcolor(neutral, 4);
    }
  }

  h1 {
    $font-sizes: attrs(rem(22px), rem(24px), rem(26px), rem(28px), rem(30px));
    $line-heights: attrs(1.5rem, 1.75rem, 2rem, 2.25rem, 2.5rem);

    @include props(font-size, $font-sizes);
    @include props(line-height, $line-heights);

    @include border($pos: bottom);
  }

  p {
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

  footer {
    margin: 0.75rem 0;
    @include flex($gap: 0.375rem);
    justify-content: center;
  }

  @mixin token($color: blue) {
    border-color: color($color, 3);

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
        @include token(teal);
      }

      &[data-d='3'] {
        @include token(red);
      }

      &[data-d='4'] {
        @include token(orange);
      }
      // @for $index from 1 through 4 {
      //   $color: nth($token-colors, $index);
      //   &[data-d='#{color}'] {
      //     @include token($color);
      //   }
      // }
    }
  }
</style>

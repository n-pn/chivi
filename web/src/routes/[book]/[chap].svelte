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

  const tags = {
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&apos;',
  }

  function replace_tag(tag) {
    return tags[tag] || tag
  }

  function escape_html(str) {
    return str.replace(/[&<>]/g, replace_tag)
  }

  export function render(tokens, active = false) {
    let res = ''
    let idx = 0
    let pos = 0

    for (const [key, val, dic] of tokens) {
      switch (val.charAt(0)) {
        case '⟨':
          res += '<cite>'
          break
        case '“':
          res += '<em>'
          break
      }

      const e_key = escape_html(key)
      const e_val = escape_html(val)

      if (active) {
        res += `<x-v data-k="${e_key}" data-i=${idx} data-d=${dic} data-p=${pos}>${e_val}</x-v>`
      } else res += e_val

      switch (val.charAt(val.length - 1)) {
        case '⟩':
          res += '</cite>'
          break
        case '”':
          res += '</em>'
          break

        // if (val === '⟨') body += '<cite>⟨'
        //       else if (val === '⟩') body += '⟩</cite>'
        //       else if (val === '[') body += '<x-m>['
        //       else if (val === ']') body += ']</x-m>'
        //       else if (val === '“') body += '<q>'
        //       else if (val === '”') body += '</q>'
        //       else if (val === '‘') body += '<i>‘'
        //       else if (val === '’') body += '’</i>'
      }

      idx += 1
      pos += key.length
    }

    return res
  }

  function get_selection(evt) {
    const nodes = get_selected()

    let res = ''
    let idx = 0

    for (; idx < nodes.length; idx++) {
      const node = nodes[idx]
      const name = node.nodeName

      if (name == 'X-Z') break
      else if (name == 'X-V') {
        const dic = +node.dataset.d
        const key = node.dataset.k
        if (dic > 0 || key == '的' || key == '') break
      }
    }

    for (; idx < nodes.length; idx++) {
      const node = nodes[idx]
      const name = node.nodeName

      if (name == 'X-V') {
        const dic = +node.dataset.d
        const key = node.dataset.k
        if (dic > 0 || key == '的' || key == '') res += key
        else break
      } else if (name == 'X-Z') res += node.textContent.trim()
      else if (name != '#text') break
    }

    return res
  }

  function get_selected() {
    const selection = document.getSelection()
    if (selection.isCollapsed) return []

    const range = selection.getRangeAt(0)

    let node = range.startContainer
    const stop = range.endContainer

    // Special case for a range that is contained within a single node
    if (node == stop) return [node]

    // Iterate nodes until we hit the end container
    let nodes = []
    while (node && node != stop) {
      node = next_node(node)
      if (node) nodes.push(node)
    }

    // Add partially selected nodes at the start of the range
    node = range.startContainer
    while (node && node != range.commonAncestorContainer) {
      nodes.unshift(node)
      node = node.parentNode
    }

    return nodes
  }

  function next_node(node) {
    if (node.hasChildNodes()) return node.firstChild

    while (node && !node.nextSibling) node = node.parentNode
    if (!node) return null
    return node.nextSibling
  }
</script>

<script>
  import { onMount } from 'svelte'

  import MIcon from '$mould/MIcon.svelte'
  import Header from '$layout/Header.svelte'
  import Lookup from '$layout/Lookup.svelte'
  import Upsert from '$layout/Upsert.svelte'

  import { lookup_active, lookup_line, lookup_from } from '$src/stores.js'

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

  let lineOnFocus = 0
  let elemOnFocus = null

  let lookupEnabled = false
  let upsertEnabled = false

  let upsertKey = ''
  let upsertDic = 'combine'
  let upsertTab = 'generic'

  function navigate(evt) {
    if (upsertEnabled) return

    // if (!evt.altKey) return

    switch (evt.keyCode) {
      case 27:
        upsertEnabled = false
        break

      case 72:
        evt.preventDefault()
        _goto(bslug)
        break

      case 37:
      case 74:
        evt.preventDefault()
        if (prev_url) _goto(`${bslug}/${prev_url}`)
        else _goto(bslug)
        break

      case 39:
      case 75:
        if (next_url) _goto(`${bslug}/${next_url}`)
        else _goto(`${bslug}`)
        evt.preventDefault()
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

  function change_focus(idx) {
    lineOnFocus = idx
  }

  function active_lookup(evt, idx) {
    if (elemOnFocus) {
      elemOnFocus.classList.remove('_active')
    }

    lookup_line.set(lines[idx])

    if (evt.target.nodeName !== 'X-V') {
      elemOnFocus = null
      lookup_from.set(0)
    } else {
      elemOnFocus = evt.target
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

  function is_active(idx, cur) {
    if (idx < cur - 9) return false
    if (idx > cur + 9) return false
    return true
  }

  function active_upsert(tab = 'special') {
    upsertTab = tab

    const selection = get_selection()

    if (selection !== '') {
      upsertKey = selection
    } else if (elemOnFocus) {
      upsertKey = elemOnFocus.dataset.k

      // const dic = +elemOnFocus.dataset.d
      // if (dic == 1 || dic == 2) {
      //   upsertTab = 'generic'
      // } else {
      //   upsertTab = 'special'
      // }
    }

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
  <title>{render(lines[0])} - {bname} - Chivi</title>
  <meta property="og:url" content="{bslug}/{curr_url}" />

</svelte:head>

<svelte:window on:keydown={navigate} />

<Header>
  <div class="left">
    <a href="/" class="header-item">
      <img src="/logo.svg" alt="logo" />
    </a>

    <a href="/{bslug}" class="header-item _title">
      <span>{bname}</span>
    </a>

    <span class="header-item _active _index">
      <span>{chidx}/{total}</span>
    </span>
  </div>

  <div class="right">
    <!-- <a href="/{bslug}/{curr_slug}?reload=true" class="header-item">
      <MIcon class="m-icon _refresh-ccw" name="refresh-ccw" />
    </a> -->

    <button type="button" class="header-item" on:click={() => reload_page()}>
      <MIcon class="m-icon _refresh-ccw" name="refresh-ccw" />
    </button>

    <button
      type="button"
      class="header-item"
      class:_active={lookupEnabled}
      on:click={trigger_lookup}>
      <MIcon class="m-icon _compass" name="compass" />
    </button>
  </div>
</Header>

<div class="wrapper">
  <article class:reload>
    {#each lines as line, idx}
      <div
        class:_focus={idx == lineOnFocus && lookupEnabled}
        on:mouseenter={() => change_focus(idx)}
        on:click={event => active_lookup(event, idx)}>
        {#if idx == 0}
          <h1>
            {@html render(line, is_active(idx, lineOnFocus))}
          </h1>
        {:else}
          <p>
            {@html render(line, is_active(idx, lineOnFocus))}
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
</div>

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
    // background-color: #fff;
    // margin: 0.75rem 0;
    // @include radius;
    // @include shadow(1);
    padding: 0.75rem;
    word-wrap: break-word;
    text-align: justify;
    text-justify: auto;
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

<script context="module">
  export async function preload({ params }) {
    const book = params.book

    const slug = params.chap.split('-')
    const site = slug[slug.length - 2]
    const chap = slug[slug.length - 1]

    const url = `api/books/${book}/${site}/${chap}`

    try {
      const res = await this.fetch(url)
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

      const text = escape_html(val)

      if (active) {
        const e_key = escape_html(key)
        res += `<x-v data-k="${e_key}" data-i=${idx} data-d=${dic} data-p=${pos}>${text}</x-v>`
      } else {
        res += text
      }

      switch (val.charAt(val.length - 1)) {
        case '⟩':
          res += '</cite>'
          break
        case '”':
          res += '</em>'
          break
      }

      idx += 1
      pos += key.length
    }

    return res
  }
</script>

<script>
  import { onMount } from 'svelte'

  import MIcon from '$mould/shared/MIcon.svelte'
  import Header from '$mould/layout/Header.svelte'
  import Lookup from '$mould/layout/Lookup.svelte'

  export let book_slug
  export let book_name
  export let prev_slug
  export let next_slug
  export let curr_slug

  export let lines
  export let chidx
  export let total

  let cur = 0

  let lookup_text = ''
  let lookup_from = 0
  let lookup_active = false

  function navigate(evt) {
    if (evt.ctrlKey || evt.altKey || evt.shiftKey) return

    switch (evt.keyCode) {
      case 72:
        evt.preventDefault()
        _goto(book_slug)
        break

      case 37:
      case 74:
        evt.preventDefault()
        if (prev_slug) _goto(`${book_slug}/${prev_slug}`)
        else _goto(book_slug)

        break

      case 39:
      case 75:
        if (next_slug) _goto(`${book_slug}/${next_slug}`)
        else _goto(`${book_slug}`)
        evt.preventDefault()

        break

      default:
        break
    }
  }

  // onMount(() => {
  //   document.onselectionchange = selection
  // })

  function selection(evt) {
    const nodes = get_selected()
    let key = ''
    for (const node of nodes) {
      if (node.nodeName == 'X-V') key += node.getAttribute('k')
    }
    console.log(key)
  }

  function get_selected() {
    const sel = document.getSelection()
    if (sel.isCollapsed) return []

    const range = sel.getRangeAt(0)

    let node = range.startContainer
    const stop = range.endContainer

    // Special case for a range that is contained within a single node
    if (node == stop) return [node]

    // Iterate nodes until we hit the end container
    let nodes = []
    while (node && node != stop) {
      nodes.push((node = next_node(node)))
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

  function lookup(evt, idx) {
    lookup_text = lines[idx].map(([key]) => key).join('')

    if (evt.target.nodeName !== 'X-V') return
    lookup_from = +evt.target.dataset['p']
    lookup_active = true
  }
</script>

<style lang="scss">
  @mixin responsive-gap() {
    padding: 0.75rem;

    @include screen-min(md) {
      padding: 1rem;
    }

    @include screen-min(lg) {
      padding: 1.25rem;
    }

    @include screen-min(xl) {
      padding: 1.5rem;
    }
  }

  article {
    // background-color: #fff;
    // margin: 0.75rem 0;
    // @include radius;
    // @include shadow(1);
    text-align: justify;
    text-justify: auto;
    word-wrap: break-word;
    padding: 0.75rem;
    // @include responsive-gap();
  }

  h1 {
    @include border($side: bottom);

    font-size: rem(20px);
    line-height: 1.75rem;

    @include screen-min(md) {
      font-size: rem(22px);
      line-height: 2rem;
    }

    @include screen-min(lg) {
      font-size: rem(24px);
      line-height: 2.25rem;
    }

    @include screen-min(xl) {
      font-size: rem(30px);
      line-height: 2.5rem;
    }
  }

  p {
    margin-top: 1rem;
    font-size: rem(17px);

    @include screen-min(md) {
      font-size: rem(18px);
    }

    @include screen-min(lg) {
      font-size: rem(19px);
      margin-top: 1.25rem;
    }

    @include screen-min(xl) {
      font-size: rem(20px);
      margin-top: 1.5rem;
    }
  }

  :global(cite) {
    text-transform: capitalize;
    font-style: normal;
    // font-variant: small-caps;
  }

  footer {
    margin: 0.75rem 0;
    display: flex;
    justify-content: center;
    [m-button] {
      margin-left: 0.5rem;
    }
  }

  :global(x-v) {
    border-bottom: 1px solid transparent;

    &[data-d='1'] {
      border-bottom-color: color(blue, 3);
      cursor: pointer;
      @include hover {
        color: color(blue, 6);
      }
    }

    &[data-d='2'] {
      border-bottom-color: color(teal, 3);
      cursor: pointer;
      @include hover {
        color: color(teal, 6);
      }
    }

    &[data-d='3'] {
      border-bottom-color: color(red, 3);
      cursor: pointer;
      @include hover {
        color: color(red, 6);
      }
    }

    &[data-d='4'] {
      border-color: color(orange, 3);
      cursor: pointer;
      @include hover {
        color: color(orange, 6);
      }
    }
  }

  .index {
    padding: 0 0.375rem;
    @include truncate(25vw);
  }
</style>

<svelte:head>
  <title>{render(lines[0])} - {book_name} - Chivi</title>
</svelte:head>

<svelte:window on:keydown={navigate} />

<Header>
  <div class="left">
    <a href="/" class="header-item">
      <img src="/logo.svg" alt="logo" />
    </a>

    <a href="/{book_slug}" class="header-item _active">
      <span>{book_name}</span>
    </a>

    <!-- <LinkBtn href="/{book_slug}/{curr_slug}"> -->
    <span class="index">Ch {chidx}/{total}</span>
    <!-- </LinkBtn> -->
  </div>

  <div class="right">
    <a href="/{book_slug}/{curr_slug}?reload=true" class="header-item">
      <MIcon m-icon="refresh-ccw" />
    </a>

    <button
      class="header-item"
      class:_active={lookup_active}
      on:click={() => (lookup_active = !lookup_active)}>
      <MIcon m-icon="info" />
    </button>
  </div>
</Header>

<article>
  {#each lines as line, idx}
    {#if idx == 0}
      <h1
        class:_active={idx == cur}
        on:mouseenter={() => (cur = idx)}
        on:click={evt => lookup(evt, idx)}>
        {@html render(line, idx == cur)}
      </h1>
    {:else}
      <p
        class:_active={idx == cur}
        on:mouseenter={() => (cur = idx)}
        on:click={evt => lookup(evt, idx)}>
        {@html render(line, idx == cur)}
      </p>
    {/if}
  {/each}
</article>

<footer>
  {#if prev_slug}
    <a m-button="line" href="/{book_slug}/{prev_slug}">
      <MIcon m-icon="chevron-left" />
      <span>Trước</span>
    </a>
  {:else}
    <a m-button="line" href="/{book_slug}">
      <MIcon m-icon="list" />
      <span>Mục lục</span>
    </a>
  {/if}

  {#if next_slug}
    <a m-button="line primary" href="/{book_slug}/{next_slug}">
      <span>Tiếp</span>
      <MIcon m-icon="chevron-right" />
    </a>
  {:else if prev_slug}
    <a m-button="line" href="/{book_slug}">
      <MIcon m-icon="list" />
      <span>Mục lục</span>
    </a>
  {/if}
</footer>

<Lookup text={lookup_text} from={lookup_from} bind:active={lookup_active} />

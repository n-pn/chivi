<script context="module">
  async function get_entries(line, from = 0, upto = from + 1) {
    // TODO: add udic
    const res = await fetch(
      `/api/lookup?line=${line}&from=${from}&upto=${upto}`
    )
    const entries = await res.json()
    return entries
  }

  function replace_tag(tag) {
    return tags[tag] || tag
  }

  function escape_html(str) {
    return str.replace(/[&<>]/g, replace_tag)
  }

  function is_active(ax, ay, bx, by) {
    if (bx >= ax && bx < ay) return '_active'
    // if (ay >= bx && ay < by) return '_active'
    return ''
  }

  function render(tokens, from, upto) {
    let zh = ''
    let vi = ''

    let idx = 0
    let pos = 0

    for (const [key, val, dic] of tokens) {
      const e_key = escape_html(key)
      const e_val = escape_html(val)

      if (dic > 0) {
        key.split('').forEach((k, i) => {
          let klass = is_active(from, upto, pos + i, pos + i + 1)
          zh += `<x-zh class="${klass}" data-p="${pos + i}">${escape_html(
            k
          )}</x-zh>`
        })

        let klass = is_active(from, upto, pos, pos + key.length)
        vi += `<x-vi class="${klass}" data-k="${e_key}" data-i="${idx}" data-d="${dic}" data-p="${pos}">${e_val}</x-vi>`
      } else {
        zh += e_key
        vi += e_val
      }

      idx += 1
      pos += key.length
    }

    return [zh, vi]
  }
</script>

<script>
  import MIcon from '$mould/shared/MIcon.svelte'

  import {
    lookup_active as active,
    lookup_pinned as pinned,
    lookup_line as line,
    lookup_from as from,
    lookup_udic as udic,
  } from '../../stores.js'

  let upto = $from + 1

  // let hanviet = []
  let entries = []

  $: zh_text = $line.map(([zh]) => zh).join('')
  $: [zh_html, vi_html] = render($line, $from, upto)
  $: if (line !== []) lookup(zh_text, $from)

  async function lookup(zh_text, from) {
    // hanviet = await get_hanviet(text)
    entries = await get_entries(zh_text, from)
    if (entries.length > 0) upto = $from + +entries[0][0]
    else upto = $from + 1
  }

  function handle_click(event) {
    const target = event.target
    if (target.nodeName == 'X-ZH' || target.nodeName == 'X-VI') {
      from.set(+target.dataset['p'])
    }
  }

  function handle_keypress(e) {
    if (e.keyCode != 92) return
    active.update(x => !x)
  }

  function pin_sidebar() {
    pinned.update(x => !x)
  }

  function close_sidebar() {
    active.set(false)
  }
</script>

<style lang="scss">
  $sidebar-width: 30rem;

  aside {
    position: fixed;
    display: block;
    top: 0;
    right: 0;
    width: $sidebar-width;
    // min-width: 20rem;
    max-width: 90vw;

    height: 100%;
    z-index: 900;

    @include bgcolor(white);
    @include shadow(2);

    // transition: transform 0.1s ease;
    transform: translateX(100%);
    &._active {
      transform: translateX(0);
    }
  }

  $hd-height: 3rem;

  header {
    display: flex;
    height: $hd-height;
    padding: 0.375rem 0.75rem;
    border-bottom: 1px solid color(neutral, 3);

    :global(svg) {
      display: inline-block;
      // vertical-align: top;
      vertical-align: text-top;
      width: 1.25rem;
      height: 1.25rem;
    }

    h2 {
      // display: flex;
      margin-right: auto;
      font-weight: 500;
      text-transform: uppercase;
      line-height: $hd-height - 0.75rem;
      @include color(neutral, 6);
      @include font-size(sm);
    }

    button {
      // margin-right: 0.75rem;
      padding: 0 0.5rem;
      @include color(neutral, 6);
      @include bgcolor(none);
      &._active,
      &:hover {
        @include color(primary, 6);
      }
    }
  }

  $vi-height: 0.75rem + (1.25 * 7rem);
  $zh-height: 0.75rem + (1.25 * 5rem);

  .input {
    overflow-y: scroll;
    line-height: 1.25rem;
    padding: 0.375rem 0.75rem;
    border-bottom: 1px solid color(neutral, 3);
    margin-bottom: 0.75rem;

    @include bgcolor(neutral, 1);
    @include font-family(sans);

    &._vi {
      max-height: $vi-height;
    }

    &._zh {
      max-height: $zh-height;
      border-top: 1px solid color(neutral, 3);
    }
  }

  $top-height: $hd-height + $zh-height + $vi-height + 1.5rem;

  section {
    height: calc(100% - #{$top-height});
    overflow-y: scroll;
  }

  :global(x-zh) {
    cursor: pointer;
    @include hover {
      @include color(primary, 5);
    }

    &._active {
      @include color(primary, 5);
    }
  }

  h4 {
    font-weight: 500;
    text-transform: uppercase;
    @include color(neutral, 6);
    @include font-size(sm);
  }

  :global(x-vi) {
    border-bottom: 1px solid transparent;

    &[data-d='1'] {
      border-bottom-color: color(blue, 3);
      cursor: pointer;
      &._active,
      &:hover {
        color: color(blue, 6);
      }
    }

    &[data-d='2'] {
      border-bottom-color: color(teal, 3);
      cursor: pointer;
      &._active,
      &:hover {
        color: color(teal, 6);
      }
    }

    &[data-d='3'] {
      border-bottom-color: color(red, 3);
      cursor: pointer;
      &._active,
      &:hover {
        color: color(red, 6);
      }
    }

    &[data-d='4'] {
      border-color: color(orange, 3);
      cursor: pointer;
      &._active,
      &:hover {
        color: color(orange, 6);
      }
    }
  }

  h3 {
    // margin-top: 0.5rem;
    font-weight: bold;
    @include font-size(md);
    @include color(neutral, 7);
  }

  .entry {
    padding: 0.375rem 0.75rem;
    // padding-top: 0;

    border-top: 1px solid color(neutral, 3);
  }

  .item {
    @include clearfix;
    & + & {
      margin-top: 0.5rem;
    }
  }

  .term {
    line-height: 1.375rem;
    margin-top: 0.25rem;
  }
</style>

<svelte:window on:keypress={handle_keypress} />

<aside class:_active={$active}>
  <header>
    <h2>Giải nghĩa</h2>

    <button class:_active={$pinned} on:click={pin_sidebar}>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round">
        <path
          d="M17.85 10.2l-4.24 5.65m4.24-5.66L13.6 5.95m4.24 4.24a2 2 0 0 0 2.83
          0l.7-.7-7.07-7.08-.7.71a2 2 0 0 0 0 2.83m0 9.9l-5.66-5.66m5.66
          5.66s1.76 2.47-.71 4.95L3 10.9c2.47-2.48 4.95-.7 4.95-.7m0
          0l5.66-4.25M7.95 15.85l-4.24 4.24" />
      </svg>
    </button>

    <button on:click={close_sidebar}>
      <MIcon m-icon="x" />
    </button>

  </header>

  <div class="input _vi" on:click={handle_click}>
    {@html vi_html}
  </div>

  <div class="input _zh" on:click={handle_click}>
    {@html zh_html}
  </div>

  <section class="lookup">
    {#each entries as [len, items]}
      <div class="entry">
        <h3>{zh_text.substring($from, $from + len)}</h3>
        {#each items as [name, value]}
          <div class="item">
            <h4>{name}</h4>
            {#each value.split('\n') as line}
              <p class="term">{line}</p>
            {/each}
          </div>
        {/each}
      </div>
    {/each}
  </section>
</aside>

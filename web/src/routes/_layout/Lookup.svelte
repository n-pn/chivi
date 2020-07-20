<script context="module">
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
          zh += `<x-z class="${klass}" data-p="${pos + i}">${escape_html(
            k
          )}</x-z>`
        })

        let klass = is_active(from, upto, pos, pos + key.length)
        vi += `<x-v class="${klass}" data-k="${e_key}" data-i="${idx}" data-d="${dic}" data-p="${pos}">${e_val}</x-v>`
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
  import { parse_content } from '$utils/render_convert'
  import MIcon from '$mould/MIcon.svelte'

  export let input = ''
  export let dname = 'tong-hop'

  export let active = false
  export let on_top = false

  export let from = 0
  let upto = from + 1

  let hanviet = []
  let entries = []
  let current = []

  $: if (input !== '') lookupTerms(input)

  $: if (entries.length > from) {
    current = entries[from]
    if (current.length == 0) upto = from + 1
    else upto = from + +current[0][0].length
  }
  $: [zh_html, hv_html] = render(hanviet, from, upto)

  async function lookupTerms(input) {
    const url = `_lookup?input=${input}&dname=${dname}`
    const res = await fetch(url)
    const data = await res.json()

    entries = data.entries
    hanviet = parse_content(data.hanviet)
  }

  function handleClick(event) {
    const target = event.target
    if (target.nodeName == 'X-Z' || target.nodeName == 'X-V') {
      from = +target.dataset['p']
    }
  }

  function handleKeypress(evt) {
    if (evt.keyCode == 27 && on_top) active = false
  }

  function renderVietphrase(words) {
    let res = []
    for (let word of words) {
      if (word === '') res.push('<em>&lt;đã xoá&gt;</em>')
      else res.push(word)
    }
    return res.join('; ')
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
      @include fgcolor(neutral, 6);
      @include font-size(sm);
    }

    :global(button) {
      // margin-right: 0.75rem;
      padding: 0 0.5rem;
      @include fgcolor(neutral, 6);
      @include bgcolor(transparent);
      &._active,
      &:hover {
        @include fgcolor(primary, 6);
      }
    }
  }

  @mixin token($color: blue) {
    @include bdcolor($color, 3);

    &._active {
      color: color($color, 6);
    }

    @include hover {
      color: color($color, 6);
    }
  }

  // $vi-height: 0.75rem + (1.25 * 6rem);
  // $vi-height: 0;
  $zh-height: 0.75rem + (1.25 * 5rem);
  $hv-height: 0.75rem + (1.25 * 6rem);

  .source {
    overflow-y: auto;
    line-height: 1.25rem;
    padding: 0.375rem 0.75rem;
    // margin: 0.75rem;
    // border: 1px solid color(neutral, 3);
    // margin-bottom: 0.75rem;

    @include bgcolor(neutral, 1);
    // @include font-family(sans);

    // &._vi {
    //   max-height: $vi-height;
    //   border-bottom: 1px solid color(neutral, 3);
    // }

    &._zh {
      max-height: $zh-height;
      // margin-top: 0.375rem;
      @include border($sides: bottom);
    }

    &._hv {
      max-height: $hv-height;
      // margin-top: 0.5rem;
      @include border($sides: bottom);
    }

    :global(x-z),
    :global(x-v) {
      cursor: pointer;
      @include hover {
        @include fgcolor(primary, 5);
      }

      &._active {
        @include fgcolor(primary, 5);
      }
    }
  }

  // $top-height: $hd-height + $zh-height + $vi-height;

  section {
    height: calc(100% - #{$hd-height});
    overflow-y: auto;
  }

  .word {
    // margin-top: 0.5rem;
    font-weight: 500;
    @include font-size(md);
    @include fgcolor(neutral, 7);
    // @include border($sides: left, $width: 0.25rem, $color: color(primary, 5));
  }

  h4 {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(neutral, 6);
    @include font-size(2);
  }

  .entry {
    padding: 0.375rem 0.75rem;
    // padding-top: 0;
    @include border($sides: bottom, $shade: 3);
    &:last-child {
      border: none;
    }
  }

  .item {
    // @include clearfix;
    & + & {
      margin-top: 0.25rem;
    }
  }

  .term {
    line-height: 1.5rem;
    // margin-top: 0.25rem;
  }
</style>

<svelte:window on:keydown={handleKeypress} />

<aside class:_active={active}>
  <header>
    <h2>Giải nghĩa</h2>

    <button on:click={() => (active = false)}>
      <MIcon class="m-icon" name="x" />
    </button>
  </header>

  <section class="lookup">
    <div class="source _zh" on:click={handleClick} lang="zh">
      {@html zh_html}
    </div>

    <div class="source _hv" on:click={handleClick}>
      {@html hv_html}
    </div>

    {#each current as [size, entries]}
      <div class="entry">
        <h3 class="word" lang="zh">{input.substr(from, size)}</h3>
        {#each Object.entries(entries) as [name, items]}
          {#if items.length > 0}
            <div class="item">
              <h4 class="name">{name}</h4>
              {#if name == 'vietphrase'}
                <p class="viet">
                  {@html renderVietphrase(items)}
                </p>
              {:else}
                {#each items as line}
                  <p class="term">{line}</p>
                {/each}
              {/if}
            </div>
          {/if}
        {/each}
      </div>
    {/each}
  </section>
</aside>

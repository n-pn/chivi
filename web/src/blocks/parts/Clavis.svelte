<script context="module">
  const tags = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&apos;',
  }

  function replace_tag(tag) {
    return tags[tag] || tag
  }

  function escape_html(str) {
    return str.replace(/[&<>'"]/g, replace_tag)
  }

  function is_active(from, upto, idx) {
    if (idx < from) return false
    return idx < upto
  }

  function render_zh(tokens, from, upto) {
    let res = ''
    let i = 0
    let p = 0

    for (const [key] of tokens) {
      if (key == '') continue
      let keys = key.split('')

      for (let j = 0; j < keys.length; j++) {
        res += '<x-v '
        if (is_active(from, upto, p)) res += 'class="_active" '

        const k = escape_html(keys[j])
        res += `data-k=${k} data-i=${i} data-p=${p} data-d=1>${k}</x-v>`
        p += 1
      }

      i += 1
    }

    return res
  }

  function render_hv(tokens, from, upto) {
    let res = ''
    let idx = 0
    let pos = 0

    for (const [key, val, dic] of tokens) {
      let key_chars = key.split('')
      let val_chars = val.split(' ')

      if (dic == 0 || key_chars.length != val_chars.length) {
        res += val
        idx += 1
        pos += key_chars.length
        continue
      }

      for (let jdx = 0; jdx < key_chars.length; jdx++) {
        const key_char = key_chars[jdx]
        const val_char = val_chars[jdx]

        if (jdx > 0) res += ' '
        res += '<x-v '
        if (is_active(from, upto, pos)) res += 'class=_active '

        res += `data-k=${escape_html(key_char)} `
        res += `data-i=${idx} `
        res += `data-p=${pos}>`
        res += escape_html(val_char)
        res += '</x-v>'
        pos += 1
      }

      idx += 1
    }

    return res
  }
</script>

<script>
  import { parse_content } from '$utils/render_convert'
  import AIcon from '$atoms/AIcon.svelte'

  export let input = ''
  export let dname = 'dich-nhanh'

  export let active = false
  export let on_top = false

  export let from = 0
  let upto = from + 1

  let hanviet = []
  let entries = []
  let current = []

  $: if (input !== '') lookup_line(input)
  $: if (from < entries.length) updateFocus()

  $: zh_html = render_zh(hanviet, from, upto)
  $: hv_html = render_hv(hanviet, from, upto)

  async function lookup_line(input) {
    const url = `/_dicts/lookup?dname=${dname}`
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ input: input }),
    })
    const data = await res.json()

    entries = data.entries
    hanviet = parse_content(data.hanviet)[0][0]
    from = from
  }

  function updateFocus() {
    if (entries.length < from) {
      current = []
      upto = from + 1
    } else {
      current = entries[from]

      if (current.length == 0) upto = from + 1
      else upto = from + +current[0][0]
    }
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

<svelte:window on:keydown={handleKeypress} />

<aside class:_active={active}>
  <header>
    <h2>Giải nghĩa</h2>

    <button on:click={() => (active = false)}>
      <AIcon name="x" />
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

      &:hover {
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

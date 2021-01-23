<script context="module">
  import { dict_lookup } from '$utils/api_calls'

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

  function is_active(from, upper, idx) {
    if (idx < from) return false
    return idx < upper
  }

  function render_zh(tokens, from, upper) {
    let output = ''
    let i = 0
    let p = 0

    for (const [key] of tokens) {
      if (key == '') continue
      let keys = key.split('')

      for (let j = 0; j < keys.length; j++) {
        output += '<x-v '
        if (is_active(from, upper, p)) output += 'class="_active" '

        const k = escape_html(keys[j])
        output += `data-k=${k} data-i=${i} data-p=${p} data-d=1>${k}</x-v>`
        p += 1
      }

      i += 1
    }

    return output
  }

  function render_hv(tokens, from, upper) {
    let output = ''
    let i = 0
    let p = 0

    for (const [key, val, dic] of tokens) {
      let key_chars = key.split('')
      let val_chars = val.split(' ')

      if (key_chars.length != val_chars.length) {
        output += val
        i += 1
        p += key_chars.length
        continue
      }

      for (let j = 0; j < key_chars.length; j++) {
        const key_char = key_chars[j]
        const val_char = val_chars[j]

        if (j > 0) output += ' '
        output += '<x-v '
        if (is_active(from, upper, p)) output += 'class=_active '

        output += `data-k=${escape_html(key_char)} `
        output += `data-i=${i} data-p=${p} data-d=${dic}>`
        output += `${escape_html(val_char)}</x-v>`
        p += 1
      }

      i += 1
    }

    return output
  }
</script>

<script>
  import SIcon from '$blocks/SIcon.svelte'
  import {
    lookup_input,
    lookup_dname,
    lookup_actived as actived,
    lookup_enabled as enabled,
  } from '$src/stores'

  $: [input, lower, upper] = $lookup_input

  export let on_top = false

  let hanviet = []
  let entries = []
  let current = []

  $: if (input) dict_lookup(input, $lookup_dname)
  $: if (lower < entries.length) update_focus()

  $: zh_html = render_zh(hanviet, lower, upper)
  $: hv_html = render_hv(hanviet, lower, upper)

  function update_focus() {
    if (entries.length < lower) {
      current = []
      upper = lower + 1
    } else {
      current = entries[lower]
      if (current.length == 0) upper = lower + 1
      else upper = lower + +current[0][0]
    }
  }

  function hanlde_click({ target }) {
    if (target.nodeName !== 'X-V') return
    lower = +target.dataset['p']
  }

  function handle_keydown(evt) {
    if (evt.keyCode == 27 && on_top) $actived = false
  }

  function fix_vietphrase(words) {
    let res = []
    for (let word of words) {
      if (word === '') res.push('<em>&lt;đã xoá&gt;</em>')
      else res.push(word)
    }
    return res.join('; ')
  }
</script>

<aside class:_active={$actived} tabindex="0" on:keydown={handle_keydown}>
  <header>
    <h2>Giải nghĩa</h2>

    <button on:click={() => ($actived = false)}>
      <SIcon name="eye-off" />
    </button>

    <button on:click={() => ($enabled = false)}>
      <SIcon name="x" />
    </button>
  </header>

  <section class="lookup">
    <div class="source _zh" on:click={hanlde_click} lang="zh">
      {@html zh_html}
    </div>

    <div class="source _hv" on:click={hanlde_click}>
      {@html hv_html}
    </div>

    {#each current as [size, entries]}
      <div class="entry">
        <h3 class="word" lang="zh">{input.substr(lower, size)}</h3>
        {#each Object.entries(entries) as [name, items]}
          {#if items.length > 0}
            <div class="item">
              <h4 class="name">{name}</h4>
              {#if name == 'vietphrase'}
                <p class="viet">
                  {@html fix_vietphrase(items)}
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
  $width: 30rem;

  aside {
    position: fixed;
    display: block;
    top: 0;
    right: 0;
    width: $width;
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
      flex-grow: 1;
      // padding: 0 0.375rem;
      font-weight: 500;
      text-transform: uppercase;
      line-height: $hd-height - 0.75rem;
      @include fgcolor(neutral, 6);
      @include font-size(sm);
    }

    button {
      // margin-right: 0.75rem;
      padding: 0 0.5rem;
      @include radius;
      @include fgcolor(neutral, 6);
      @include bgcolor(transparent);

      // &._active {
      //   @include fgcolor(primary, 6);
      //   @include bgcolor(neutral, 2);
      // }

      &:hover {
        @include fgcolor(primary, 6);
        @include bgcolor(neutral, 2);
      }
    }

    // button + button {
    //   margin-left: 0.375rem;
    // }
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

      &:hover,
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
    & + & {
      margin-top: 0.25rem;
    }
  }

  .term {
    line-height: 1.5rem;
    // margin-top: 0.25rem;
  }
</style>

<script context="module">
  export function parse(line) {
    return line.split('ǁ').map((x) => x.split('¦'))
  }

  export function render(nodes, rmode = 2) {
    let res = ''
    let idx = 0
    let pos = 0

    for (const [key, val, dic] of nodes) {
      const e_key = escape_html(key)
      const e_val = escape_html(val)

      if (rmode > 1) res += e_val
      else {
        switch (val.charAt(0)) {
          case '⟨':
            res += '<cite>'
            break
          case '“':
            res += '<em>'
            break
        }

        res += rmode < 1 ? e_val : render_node(e_key, e_val, dic, idx, pos)

        switch (val.charAt(val.length - 1)) {
          case '⟩':
            res += '</cite>'
            break
          case '”':
            res += '</em>'
            break
        }
      }

      idx += 1
      pos += key.length
    }

    return res
  }

  const escape_tags = {
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&apos;',
  }

  function replace_tag(tag) {
    return escape_tags[tag] || tag
  }

  function escape_html(str) {
    return str.replace(/[&<>]/g, replace_tag)
  }

  function render_node(key, val, dic, idx, pos) {
    return `<x-v data-k="${key}" data-d=${dic} data-i=${idx} data-p=${pos}>${val}</x-v>`
  }

  function make_bounds(nodes = [], idx = 0, min = 4, max = 10) {
    let output = ''

    for (let j = idx - 1; j >= 0; j--) {
      const [key] = nodes[j]
      output = key + output
      if (output.length >= min) break
    }

    const lower = output.length
    output += nodes[idx][0]
    const upper = output.length

    let limit = upper + min
    if (limit < max) limit = max

    for (let j = idx + 1; j < nodes.length; j++) {
      const [key] = nodes[j]
      output = output + key
      if (output.length > limit) break
    }

    return [output, lower, upper]
  }

  import {
    upsert_actived,
    upsert_input,
    upsert_d_idx,
    lookup_actived,
    lookup_input,
  } from '$src/stores'
</script>

<script>
  export let nodes = []
  export let rmode = 1

  export let index = -1
  export let hover = 0
  export let focus = 0

  export let cursor

  $: if (rmode < 2) rmode = index == hover || index == focus ? 0 : 1
  $: html_0 = render(nodes, 0)
  $: html_1 = render(nodes, 1)
  $: html_x = rmode > 0 ? html_0 : html_1

  function handle_click({ target }) {
    if (focus != index) focus = index
    if (target.nodeName != 'X-V') return
    const idx = +target.dataset.i

    upsert_input.set(make_bounds(nodes, idx))

    if (target === cursor) {
      upsert_d_idx.set(0)
      upsert_actived.set(true)
    } else {
      if (cursor) cursor.classList.remove('_focus')
      cursor = target
      cursor.classList.add('_focus')

      lookup_input.set(make_bounds(nodes, idx, 8, 20))
      lookup_actived.set(true)
    }
  }
</script>

<div on:mouseenter={() => (hover = index)} on:click={handle_click}>
  {@html html_x}
</div>

<style lang="scss">
  div {
    font-size: 1em;
  }

  @mixin mixed($color: blue) {
    cursor: pointer;
    position: relative;

    @include hover {
      @include fgcolor($color, 6);
    }

    div:hover & {
      @include border($color: $color, $shade: 3, $sides: bottom);
    }

    &._focus {
      @include fgcolor($color, 6);
    }
  }

  :global(x-v) {
    &[data-d='1'] {
      @include mixed(teal);
    }

    &[data-d='2'] {
      @include mixed(blue);
    }

    &[data-d='3'] {
      @include mixed(green);
    }

    &[data-d='9'] {
      @include mixed(gray);
    }

    // div.line > &._active {
    //   &:before {
    //     position: absolute;
    //     display: inline-block;
    //     content: attr(data-k);

    //     left: 0;
    //     top: -1.5em;
    //     width: 100%;
    //     text-align: center;
    //     overflow: hidden;

    //     font-size: 0.75em;
    //     line-height: 1.5em;
    //     font-style: normal;

    //     @include radius();
    //     @include fgcolor(neutral, 2);
    //     @include bgcolor(neutral, 7);
    //   }
    // }
  }
</style>

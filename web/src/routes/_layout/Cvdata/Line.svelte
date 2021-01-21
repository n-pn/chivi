<script context="module">
  export function render(nodes) {
    if (nodes.length == 0) return ['', '']

    let res_0 = ''
    let res_1 = ''

    let idx = 0
    let pos = 0

    let nest = 0

    for (const [key, val, dic] of nodes) {
      const e_key = escape_html(key)
      const e_val = escape_html(val).replace(/_/, '_\xAD') // force break words

      if (val.charAt(0) == '“') {
        nest += 1
        res_0 += '<em>'
        res_1 += '<em>'
      }

      res_0 += render_node(e_key, e_val, dic, idx, pos)
      res_1 += e_val

      const last = val.charAt(val.length - 1)
      if (last == '”') {
        nest -= 1
        res_0 += '</em>'
        res_1 += '</em>'
      }

      idx += 1
      pos += key.length
    }

    if (nest < 0) {
      res_0 = '<em>“' + res_0
      res_1 = '<em>“' + res_1
    } else if (nest > 0) {
      res_0 += '”</em>'
      res_1 += '”</em>'
    }

    return [res_0, res_1]
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
</script>

<script>
  export let nodes = []
  export let title = false
  export let frags = false

  $: [html_frag, html_nofrag] = render(nodes)
  $: content = frags ? html_frag : html_nofrag
</script>

{#if title}
  <h1 class="chivi">
    {@html content}
  </h1>
{:else}
  <p class="chivi">
    {@html content}
  </p>
{/if}

<style lang="scss">
  @mixin mixed($color: blue) {
    cursor: pointer;
    position: relative;

    &:hover {
      @include fgcolor($color, 6);
    }

    :global(.chivi):hover & {
      @include border($color: $color, $shade: 3, $sides: bottom);
    }

    &._focus {
      @include fgcolor($color, 6);
    }
  }

  .chivi {
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
    }
  }
</style>

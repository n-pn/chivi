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
      res_0 = '<em>' + res_0
      res_1 = '<em>' + res_1
    } else if (nest > 0) {
      res_0 += '</em>'
      res_1 += '</em>'
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

  $: [html_frag, html_nofrag] = render_html(nodes)
  $: content = frags ? html_frag : html_nofrag

  function render_html(nodes) {
    return render(nodes)
  }
</script>

{#if title}
  <h1 class="mtl">
    {@html content}
  </h1>
{:else}
  <p class="mtl">
    {@html content}
  </p>
{/if}

<style lang="scss">
  :global(.mtl) {
    --fgcolor: #{color(neutral, 8)};
    color: var(--fgcolor);

    @include tm-dark {
      --fgcolor: #{color(neutral, 3)};
    }
  }

  @mixin change-color($color: blue) {
    cursor: pointer;
    --border: #{color($color, 4)};
    --active: #{color($color, 6)};

    :global(.tm-dark) & {
      --border: #{color($color, 5)};
      --active: #{color($color, 3)};
    }
  }

  :global(x-v) {
    --border: transparent;
    --active: #{color(primary, 9)};

    color: var(--fgcolor);
    border-bottom: 1px solid transparent;

    .mtl:hover & {
      border-color: var(--border);
    }
  }

  :global(x-v:hover),
  :global(x-v.focus) {
    color: var(--active);
  }

  :global(x-v[data-d='1']) {
    @include change-color(teal);
  }

  :global(x-v[data-d='2']) {
    @include change-color(blue);
  }

  :global(x-v[data-d='3']) {
    @include change-color(green);
  }

  :global(x-v[data-d='9']) {
    @include change-color(gray);
  }
</style>

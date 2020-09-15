const tags = {
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&apos;',
}

function replace_tag(tag) {
  return tags[tag] || tag
}

function escape_html(str = '') {
  return str.replace(/[&<>]/g, replace_tag)
}

export function parse_content(body) {
  return body
    .split('\n')
    .map((line) => line.split('ǁ').map((x) => x.split('¦')))
}

export function render_convert(tokens, mode = 0) {
  let res = ''
  let idx = 0
  let pos = 0

  for (const [key, val, dic] of tokens) {
    const e_key = escape_html(key)
    const e_val = escape_html(val)

    if (mode > 0) {
      switch (e_val.charAt(0)) {
        case '⟨':
          res += '<cite>'
          break
        case '“':
          res += '<em>'
          break
      }
    }

    if (mode == 2) {
      res += `<x-v data-k="${e_key}" data-i=${idx} data-d=${dic} data-p=${pos}>${e_val}</x-v>`
    } else res += e_val

    if (mode > 0) {
      switch (e_val.charAt(0)) {
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

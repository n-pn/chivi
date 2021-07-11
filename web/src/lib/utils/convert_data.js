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
  const vp_data = []
  const zh_data = []

  const lines = body.split('\n')
  for (const line of lines) {
    let vp_line = []
    let zh_line = ''

    const words = line.split('ǁ')
    for (const word of words) {
      const term = word.split('¦')
      vp_line.push(term)
      zh_line += term[0]
    }

    vp_data.push(vp_line)
    zh_data.push(zh_line)
  }

  return [vp_data, zh_data]
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

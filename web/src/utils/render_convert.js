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

export default function render_convert(tokens, mode = 0, wrap = null) {
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

    // if (val === '⟨') body += '<cite>⟨'
    //       else if (val === '⟩') body += '⟩</cite>'
    //       else if (val === '[') body += '<x-m>['
    //       else if (val === ']') body += ']</x-m>'
    //       else if (val === '“') body += '<q>'
    //       else if (val === '”') body += '</q>'
    //       else if (val === '‘') body += '<i>‘'
    //       else if (val === '’') body += '’</i>'

    idx += 1
    pos += key.length
  }

  if (wrap) res = `<${wrap}>${res}</${wrap}>`
  return res
}

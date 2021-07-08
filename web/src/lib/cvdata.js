export function split_input(cvdata) {
  const lines = cvdata.split('\n').map((x) => x.trim())
  return lines.filter((x) => x).map((line) => split_cvline(line))
}

export function split_cvline(cvline) {
  return cvline.split('\t').map((x) => {
    const [key, val, tag, dic] = x.split('ǀ')
    return [key, val || '', tag || '', +dic]
  })
}

export function render_text(nodes) {
  let res = ''
  let lvl = 0

  for (const [_key, val] of nodes) {
    if (val.charAt(0) == '“') {
      lvl += 1
      res += '<em>'
    }

    res += escape_html(val)

    const last = val.charAt(val.length - 1)
    if (last == '”') {
      lvl -= 1
      res += '</em>'
    }
  }

  if (lvl < 0) {
    res = '<em>' + res
  } else if (lvl > 0) {
    res += '</em>'
  }

  return res
}

export function render_html(nodes) {
  let res = ''
  let lvl = 0
  let idx = 0
  let pos = 0

  for (const [key, val, tag, dic] of nodes) {
    const e_key = escape_html(key)
    const e_val = escape_html(val)

    if (val.charAt(0) == '“') {
      lvl += 1
      res += '<em>'
    }

    res += render_node(e_key, e_val, tag, dic, idx, pos)

    const last = val.charAt(val.length - 1)
    if (last == '”') {
      lvl -= 1
      res += '</em>'
    }

    idx += 1
    pos += key.length
  }

  if (lvl < 0) {
    res = '<em>' + res
  } else if (lvl > 0) {
    res += '</em>'
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
  if (!str) return ''
  return str.replace(/[&<>]/g, replace_tag)
}

function render_node(key, val, tag, dic, idx, pos) {
  return `<x-v data-k="${key}" data-t="${key}/${tag}" data-d=${dic} data-i=${idx} data-p=${pos}>${val}</x-v>`
}

export function ad_indexes(len, min = 15) {
  let res = []

  for (let idx = 0; idx < len; idx += random_int(min - 5, min + 5)) {
    res.push(idx)
  }

  return res
}

function random_int(min, max) {
  return Math.round(Math.random() * (max - min)) + min
}

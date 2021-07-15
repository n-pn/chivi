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

export function render(nodes, type = 'text') {
  let res = ''
  let lvl = 0
  let i = 0
  let p = 0

  for (const [key, val, tag, dic] of nodes) {
    if (tag == 'wyz') {
      lvl += 1
      res += '<em>'
    }

    if (type == 'text') {
      res += escape_html(val)
    } else {
      const k = escape_html(key)
      const v = escape_html(val)
      res += `<x-v data-k="${k}" data-t="${tag}" data-d=${dic} data-i=${i} data-p=${p}>${v}</x-v>`
    }

    if (tag == 'wyy') {
      lvl -= 1
      res += '</em>'
    }

    i += 1
    p += key.length
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

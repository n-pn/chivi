import cpos_info from './consts/cpos_info'

const escape_tags = { '&': '&amp;', '"': '&quot;', "'": '&apos;' }

function escape_htm(str: string) {
  return str.replace(/[&<>]/g, (x) => escape_tags[x] || x)
}

function capitalize(str: String) {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

const sort = (a: CV.Cvtree, b: CV.Cvtree) => a[2] - b[2]

export function gen_ztext_text(input: CV.Cvtree) {
  const stack = [input]

  let text = ''

  while (true) {
    const node = stack.pop()
    if (!node) break

    const body = node[4]

    if (Array.isArray(body)) {
      const orig = body.slice().sort(sort)
      for (let i = orig.length - 1; i >= 0; i--) stack.push(orig[i])
    } else {
      text += body
    }
  }

  return text
}

export function gen_ztext_html(ztext: string) {
  let html = ''

  for (let i = 0; i < ztext.length; i++) {
    html += `<x-z data-b=${i} data-e=${i + 1}>`
    html += escape_htm(ztext.charAt(i))
    html += `</x-z>`
  }

  return html
}

export function gen_hviet_text(input: string[], cap = false) {
  const text = input.join('').replace('\u200b', '').trim()
  return cap ? text : text.toLowerCase()
}

export function gen_hviet_html(input: string[], cap = true) {
  let html = ''
  let from = 0

  for (const vstr of input) {
    if (vstr.charAt(0) == ' ') html += ' '
    let vesc = escape_htm(vstr.substring(1))

    if (!cap) vesc = vesc.toLowerCase()
    html += `<x-n d=1 data-b=${from} data-e=${from + 1} >${vesc}</x-n>`

    from += 1
  }

  return html
}

export function gen_ctree_text(node: CV.Cvtree, level = 0, on_nl = false) {
  const cpos = node[0]
  const body = node[4]

  let text = ''

  if (on_nl) {
    text += '\n'
    for (let i = 0; i < level; i++) text += ' '
  }

  text += `(${cpos}`

  if (Array.isArray(body)) {
    const child_on_nl = body.length > 1 && !same_level_tags.includes(cpos)

    const orig = body.slice().sort(sort)
    for (let i = 0; i < orig.length; i++) {
      if (!child_on_nl) text += ' '
      text += gen_ctree_text(orig[i], level + 1, child_on_nl)
    }
  } else {
    text += ' ' + body
  }

  return text + ')'
}

const same_level_tags = [
  'VCD',
  'VRD',
  'VNV',
  'VPT',
  'VCP',
  'VAS',
  'DVP',
  'QP',
  'DNP',
  'DP',
  'CLP',
]

export function gen_ctree_html(node: CV.Cvtree, level = 0, on_nl = false) {
  const [cpos, _attr, from, upto, body, dnum] = node
  const dpos = dnum % 10
  // const lock = Math.floor(dnum / 10)

  let html = ''
  if (on_nl) {
    html = `<br/>`
    for (let i = 0; i < level; i++) {
      html += '&nbsp;&nbsp;'
    }
  }

  html += `<x-g l=${level % 8} data-b=${from} data-e=${upto}>`

  const { name } = cpos_info[cpos] || {}
  html += `<x-c data-tip="${name}" data-b=${from} data-e=${upto} data-c=${cpos}>${cpos}</x-c>`

  if (Array.isArray(body)) {
    const child_on_nl = body.length > 1 && !same_level_tags.includes(cpos)

    const orig = body.slice().sort(sort)
    for (let i = 0; i < orig.length; i++) {
      const child = orig[i]
      html += ' ' + gen_ctree_html(child, level + 1, child_on_nl)
    }
  } else {
    const vesc = escape_htm(body)
    html += ` <x-n d=${dpos} data-b=${from} data-e=${upto} data-c=${cpos}>${vesc}</x-n>`
    // html += ` <x-z d=${dpos} data-b=${from} data-e=${upto} data-c=${cpos}>${zesc}</x-z>`
  }

  html += '</x-g>'

  return html
}

const is_quote_start = (vstr: string) => /^“|‘|\[/.test(vstr)
const is_quote_final = (vstr: string) => /”|’|\]$/.test(vstr)

function render_mtl(vstr: string, cpos: string) {
  switch (cpos) {
    case 'EM':
      return `<x-em>${vstr}</x-em>`
    case 'URL':
      return `<a href="${vstr}" target=_blank rel=noreferrer>${vstr}</a>`
    default:
      return vstr
  }
}

/////////////
// if line contain quoted sentence then add cap to the first letter
// observe:
// - first element in list is quote start punctuation
// - last element in is is quote final punctuation and the element before it is also a punctuation
// - last element is some punctuation, this marks the end of sentence (without proper quote enclosure)
function should_add_cap(list: Array<CV.Cvtree>) {
  const head = list[0]
  if (head[0] != 'PU' || !is_quote_start(head[1])) return false

  const tail = list[list.length - 1]
  if (tail[0] != 'PU') return false

  return !is_quote_final(tail[1]) || list[list.length - 2][0] == 'PU'
}

export function gen_mt_ai_html(
  node: CV.Cvtree,
  opts = { mode: 1, cap: true, und: true, _qc: 0 },
  _lvl = 0
) {
  opts.cap ??= true
  opts.und ??= true
  opts._qc ??= 0

  const [cpos, attr, from, upto, body, dnum = 0] = node
  if (attr.includes('Hide')) return ''

  let html = ''

  if (Array.isArray(body)) {
    opts.cap ||= should_add_cap(body)

    for (let i = 0; i < body.length; i++) {
      html += gen_mt_ai_html(body[i], opts, _lvl + 1)
    }
  } else {
    if (body.charAt(0) == '⟨') {
      html += '<cite>'
    } else if (is_quote_start(body)) {
      html += '<em>'
      opts._qc += 1
    }

    if (!opts.und && !attr.includes('Undb')) html += ' '
    opts.und = attr.includes('Undn')

    const asis = /Capx|Asis/.test(attr)
    let vesc = escape_htm(body)

    if (opts.cap && !asis) vesc = capitalize(body)
    opts.cap = (opts.cap && asis) || attr.includes('Capn')

    if (opts.mode == 2) {
      const dtyp = dnum == 16 ? 7 : dnum % 10

      html += `<x-n d=${dtyp} data-b=${from} data-e=${upto} data-c=${cpos}>`
      html += render_mtl(vesc, cpos)
      html += `</x-n>`
    } else if (opts.mode == 1) {
      html += render_mtl(vesc, cpos)
    } else {
      html += vesc
    }

    if (body.charAt(0) == '⟩') {
      html += '</cite>'
    } else if (is_quote_final(body)) {
      html += '</em>'
      opts._qc -= 1
    }
  }

  if (_lvl == 0) {
    while (opts._qc < 0) {
      opts._qc += 1
      html = '<em>' + html
    }

    while (opts._qc > 0) {
      opts._qc -= 1
      html += '</em>'
    }
  }

  return html
}

export function gen_mt_ai_text(
  node: CV.Cvtree,
  opts = { cap: true, und: true },
  _raw = false
) {
  if (!node) return ''
  const [_pos, attr, _from, _upto, body] = node
  if (attr.includes('Hide')) return _raw ? body.toString() : ''

  let text = ''

  if (Array.isArray(body)) {
    opts.cap ||= should_add_cap(body)

    for (let i = 0; i < body.length; i++) {
      text += gen_mt_ai_text(body[i], opts)
    }
  } else {
    if (!opts.und && !attr.includes('Undb')) text += ' '
    opts.und = attr.includes('Undn')

    const asis = /Capx|Asis/.test(attr)

    text += opts.cap && !asis ? capitalize(body) : body
    opts.cap = (opts.cap && asis) || attr.includes('Capn')
  }

  return text
}

// export function find_node(input: CV.Cvtree, q_idx = 0, q_len = 0) {
//   const queue = [input]

//   while (true) {
//     const node = queue.pop()
//     if (!node) break

//     const [_cpos, n_idx, n_len, _attr, body] = node

//     if (n_idx < q_idx) continue
//     if (n_idx > q_idx || n_len < q_len) break

//     if (!Array.isArray(body)) {
//       if (n_len == q_len) return node
//     } else {
//       if (n_len == q_len && body.length > 1) return node
//       for (let i = body.length - 1; i >= 0; i--) queue.push(body[i])
//     }
//   }

//   return null
// }

export function flatten_tree(node: CV.Cvtree, list: CV.Cvtree[] = []) {
  list.push(node)
  const body = node[4]

  if (Array.isArray(body)) {
    for (const next of body) flatten_tree(next, list)
  }

  return list
}

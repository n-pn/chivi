import cpos_info from './consts/cpos_info'

const escape_tags = { '&': '&amp;', '"': '&quot;', "'": '&apos;' }

function escape_htm(str: string) {
  return str.replace(/[&<>]/g, (x) => escape_tags[x] || x)
}

function capitalize(str: String) {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

const sort = (a: CV.Cvtree, b: CV.Cvtree) => a[1] - b[1]

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

export function gen_ztext_html(
  ztext: string,
  hviet: Array<[string, string]> = []
) {
  let html = ''

  for (let i = 0; i < ztext.length; i++) {
    const [hstr] = hviet[i] || []

    html += `<x-z data-b=${i} data-e=${i + 1} data-tip="${hstr}">`
    html += escape_htm(ztext.charAt(i))
    html += `</x-z>`
  }

  return html
}

export function gen_hviet_text(hvarr: Array<[string, string]>, cap = false) {
  let text = ''
  let p_ws = false

  for (const [hstr, attr] of hvarr) {
    if (attr.includes('Hide')) continue

    if (p_ws && !attr.includes('Undb')) text += ' '
    p_ws = !attr.includes('Undn')

    const asis = /Capx|Asis/.test(attr)

    if (!cap || asis) text += hstr
    else text += capitalize(hstr)

    cap = (cap && asis) || attr.includes('Capn')
  }

  return text
}

export function gen_ctree_text([cpos, _idx, _len, _att, body]: CV.Cvtree) {
  let text = `(${cpos}`

  if (Array.isArray(body)) {
    const orig = body.slice().sort(sort)
    for (let i = 0; i < orig.length; i++) text += ' ' + gen_ctree_text(orig[i])
  } else {
    text += ' ' + body
  }

  return text + ')'
}

export function gen_ctree_html(node: CV.Cvtree, show_zh = true, level = 0) {
  const [cpos, from, zlen, _attr, body, vstr, dnum] = node
  const upto = from + zlen
  const dpos = dnum % 10
  // const lock = Math.floor(dnum / 10)

  let html = `<x-g l=${level % 8} data-b=${from} data-e=${upto}>`

  const { name } = cpos_info[cpos] || {}
  html += `<x-c data-tip="${name}" data-b=${from} data-e=${upto} data-c=${cpos}>${cpos}</x-c>`

  if (Array.isArray(body)) {
    const orig = body.slice().sort(sort)

    for (let i = 0; i < orig.length; i++) {
      html += ' ' + gen_ctree_html(orig[i], show_zh, level + 1)
    }
  } else {
    const zesc = escape_htm(body)
    const vesc = escape_htm(vstr)
    const [text, hint] = show_zh ? [zesc, vesc] : [vesc, zesc]

    html += ` <x-n d=${dpos} data-tip="${hint}" data-b=${from} data-e=${upto} data-c=${cpos}>${text}</x-n>`
  }

  return html + '</x-g>'
}

const is_quote_open = (vstr: string) => /^“|‘|\[/.test(vstr)
const is_quote_stop = (vstr: string) => /”|’|\]$/.test(vstr)

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

export function gen_vtran_html(
  node: CV.Cvtree,
  opts = { mode: 1, cap: true, und: true }
) {
  const [cpos, zidx, zlen, attr, body, vstr, vdic] = node
  if (attr.includes('Hide')) return ''

  let html = ''

  if (Array.isArray(body)) {
    const fvstr = body[0][5]
    const lvstr = body[body.length - 1][5]

    if (is_quote_open(fvstr) && is_quote_stop(lvstr)) {
      const near_last = body[body.length - 2]
      opts.cap ||= near_last[0] == 'PU'
    }

    for (let i = 0; i < body.length; i++) {
      html += gen_vtran_html(body[i], opts)
    }
  } else {
    if (!opts.und && !attr.includes('Undb')) html += ' '
    opts.und = attr.includes('Undn')

    const upto = zidx + zlen
    const dtyp = vdic % 10

    const fchar = vstr.charAt(0)

    if (fchar == '“' || fchar == '‘' || fchar == '[') {
      html = '<em>' + html
    } else if (fchar == '⟨') {
      html = '<cite>' + html
    }

    const asis = /Capx|Asis/.test(attr)

    let vesc = escape_htm(vstr)
    if (opts.cap && !asis) vesc = capitalize(vstr)

    opts.cap = (opts.cap && asis) || attr.includes('Capn')

    if (opts.mode == 2) {
      html += `<x-n d=${dtyp} data-b=${zidx} data-e=${upto} data-c=${cpos}>`
      html += render_mtl(vesc, cpos)
      html += `</x-n>`
    } else if (opts.mode == 1) {
      html += render_mtl(vesc, cpos)
    } else {
      html += vesc
    }

    const lchar = vstr.charAt(vstr.length - 1)

    if (lchar == '”' || lchar == '’' || lchar == ']') {
      html += '</em>'
    } else if (lchar == '⟩') {
      html += '</cite>'
    }
  }

  return html
}

export function gen_vtran_text(
  node: CV.Cvtree,
  opts = { cap: true, und: true }
) {
  const [_pos, zidx, zlen, attr, body, vstr, vdic] = node
  if (attr.includes('Hide')) return ''

  let text = ''

  if (Array.isArray(body)) {
    const fvstr = body[0][5]
    const lvstr = body[body.length - 1][5]

    if (is_quote_open(fvstr) && is_quote_stop(lvstr)) {
      opts.cap ||= body[body.length - 2][0] == 'PU'
    }

    for (let i = 0; i < body.length; i++) {
      text += gen_vtran_text(body[i], opts)
    }
  } else {
    if (!opts.und && !attr.includes('Undb')) text += ' '
    opts.und = attr.includes('Undn')

    const asis = /Capx|Asis/.test(attr)

    text += opts.cap && !asis ? capitalize(vstr) : vstr
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

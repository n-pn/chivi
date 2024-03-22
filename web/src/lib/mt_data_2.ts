import cpos_info from './consts/cpos_info'

const escape_tags = { '&': '&amp;', '"': '&quot;', "'": '&apos;' }

function escape_htm(str: string) {
  return str.replaceAll(/[&<>]/g, (x) => escape_tags[x] || x)
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
    html += `<x-z data-f=${i} data-u=${i + 1}>`
    html += escape_htm(ztext.charAt(i))
    html += `</x-z>`
  }

  return html
}

export function gen_hviet_text(input: string[], cap = false) {
  const text = input.join('').replaceAll('\u200b', '').trim()
  return cap ? text : text.toLowerCase()
}

export function gen_hviet_html(input: string[], cap = true) {
  let html = ''
  let from = 0

  for (const vstr of input) {
    if (vstr.charAt(0) == ' ') html += ' '
    let vesc = escape_htm(vstr.substring(1))

    if (!cap) vesc = vesc.toLowerCase()
    html += `<x-n d=4 data-f=${from} data-u=${from + 1} >${vesc}</x-n>`

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

const same_level_tags = ['VCD', 'VRD', 'VNV', 'VPT', 'VCP', 'VAS', 'DVP', 'QP', 'DNP', 'DP', 'CLP']

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

  html += `<x-g l=${level % 8} data-f=${from} data-u=${upto}>`

  const { name } = cpos_info[cpos] || {}
  html += `<x-c data-tip="${name}" data-f=${from} data-u=${upto} data-p=${cpos}>${cpos}</x-c>`

  if (Array.isArray(body)) {
    const child_on_nl = body.length > 1 && !same_level_tags.includes(cpos)

    const orig = body.slice().sort(sort)
    for (let i = 0; i < orig.length; i++) {
      const child = orig[i]
      html += ' ' + gen_ctree_html(child, level + 1, child_on_nl)
    }
  } else {
    const vesc = escape_htm(body)
    html += ` <x-n d=${dpos} data-f=${from} data-u=${upto} data-p=${cpos}>${vesc}</x-n>`
    // html += ` <x-z d=${dpos} data-f=${from} data-u=${upto} data-p=${cpos}>${zesc}</x-z>`
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
      return `<a href="${vstr}" target="_blank" rel="noreferrer">${vstr}</a>`
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

export function gen_mt_ai_text(list: CV.Mtnode[], _cap = true, _und = true, _raw = false) {
  let text = ''

  for (const node of list) {
    const body = node[0]
    if (typeof body == 'number') continue

    const attr = node[4]
    if (attr.includes('Hide')) {
      if (_raw) text += body
      continue
    }

    if (!_und && !attr.includes('Undb')) text += ' '
    _und = attr.includes('Undn')

    const asis = /Capx|Asis/.test(attr)
    text += _cap && !asis ? capitalize(body) : body
    _cap = (_cap && asis) || attr.includes('Capn')
  }

  return text
}

export function gen_mt_ai_html(list: CV.Mtnode[], mode = 2, _cap = true, _und = true) {
  let html = ''
  let _lvl = 0
  let _emc = 0

  for (const [body, from, upto, cpos, attr, dnum] of list) {
    if (typeof body == 'number') continue
    if (attr.includes('Hide')) continue

    if (body.charAt(0) == '⟨') {
      html += '<cite>'
    } else if (is_quote_start(body)) {
      html += '<em>'
      _emc += 1
    }

    if (!_und && !attr.includes('Undb')) html += ' '
    _und = attr.includes('Undn')

    const asis = /Capx|Asis/.test(attr)
    let vesc = escape_htm(body)

    if (_cap && !asis) vesc = capitalize(body)
    _cap = (_cap && asis) || attr.includes('Capn')

    if (mode == 2) {
      const dtyp = dnum == 16 ? 7 : dnum % 10
      html += `<x-n d=${dtyp} data-f=${from} data-u=${upto} data-p=${cpos}>`
      html += render_mtl(vesc, cpos)
      html += `</x-n>`
    } else if (mode == 1) {
      html += render_mtl(vesc, cpos)
    } else {
      html += vesc
    }

    if (body.charAt(0) == '⟩') {
      html += '</cite>'
    } else if (is_quote_final(body)) {
      html += '</em>'
      _emc -= 1
    }
  }

  if (_lvl == 0) {
    while (_emc < 0) {
      _emc += 1
      html = '<em>' + html
    }

    while (_emc > 0) {
      _emc -= 1
      html += '</em>'
    }
  }

  return html
}

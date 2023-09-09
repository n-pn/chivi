export type Cdata = [
  string,
  number,
  number,
  string,
  string | Array<Cdata>,
  string | null,
  number | null
]

const escape_tags = { '&': '&amp;', '"': '&quot;', "'": '&apos;' }

function escape_htm(str: string) {
  return str.replace(/[&<>]/g, (x) => escape_tags[x] || x)
}

function capitalize(str: String) {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

function skip_space(und = false, attr = '') {
  return und || attr.match(/Hide|Undb/)
}

function apply_cap(vstr: string, cap = false, attr = ''): [string, boolean] {
  if (attr.includes('Hide')) return ['', cap]
  if (attr.includes('Capx')) return [vstr, cap]
  if (attr.includes('Asis') || !cap) return [vstr, attr.includes('Capn')]
  return [capitalize(vstr), attr.includes('Capn')]
}

function render_vstr(vstr: string, cpos: string) {
  const safe_vstr = escape_htm(vstr)

  switch (cpos) {
    case 'EM':
      return `<pre>${safe_vstr}</pre>`
    case 'URL':
      return `<a href="${safe_vstr}" target=_blank rel=noreferrer>${safe_vstr}</a>`
    default:
      return safe_vstr
  }
}

export function render_ctree(input: Cdata, rmode = 1) {
  let out = ''

  const queue = [input]
  while (true) {
    const node = queue.pop()
    if (!node) break

    const [cpos, cidx, size, _attr, body, _vstr, vdic] = node

    if (rmode > 0) out += `<x-g i=${cidx} u=${cidx + size}>`

    out += `(${cpos} `

    if (Array.isArray(body)) {
      for (let i = body.length - 1; i >= 0; i--) queue.push(body[i])
    } else {
      out += body

      // if (rmode == 2) {
      //   out += `<x-n d=${body} b=${_idx} e=${_idx + _len}>`
      //   out += render_vstr(vstr2, cpos)
      //   out += `</x-n>`
      // } else if (rmode == 1) {
      //   out += render_vstr(vstr2, cpos)
      // } else {
      //   out += escape_htm(vstr2)
      // }
    }
    out += `)`

    if (rmode > 0) out += '</x-g>'
  }

  return out
}

export function render_cdata(input: Cdata, rmode = 1, cap = true) {
  let out = ''
  let und = true
  let lvl = 0

  const queue = [input]
  while (true) {
    const node = queue.pop()
    if (!node) break

    const [cpos, _idx, _len, attr, body, vstr, _dic] = node
    if (Array.isArray(body)) {
      for (let i = body.length - 1; i >= 0; i--) queue.push(body[i])
    } else {
      if (!skip_space(und, attr)) out += ' '
      const [vstr2, cap2] = apply_cap(vstr || '', cap, attr)
      cap = cap2
      und = attr.includes('Hide') ? und : attr.includes('Undn')

      if (rmode == 2) {
        out += `<x-n d=${_dic} b=${_idx} e=${_idx + _len}>`
        out += render_vstr(vstr2, cpos)
        out += `</x-n>`
      } else if (rmode == 1) {
        out += render_vstr(vstr2, cpos)
      } else {
        out += escape_htm(vstr2)
      }

      if (rmode > 0) {
        const fchar = vstr.charAt(0)
        if (fchar == '“' || fchar == '‘') {
          out = '<em>' + out
          lvl += 1
        } else if (fchar == '⟨') {
          out = '<cite>' + out
        }

        const lchar = vstr.charAt(vstr.length - 1)

        if (lchar == '”' || lchar == '’') {
          lvl -= 1
          out += '</em>'
        } else if (lchar == '⟩') {
          out += '</cite>'
        }
      }
    }
  }

  if (rmode > 0) {
    if (lvl < 0) for (; lvl; lvl++) out = '<em>' + out
    else if (lvl > 0) for (; lvl; lvl--) out += '</em>'
  }

  return out
}

export function find_node(input: Cdata, q_idx = 0, q_len = 0) {
  const queue = [input]

  while (true) {
    const node = queue.pop()
    if (!node) break

    const [_cpos, n_idx, n_len, _attr, body] = node

    if (n_idx < q_idx) continue
    if (n_idx > q_idx || n_len < q_len) break

    if (!Array.isArray(body)) {
      if (n_len == q_len) return node
    } else {
      if (n_len == q_len && body.length > 1) return node
      for (let i = body.length - 1; i >= 0; i--) queue.push(body[i])
    }
  }

  return null
}

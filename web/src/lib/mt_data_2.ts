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

const sort = (a: CV.Cvtree, b: CV.Cvtree) => a[1] - b[1]

export function render_ztext(input: CV.Cvtree, rmode = 1) {
  let out = ''

  const queue = [input]
  while (true) {
    const node = queue.pop()
    if (!node) break

    const [_cpos, zidx, zlen, _attr, body, _vstr, vdic] = node

    if (rmode > 1) {
      out += `<x-n data-d=${vdic % 10} data-b=${zidx} data-e=${zidx + zlen}>`
    }

    if (Array.isArray(body)) {
      const orig = body.slice().sort(sort)
      for (let i = orig.length - 1; i >= 0; i--) queue.push(orig[i])
    } else {
      if (rmode == 0) {
        out += body
      } else {
        for (let x = 0; x < body.length; x++) {
          const idx = zidx + x
          out += `<x-z data-d=${vdic % 10} data-b=${idx} data-e=${idx + 1}>`
          out += escape_htm(body.charAt(x))
          out += `</x-z>`
        }
      }
    }
    if (rmode > 1) out += '</x-n>'
  }

  return out
}

export function render_ctree(node: CV.Cvtree, rmode = 1, sbuff = '') {
  const [cpos, zidx, zlen, _attr, body, _vstr, vdic] = node

  if (rmode > 0) {
    sbuff += `<x-g data-b=${zidx} data-e=${zidx + zlen}>`
  } else {
    sbuff += `(${cpos} `
  }

  if (rmode > 1)
    sbuff += `<x-c data-b=${zidx} data-e=${zidx + zlen}>${cpos}</x-c> `

  if (Array.isArray(body)) {
    const orig = body.slice().sort(sort)

    for (let i = 0; i < orig.length; i++) {
      if (i) sbuff += ' '
      sbuff = render_ctree(orig[i], rmode, sbuff)
    }
  } else {
    if (rmode == 2) {
      for (let x = 0; x < body.length; x++) {
        const b = zidx + x
        sbuff += `<x-z data-d=${vdic % 10} data-b=${b} data-e=${b + 1}>`
        sbuff += escape_htm(body.charAt(x))
        sbuff += `</x-z>`
      }
    } else {
      sbuff += escape_htm(body)
    }
  }

  if (rmode > 0) sbuff += '</x-g>'
  else sbuff += `)`

  return sbuff
}

export function render_vdata(input: CV.Cvtree, rmode = 1, cap = true) {
  let out = ''
  let und = true
  let lvl = 0

  const queue = [input]
  while (true) {
    const node = queue.pop()
    if (!node) break

    let [cpos, zidx, zlen, attr, body, vstr, vdic] = node

    if (Array.isArray(body)) {
      for (let i = body.length - 1; i >= 0; i--) queue.push(body[i])
    } else {
      if (!skip_space(und, attr)) out += ' '

      if (!attr.includes('Hide')) {
        und = attr.includes('Undn')
        ;[vstr, cap] = apply_cap(vstr || '', cap, attr)
      }

      if (rmode == 2) {
        out += `<x-n data-d=${vdic % 10} data-b=${zidx} data-e=${zidx + zlen}>`
        out += render_vstr(vstr, cpos)
        out += `</x-n>`
      } else if (rmode == 1) {
        out += render_vstr(vstr, cpos)
      } else {
        out += escape_htm(vstr)
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

export function find_node(input: CV.Cvtree, q_idx = 0, q_len = 0) {
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

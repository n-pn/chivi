const escape_tags = { '&': '&amp;', '"': '&quot;', "'": '&apos;' }

function escape_html(str: string | null) {
  return str && str.replace(/[&<>]/g, (x) => escape_tags[x] || x)
}

export type Cdata = [
  string,
  number,
  number,
  string,
  number | Array<Cdata>,
  string | null,
  string | null
]

function no_pad_ws(und = false, attr = '') {
  return und || attr.match(/Hide|Undb/)
}

function capitalize(str: String) {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

function apply_cap(vstr: string, cap = false, attr = ''): [string, boolean] {
  if (attr.includes('Hide')) return ['', cap]
  if (attr.includes('Capx')) return [vstr, cap]
  if (attr.includes('Asis') || !cap) return [vstr, attr.includes('Capn')]
  return [capitalize(vstr), attr.includes('Capn')]
}

function render_vstr(vstr: string, cpos: string) {
  const safe_vstr = escape_html(vstr)

  switch (cpos) {
    case 'EM':
      return `<pre>${safe_vstr}</pre>`
    case 'URL':
      return `<a href="${safe_vstr}" target=_blank rel=noreferrer>${safe_vstr}</a>`
    default:
      return safe_vstr
  }
}

export function render_cdata(input: Cdata, plain = true, lvl = 0) {
  const queue = [input]

  let out = ''
  let cap = true
  let und = true

  while (true) {
    const node = queue.pop()
    if (!node) break

    const [cpos, _idx, _len, attr, body, vstr, zstr] = node
    if (Array.isArray(body)) {
      for (let i = body.length - 1; i >= 0; i--) queue.push(body[i])
    } else {
      if (!no_pad_ws(und, attr)) out += ' '
      const [vstr2, cap2] = apply_cap(vstr || '', cap, attr)
      cap = cap2
      und = attr.includes('Hide') ? und : attr.includes('Undn')

      const fchar = vstr.charAt(0)

      if (fchar == '“' || fchar == '‘') {
        out += '<em>'
        lvl += 1
      } else if (fchar == '⟨') {
        out += '<cite>'
      }

      if (plain) {
        out += render_vstr(vstr2, cpos)
      } else {
        const u = _idx + _len
        out += `<x-n d=${body} b=${_idx} e=${u}>`
        out += render_vstr(vstr2, cpos)
        out += `</x-n>`
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

  if (lvl > 0) for (; lvl; lvl--) out += '</em>'
  if (lvl < 0) for (; lvl; lvl++) out = '<em>' + out

  return out
}

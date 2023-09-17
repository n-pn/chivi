import { get, writable } from 'svelte/store'

import { render_ztext, render_vdata, split_hviet_vstr } from '$lib/mt_data_2'

interface Data {
  htree: CV.Cvtree
  vtree: CV.Cvtree

  zfrom: number
  zupto: number

  icpos: string
}

const init_data = {
  htree: ['', 0, 0, '', '', '', 0] as CV.Cvtree,
  vtree: ['', 0, 0, '', '', '', 0] as CV.Cvtree,

  zfrom: 0,
  zupto: 0,

  icpos: '',
}

function split_hviet_node(node: CV.Cvtree) {
  const [cpos, zidx, zlen, attr, body, hstr] = node

  const zstr = body as string
  const zval = Array.from(zstr)

  const hval = split_hviet_vstr(hstr, cpos, zlen)
  if (hval.length != zlen) console.log(`warning: not match: ${node}`)

  const list: Array<CV.Cvtree> = []

  for (let i = 0; i < zval.length; i++) {
    list.push([cpos, zidx + i, 1, attr, zval[i], hval[i], -1])
  }

  return list
}

function find_hviet_node(node: CV.Cvtree, lower = 0, upper = 0) {
  const [_cpos, from, zlen, _atrr, body] = node
  const upto = from + zlen

  if (from > lower || upto < upper) return node

  if (typeof body == 'string') {
    if (from == lower && upto == upper) {
      return node
    } else if (from >= lower || upto <= lower) {
      node[4] = split_hviet_node(node)
      return find_hviet_node(node, lower, upper)
    } else {
      return null
    }
  } else {
    let list: Array<CV.Cvtree> = []

    for (const child of body) {
      const [_cpos, from, zlen, _attr] = child
      const upto = from + zlen

      if (upto <= lower) continue
      if (from > upper) break

      if (from == lower && upto == upper) return child

      if (lower <= from && upto <= upper) {
        list.push(child)
        continue
      }

      const harr = split_hviet_node(child)
      list = list.concat(harr.slice(lower - from, upper - from))
    }

    return ['_', lower, upper, '', list, '', 0] as CV.Cvtree
  }
}

function find_vdata_node(node: CV.Cvtree, lower = 0, upper = 0, icpos = '') {
  const [cpos, from, zlen, _atrr, body] = node
  const upto = from + zlen

  if (from > lower || upto < upper) return null

  if (from == lower && upto == upper) {
    if (typeof body == 'string') return node
    if (icpos && icpos == cpos) return node
  }

  for (const child of body as Array<CV.Cvtree>) {
    const [_cpos, from, zlen, _attr] = child
    const upto = from + zlen

    if (from <= lower && upto >= upper) {
      return find_vdata_node(child, lower, upper, icpos)
    }
  }

  return from == lower && upto == upper ? node : null
}

function extract_term(input: Data): CV.Vtdata {
  const { htree, vtree, zfrom, zupto, icpos } = input

  const hnode = find_hviet_node(htree, zfrom, zupto)
  const vnode = find_vdata_node(vtree, zfrom, zupto, icpos)
  const hviet = render_vdata(hnode, 0, false)

  const zstr = render_ztext(hnode, 0)

  if (vnode) {
    const [cpos, _idx, _len, attr, _zh, _vi, dnum = 5] = vnode

    return {
      zstr: zstr,
      vstr: render_vdata(vnode, 0, false),
      cpos,
      attr,
      plock: Math.floor(dnum / 10),
      local: dnum % 2 == 1,
      hviet,
    }
  } else {
    return {
      zstr: zstr,
      vstr: hviet,
      cpos: '_',
      attr: '',
      plock: -1,
      local: true,
      hviet,
    }
  }
}

export const data = {
  ...writable<Data>(init_data),
  put(htree: CV.Cvtree, vtree: CV.Cvtree, zfrom = 0, zupto = -1, icpos = '') {
    if (zupto <= zfrom) zupto = htree[1] + htree[2]

    data.set({ htree, vtree, zfrom, zupto, icpos })
  },
  get_term(_from = -1, _upto = -1, _cpos = '?') {
    const input = { ...get(data) }
    if (_from >= 0) input.zfrom = _from
    if (_upto >= 0) input.zupto = _upto
    if (_cpos != '') input.icpos = _cpos

    return extract_term(input)
  },

  get_cpos(zfrom: number, zupto: number) {
    const input = get(data)
    return zfrom == input.zfrom && zupto == input.zupto ? input.icpos : ''
  },
}

export const ctrl = {
  ...writable({ actived: false, tab: 0 }),
  show: (tab = 0) => ctrl.set({ actived: true, tab }),
  hide: () => ctrl.set({ actived: false, tab: 0 }),
}

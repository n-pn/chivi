import { get, writable } from 'svelte/store'

import { gen_vtran_text, gen_hviet_text } from '$lib/mt_data_2'

interface Data {
  zline: string

  zfrom: number
  zupto: number
  icpos: string

  vtree: CV.Cvtree
  hvarr: Array<[string, string]>
}

const init_data = {
  zline: '',

  zfrom: 0,
  zupto: 0,
  icpos: '',

  vtree: ['', 0, 0, '', '', '', 0] as CV.Cvtree,
  hvarr: [] as Array<[string, string]>,
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
  const { zline, vtree, hvarr, zfrom, zupto, icpos } = input
  const zstr = zline.substring(zfrom, zupto)

  const vnode = find_vdata_node(vtree, zfrom, zupto, icpos)
  const hviet = gen_hviet_text(hvarr.slice(zfrom, zupto), false)

  if (vnode) {
    const [cpos, _idx, _len, attr, _zh, _vi, dnum = 5] = vnode

    return {
      zstr: zstr,
      vstr: gen_vtran_text(vnode, { cap: false, und: true }),
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
      cpos: 'X',
      attr: '',
      plock: -1,
      local: true,
      hviet,
    }
  }
}

export const data = {
  ...writable<Data>(init_data),
  put(
    zline: string,
    hvarr: Array<[string, string]>,
    vtree: CV.Cvtree,
    zfrom = 0,
    zupto = -1,
    icpos = ''
  ) {
    if (zupto <= zfrom) zupto = hvarr.length

    data.set({ zline, hvarr, vtree, zfrom, zupto, icpos })
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

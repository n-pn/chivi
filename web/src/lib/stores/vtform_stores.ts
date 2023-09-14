import { get, writable } from 'svelte/store'

import { render_ztext, render_vdata } from '$lib/mt_data_2'

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

function split_hviet_vstr(hstr: string, cpos: string, zlen: number) {
  if (cpos == 'PU' || hstr.length == zlen) return Array.from(hstr)

  const harr = hstr.split(' ')
  if (cpos == '_' || harr.length == zlen) return harr

  return hstr.split(' ').flatMap((x) => x.split(/\p{P}/u))
}

function split_hviet_node(node: CV.Cvtree) {
  const [cpos, zidx, zlen, attr, body, hstr] = node

  const zstr = body as string
  const zval = Array.from(zstr)

  const hval = split_hviet_vstr(hstr, cpos, zlen)
  if (hval.length != zlen) console.log(`warning: not match: ${node}`)

  const list: Array<CV.Cvtree> = []

  for (let i = 0; i < zval.length; i++) {
    list.push([cpos, zidx + i, 1, attr, zval[i], hval[i], 0])
  }

  return list
}

function find_hviet_node(node: CV.Cvtree, lower = 0, upper = 0) {
  console.log({ lower, upper })

  const [_cpos, from, zlen, _atrr, body] = node
  const upto = from + zlen

  if (from > lower || upto < upper) return null

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

function extract_term(input: Data) {
  const { htree, vtree, zfrom, zupto, icpos } = input
  const hnode = find_hviet_node(htree, zfrom, zupto)

  return {
    ztext: render_ztext(hnode, 0),
    hviet: render_vdata(hnode, 0, false),
  }
}

export const data = {
  ...writable<Data>(init_data),
  put(htree: CV.Cvtree, vtree: CV.Cvtree, zfrom = 0, zupto = -1, icpos = '') {
    if (zupto <= zfrom) zupto = htree[1] + htree[2]

    data.set({ htree, vtree, zfrom, zupto, icpos })
  },
  get_term(_from = -1, _upto = -1, _cpos = '') {
    const input = get(data)
    if (_from >= 0) input.zfrom = _from
    if (_upto >= 0) input.zupto = _upto
    if (_cpos != '') input.icpos = _cpos

    return extract_term(input)
  },
}

export const ctrl = {
  ...writable({ actived: false, tab: 0 }),
  show: (tab = 0) => ctrl.set({ actived: true, tab }),
  hide: () => ctrl.set({ actived: false, tab: 0 }),
}

export class VitermForm {
  // static from(key: string, dic: number = 0, privi = -1) {
  //   const term = { key, val: '', ptag: '', wseg: 2, dic, tab: 1 }
  //   return new CvtermForm(term, dic, privi)
  // }

  init: Partial<CV.Viterm>
  curr: Partial<CV.Viterm>

  _dic: number

  constructor(init: Partial<CV.Cvterm>, _dic = 1) {
    this.init = init
    this.curr = { ...init }
    this._dic = _dic
  }

  reset() {
    this.curr = { ...this.init }

    return this
  }

  clear() {
    this.curr.vstr = this.curr.vstr ? '' : '⛶'
    return this
  }

  changed() {
    if (!this.curr.vstr) return false

    const fields = ['vstr', 'cpos']

    for (const field of fields) {
      if (this[field] != this.init[field]) return true
    }

    return false
  }

  // get req_privi() {
  //   return req_privi(this.dic, this.tab)
  // }

  // toJSON(wn_id: number, input: string, index: number) {
  //   return JSON.stringify({
  //     key: this.key,
  //     val: this.val,
  //     ptag: this.ptag,
  //     prio: this.prio,
  //     dic: this.dic,
  //     _ctx: { wn_id, input, index },
  //   })
  // }
}

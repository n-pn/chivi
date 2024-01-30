import { flatten_tree, gen_mt_ai_text } from '$lib/mt_data_2'

import type { Rdline, Rdword } from '$lib/reader'

export const gen_mlist = (ctree: CV.Cvtree, from: number, upto: number) => {
  if (!ctree) return []
  const input = flatten_tree(ctree)

  let mlist = []

  for (const node of input) {
    if (node[2] <= from && node[3] >= upto) mlist.push(node)
  }

  if (mlist.length > 4) mlist = mlist.slice(mlist.length - 4)

  for (const node of input) {
    if (node[2] >= from && node[3] < upto) mlist.push(node)
  }

  return mlist.slice(0, 6)
}

export class Vtdata {
  vstr: string
  cpos: string
  attr: string

  lock: boolean
  d_no: number

  constructor(
    vstr: string,
    cpos: string,
    attr: string = '',
    dnum: number = -1
  ) {
    this.vstr = vstr
    this.cpos = cpos
    this.attr = attr

    this.lock = dnum >= 10
    this.d_no = dnum < 0 ? 0 : ((dnum % 10) / 2) | 0
  }
}

export function find_last<T>(input: T[], callback: (x: T) => boolean) {
  for (let i = input.length - 1; i >= 0; i--) {
    const item = input[i]
    if (callback(item)) return item
  }

  return undefined
}

export class Viform {
  finit: Vtdata
  fdata: Vtdata

  ztext: string
  hviet: string
  vtemp: string

  fresh: boolean

  constructor(mlist: CV.Cvtree[], rword: Rdword, ztext = '', hviet = '') {
    this.ztext = ztext
    this.hviet = hviet

    const { from, upto, cpos } = rword

    const vnode = find_last<CV.Cvtree>(mlist, (x) => {
      if (x[2] != from || x[3] != upto) return false
      return x[0] == cpos || cpos == 'X'
    })

    if (vnode) {
      const vstr = gen_mt_ai_text(vnode, { cap: false, und: true })
      const dnum = vnode[5] || -1
      this.finit = new Vtdata(vstr, vnode[0], vnode[1], dnum)
      this.fresh = dnum < 0 || dnum == 6 || dnum % 2 == 1
    } else {
      this.finit = new Vtdata(hviet, cpos)
      this.fresh = true
    }

    this.fdata = { ...this.finit, lock: false }
    this.vtemp = this.finit.vstr || hviet
  }

  // fix_lock(privi: number) {
  //   if (this.plock < 0) this.plock = privi > 0 ? 1 : 0
  //   else if (this.plock == 0 && privi > this.min_privi) this.plock = 1
  // }

  get zstr() {
    return this.ztext
  }

  get vstr() {
    return this.fdata.vstr
  }

  set vstr(vstr: string) {
    this.vtemp = this.fdata.vstr
    this.fdata.vstr = vstr
  }

  get attr() {
    return this.fdata.attr
  }

  set attr(attr: string) {
    this.fdata.attr = attr
  }

  get cpos() {
    return this.fdata.cpos
  }

  set cpos(cpos: string) {
    this.fdata.cpos = cpos
  }

  get lock() {
    return this.fdata.lock
  }

  set lock(lock: boolean) {
    this.fdata.lock = lock
  }

  get d_no() {
    return this.fdata.d_no
  }

  set d_no(d_no: number) {
    this.fdata.d_no = d_no
  }

  get min_privi() {
    return this.d_no - 1 // TODO: update after increase privi
  }

  get req_privi() {
    return this.min_privi + +this.lock
  }

  get state() {
    return !this.fdata.vstr ? 0 : this.fresh ? 1 : 2
  }

  get plock() {
    return this.fdata.lock ? 2 : this.finit.lock ? 1 : 0
  }

  reset() {
    if (this.fdata.vstr != this.vtemp) {
      this.fdata.vstr = this.vtemp
    } else if (this.fdata.vstr != this.finit.vstr) {
      this.fdata.vstr = this.finit.vstr
    } else {
      this.fdata = { ...this.finit, lock: false }
    }

    return this
  }

  clear() {
    if (this.fdata.vstr) {
      this.fdata.vstr = ''
    } else if (this.fdata.attr) {
      this.fdata.attr = ''
    } else {
      this.fdata.vstr = '⛶'
      this.fdata.attr = 'Hide'
    }

    return this
  }

  changed() {
    if (!this.fdata.vstr) return false

    for (const field in this.finit) {
      if (this[field] != this.finit[field]) return true
    }

    return false
  }

  toJSON(_ctx = {}) {
    return {
      zstr: this.zstr,
      vstr: this.vstr,

      cpos: this.cpos,
      attr: this.attr,

      lock: this.lock,
      d_no: this.d_no,

      _ctx,
    }
  }
}

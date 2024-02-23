import { gen_mt_ai_text } from '$lib/mt_data_2'

import type { Rdword } from '$lib/reader'
import { find_last } from '$utils/list_utils'

class Vtdata {
  vstr: string
  cpos: string
  attr: string
  rank: number
  lock: boolean
  d_no: number

  constructor(vstr: string, cpos: string, attr: string = '', dnum: number = -1) {
    this.vstr = vstr
    this.cpos = cpos
    this.attr = attr

    this.rank = dnum >= 300 ? 3 : 1
    this.lock = dnum % 100 >= 10
    this.d_no = dnum < 0 || dnum == 6 ? -1 : ((dnum % 10) / 2) | 0 % 3
  }
}

export class Viform {
  finit: Vtdata
  fdata: Vtdata

  ztext: string
  hviet: string
  vtemp: string

  constructor(mlist: CV.Mtnode[], rword: Rdword, ztext = '', hviet = '', privi = -1, pd_no = 3) {
    this.ztext = ztext
    this.hviet = hviet

    let cpos = rword.cpos
    let dnum = -1
    let attr = ''

    const vdata = mlist.filter((node) => {
      if (node[1] < rword.from || node[2] > rword.upto) return false
      if (node[1] != rword.from || node[2] != rword.upto) return true

      if (node[3] == rword.cpos || rword.cpos == 'X') {
        cpos = node[3]
        attr = node[4]
        dnum = node[5] || -1
      }

      return true
    })

    if (vdata.length > 0) {
      const vstr = gen_mt_ai_text(vdata, false)
      this.finit = new Vtdata(vstr, cpos, attr, dnum)
    } else {
      this.finit = new Vtdata(hviet, rword.cpos)
    }

    let d_no = this.finit.d_no

    if (pd_no < 3) d_no = pd_no
    else if (d_no < 0) d_no = rword.cpos == 'NR' || rword.cpos == 'NN' ? 1 : 2
    if (d_no > privi) d_no = privi > 0 ? privi : 0

    this.fdata = { ...this.finit, d_no, lock: false }
    this.vtemp = this.finit.vstr || hviet
  }

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
    return this.fdata.d_no
  }

  get req_privi() {
    return this.min_privi + +this.lock
  }

  get state() {
    return !this.fdata.vstr ? 0 : this.finit.d_no < 0 ? 1 : 2
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
      this.fdata.vstr = this.finit.vstr
      this.fdata.cpos = this.finit.cpos
      this.fdata.attr = this.finit.attr
    }

    return this
  }

  clear() {
    if (this.fdata.vstr) {
      this.fdata.vstr = ''
    } else if (this.fdata.attr) {
      this.fdata.attr = ''
    } else {
      this.fdata.vstr = '∅'
      this.fdata.attr = 'Hide'
    }

    return this
  }

  changed() {
    if (this.fdata.d_no < 0) return true

    for (const field in this.finit) {
      if (this[field] != this.finit[field]) return true
    }

    return false
  }

  fixed_cpos() {
    return this.fdata.rank == 3
  }
}

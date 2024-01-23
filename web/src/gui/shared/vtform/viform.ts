import type { Rdword } from '$lib/reader'

export interface Vtdata {
  vstr: string
  cpos: string
  attr: string

  plock: number
  local: boolean
}

export function find_last<T>(input: T[], callback: (x: T) => boolean) {
  for (let i = input.length - 1; i >= 0; i--) {
    const item = input[i]
    if (callback(item)) return item
  }

  return undefined
}

export class Viform {
  // static from(key: string, dic: number = 0, privi = -1) {
  //   const tform = { key, val: '', ptag: '', wseg: 2, dic, tab: 1 }
  //   return new CvtformForm(tform, dic, privi)
  // }

  rword: Rdword
  tinit: Vtdata
  tform: Vtdata

  ztext: string
  hviet: string
  vtemp: string

  constructor(
    rword: Rdword,
    tdata: Vtdata,
    ztext: string,
    hviet: string,
    privi = 0
  ) {
    this.rword = rword
    this.tinit = tdata
    this.tform = { ...tdata }
    this.ztext = ztext
    this.hviet = hviet
    this.vtemp = tdata.vstr || hviet

    this.fix_plock(privi)
    if (privi < this.min_privi) this.local = true
  }

  fix_plock(privi: number) {
    if (this.plock < 0) this.plock = privi > 0 ? 1 : 0
    else if (this.plock == 0 && privi > this.min_privi) this.plock = 1
  }

  get min_privi() {
    return this.local ? 0 : 1
  }

  get req_privi() {
    return this.min_privi + this.plock
  }

  get zstr() {
    return this.ztext
  }

  get vstr() {
    return this.tform.vstr
  }

  set vstr(vstr: string) {
    this.vtemp = this.tform.vstr
    this.tform.vstr = vstr
  }

  get attr() {
    return this.tform.attr
  }

  set attr(attr: string) {
    this.tform.attr = attr
  }

  get cpos() {
    return this.tform.cpos
  }

  set cpos(cpos: string) {
    this.tform.cpos = cpos
  }

  get local() {
    return this.tform.local
  }

  set local(local: boolean) {
    this.tform.local = local
  }

  get plock() {
    return this.tform.plock
  }

  set plock(plock: number) {
    this.tform.plock = plock
  }

  reset() {
    if (this.tform.vstr != this.vtemp) {
      this.tform.vstr = this.vtemp
    } else if (this.tform.vstr != this.tinit.vstr) {
      this.tform.vstr = this.tinit.vstr
    } else {
      this.tform = { ...this.tinit }
    }

    return this
  }

  clear() {
    if (this.tform.vstr) {
      this.tform.vstr = ''
    } else if (this.tform.attr) {
      this.tform.attr = ''
    } else {
      this.tform.vstr = '⛶'
      this.tform.attr = 'Hide'
    }

    return this
  }

  changed() {
    if (!this.tform.vstr) return false

    for (const field in this.tinit) {
      if (this[field] != this.tinit[field]) return true
    }

    return false
  }

  // get req_privi() {
  //   return req_privi(this.dic, this.tab)
  // }

  toJSON(ropts: Partial<CV.Rdopts>, vtree: string) {
    return {
      zstr: this.zstr,
      vstr: this.vstr,

      cpos: this.cpos,
      attr: this.attr,

      plock: this.plock,
      dname: this.local ? ropts.pdict : 'regular',

      _ctx: { ...ropts, vtree, zfrom: this.rword.from },
    }
  }
}

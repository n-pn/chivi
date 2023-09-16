export class Vtform {
  // static from(key: string, dic: number = 0, privi = -1) {
  //   const term = { key, val: '', ptag: '', wseg: 2, dic, tab: 1 }
  //   return new CvtermForm(term, dic, privi)
  // }

  init: CV.Vtdata
  curr: CV.Vtdata

  vtmp: string

  constructor(init: CV.Vtdata) {
    this.init = init
    this.curr = { ...init }

    this.vtmp = init.vstr
  }

  get vstr() {
    return this.curr.vstr
  }

  set vstr(vstr: string) {
    this.vtmp = this.curr.vstr
    this.curr.vstr = vstr
  }

  get attr() {
    return this.curr.attr
  }

  set attr(attr: string) {
    this.curr.attr = attr
  }

  get cpos() {
    return this.curr.cpos
  }

  set cpos(cpos: string) {
    this.curr.cpos = cpos
  }

  reset() {
    if (this.curr.vstr != this.vtmp) {
      this.curr.vstr = this.vtmp
    } else if (this.curr.vstr != this.init.vstr) {
      this.curr.vstr = this.init.vstr
    } else {
      this.curr = { ...this.init }
    }

    return this
  }

  clear() {
    if (this.curr.vstr) {
      this.curr.vstr = ''
    } else if (this.curr.attr) {
      this.curr.attr = ''
    } else {
      this.curr.vstr = '⛶'
      this.curr.attr = 'Hide'
    }

    return this
  }

  changed() {
    if (!this.curr.vstr) return false

    const fields = ['vstr', 'cpos', 'attr', 'plock', 'local']

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

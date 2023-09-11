import { get, writable } from 'svelte/store'

import { type Ctree, render_ztext } from '$lib/mt_data_2'

interface Data {
  tree: Ctree
  text: string
  from: number
  upto: number
  cpos: string
}

const init_data = {
  tree: undefined,
  text: '',
  from: 0,
  upto: 0,
  cpos: '',
}

export const data = {
  ...writable<Data>(init_data),
  from_data(tree: Ctree, text = '', from = 0, upto = text.length, cpos = '') {
    if (!text) text = render_ztext(tree, 0)
    if (!upto) upto = text.length
    data.set({ tree, text, from, upto, cpos })
  },
  get_zstr() {
    const { text, from, upto } = get(data)
    return text.substring(from, upto)
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

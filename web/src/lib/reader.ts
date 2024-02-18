import {
  gen_ztext_html,
  gen_hviet_text,
  gen_hviet_html,
  gen_mt_ai_html,
  gen_mt_ai_text,
  gen_ctree_html,
  gen_ctree_text,
} from '$lib/mt_data_2'
import { call_qtran } from '$utils/qtran_utils'

export class Rdword {
  from: number
  upto: number
  cpos: string

  constructor(from: number = 0, upto: number = 1, cpos: string = 'X') {
    this.from = from
    this.upto = upto
    this.cpos = cpos
  }

  match(from: number, upto: number, cpos: string) {
    if (from != this.from || upto != this.upto) return false
    return this.cpos == cpos || cpos == 'X'
  }

  copy() {
    return new Rdword(this.from, this.upto, this.cpos)
  }

  static from(node: HTMLElement) {
    if (!node) return new Rdword()
    const { b, e, c } = node.dataset
    return new Rdword(+b || 0, +e || 1, c || 'X')
  }
}

export class Rdline {
  ztext: string
  hviet: string[]

  trans: Record<string, string | CV.Cvtree>
  edits: string[]

  constructor(ztext: string) {
    this.ztext = ztext
    this.hviet = []

    this.trans = {}
    this.edits = []
  }

  text_get_fn(qkind: string, ropts = {}) {
    return async (rmode = 1) => {
      const qdata = await this.load_qtran(rmode, qkind, ropts)
      if (typeof qdata == 'string') return qdata
      return gen_mt_ai_text(qdata)
    }
  }
  html_get_fn(qkind: string, ropts = {}) {
    return async (rmode = 1) => {
      const qdata = await this.load_qtran(rmode, qkind, ropts)
      if (typeof qdata == 'string') return qdata
      return gen_mt_ai_html(qdata, { mode: 2, cap: true, und: true, _qc: 0 })
    }
  }

  async load_qtran(rmode = 1, qtype = 'qt_v1', ropts = {}) {
    const cached = this.trans[qtype]
    if (rmode == 0 || (rmode == 1 && cached)) return cached
    this.trans[qtype] = qtype.startsWith('mtl') ? ['', '', 0, 0, '', 0] : '...'

    const [qtran] = await call_qtran(this.ztext, qtype, ropts)
    this.trans[qtype] = qtran
    return qtran
  }

  get_ztext(from: number, upto: number) {
    return this.ztext.substring(from, upto)
  }

  get_hviet(from: number, upto: number) {
    if (this.hviet.length == 0) return ''
    const hviet = this.hviet.slice(from, upto)
    return gen_hviet_text(hviet)
  }

  get hviet_text() {
    if (this.hviet.length == 0) return ''
    return gen_hviet_text(this.hviet)
  }

  get hviet_html() {
    if (this.hviet.length == 0) return ''
    return gen_hviet_html(this.hviet)
  }

  get ztext_html() {
    if (!this.ztext) return ''
    return gen_ztext_html(this.ztext)
  }

  ctree_text(mtype = 'mtl_2') {
    const mdata = this.trans[mtype] as CV.Cvtree
    return mdata ? gen_ctree_text(mdata) : ''
  }

  ctree_html(mtype = 'mtl_2') {
    const mdata = this.trans[mtype] as CV.Cvtree
    return mdata ? gen_ctree_html(mdata) : ''
  }

  mtran_text(mtype = 'mtl_2') {
    const mdata = this.trans[mtype] as CV.Cvtree
    return mdata ? gen_mt_ai_text(mdata) : ''
  }

  mtran_html(mtype = 'mtl_2') {
    const mdata = this.trans[mtype] as CV.Cvtree
    return mdata ? gen_mt_ai_html(mdata, { mode: 2, cap: true, und: true, _qc: 0 }) : ''
  }

  qtran_text(qkind = 'qt_v1') {
    const qdata = this.trans[qkind]
    if (!qdata) return ''
    if (typeof qdata == 'string') return qdata
    return gen_mt_ai_text(qdata)
  }
}

export class Rdpage {
  lines: Rdline[]
  state: Record<string, boolean>
  track: Record<string, number>

  constructor(ztext: string) {
    let lines = ztext.split('\n').filter(Boolean)
    this.lines = lines.map((x) => new Rdline(x.trim()))
    this.state = {}
    this.track = {}
  }

  gen_rinit(cache: number, method = 'GET'): RequestInit {
    return {
      method,
      cache: cache == 2 ? 'no-cache' : 'force-cache',
      body: method == 'POST' ? this.lines.map((x) => x.ztext).join('\n') : undefined,
    }
  }

  get_ztext(l_idx: number) {
    return this.lines[l_idx].ztext
  }

  get_trans(qtype: string) {
    return this.lines.map(({ trans }) => trans[qtype])
  }

  get_texts(qtype: string) {
    return this.lines.map((x) => x.qtran_text(qtype))
  }

  get hviet() {
    return this.lines.map((x) => x.hviet)
  }

  async load_hviet(cache = 0) {
    if (cache == 0 || (cache == 1 && this.state['hviet'])) return

    const res = await fetch(`/_ai/hviet`, this.gen_rinit(cache, 'POST'))
    if (!res.ok) return

    const lines = await res.text().then((x) => x.split('\n'))
    const hviet = lines.map((x) => x.match(/[\s\u200b].[^\s\u200b]*/g))

    for (let i = 0; i < this.lines.length; i++) this.lines[i].hviet = hviet[i]
    this.state['hviet'] = true
  }

  async reload(needle: string, qkind = 'qt_v1', pdict = 'combine') {
    if (!needle) return

    let input = ''
    let l_ids = []

    for (let i = 0; i < this.lines.length; i++) {
      const { ztext, trans } = this.lines[i]
      if (trans[qkind] && ztext.includes(needle)) {
        l_ids.push(i)
        if (input) input += '\n'
        input += ztext
      }
    }

    const ropts = { pdict, h_sep: l_ids[0] == 0 ? 1 : 0 }
    const lines = await call_qtran(input, qkind, ropts)

    for (let i = 0; i < lines.length; i++) {
      this.lines[l_ids[i]].trans[qkind] = lines[i]
    }

    return l_ids
  }

  async load_more(qkind = 'qt_v1', pdict = 'combine') {
    const start = this.track[qkind] || 0
    const total = this.lines.length
    let new_start = start

    let input = ''
    let count = 0

    const limit = qkind == 'c_gpt' ? 300 : qkind.startsWith('mtl') ? 600 : 1200

    for (; new_start < total; new_start++) {
      const ztext = this.lines[new_start].ztext

      if (input) input += '\n'
      input += ztext
      count += ztext.length

      if (new_start + 5 < total && count > limit) break
    }

    console.log({ from: start, upto: new_start, size: count })

    const ropts = { pdict, h_sep: start == 0 ? 1 : 0 }
    const lines = await call_qtran(input.trim(), qkind, ropts)

    for (let i = 0; i < lines.length; i++) {
      this.lines[i + start].trans[qkind] = lines[i]
    }

    this.track[qkind] = new_start
    return new_start
  }
}

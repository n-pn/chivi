import {
  gen_ztext_html,
  gen_hviet_text,
  gen_hviet_html,
  gen_mt_ai_html,
  gen_mt_ai_text,
} from '$lib/mt_data_2'
import { call_qtran } from '$utils/qtran_utils'

export class Rdword {
  from: number
  upto: number
  cpos: string

  constructor(from: number = 0, upto: number = 0, cpos: string = 'X') {
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
    const { f, u, p } = node.dataset
    return new Rdword(+f || 0, +u || 0, p || 'X')
  }
}

export class Rdline {
  index: number
  ztext: string
  hviet: string[]

  trans: Record<string, string | CV.Mtnode[]>
  edits: string[]

  constructor(ztext: string, index: number = 0) {
    this.index = index
    this.ztext = ztext.replaceAll(/[\t\n]/g, '').trim()
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
      return gen_mt_ai_html(qdata, 2)
    }
  }

  async load_qtran(rmode = 1, qtype = 'qt_v1', ropts = {}) {
    const cached = this.trans[qtype]
    if (rmode == 0 || (rmode == 1 && cached)) return cached
    this.trans[qtype] = qtype.startsWith('mtl') ? [[0, 0, 0, '', '', 0]] : '...'

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

  // ctree_text(mtype = 'mtl_2') {
  //   const mdata = this.trans[mtype] as CV.Mtnode[]
  //   return mdata ? gen_ctree_text(mdata) : ''
  // }

  // ctree_html(mtype = 'mtl_2') {
  //   const mdata = this.trans[mtype] as CV.Mtnode[]
  //   return mdata ? gen_ctree_html(mdata) : ''
  // }

  mtran_text(mtype = 'mtl_2') {
    const mdata = this.trans[mtype] as CV.Mtnode[]
    return mdata ? gen_mt_ai_text(mdata) : ''
  }

  mtran_html(mtype = 'mtl_2') {
    const mdata = this.trans[mtype] as CV.Mtnode[]
    return mdata ? gen_mt_ai_html(mdata, 2) : ''
  }

  qtran_text(qkind = 'qt_v1') {
    const qdata = this.trans[qkind]
    if (!qdata) return ''
    if (typeof qdata == 'string') return qdata
    return gen_mt_ai_text(qdata)
  }
}

export class Rdpage {
  hviet_loaded: boolean

  lines: Rdline[]

  p_idx: number
  p_min: number
  p_max: number

  // p_min_map: Record<string, number>
  // p_idx_map: Record<string, number>

  constructor(ztext: string, p_idx: number = 0) {
    this.hviet_loaded = false
    this.lines = []

    for (let line of ztext.split('\n')) {
      line = line.replaceAll(/\s/g, '')
      if (line) this.lines.push(new Rdline(line, this.lines.length))
    }

    this.p_max = this.lines.length

    if (p_idx > this.p_max) p_idx = this.p_max - 5
    if (p_idx < 0) p_idx = 0

    this.p_min = p_idx
    this.p_idx = p_idx

    // this.p_min_map = {}
    // this.p_idx_map = {}
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

  get_vtran(l_idx: number, qkind: string) {
    const rline = this.lines[l_idx]
    return rline && rline.trans ? rline.trans[qkind] : ''
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
    if (cache == 0 || (cache == 1 && this.hviet_loaded)) return

    const res = await fetch(`/_ai/hviet`, this.gen_rinit(cache, 'POST'))
    if (!res.ok) return

    const lines = await res.text().then((x) => x.split('\n'))
    const hviet = lines.map((x) => x.match(/[\s\u200b].[^\s\u200b]*/g))

    for (let i = 0; i < this.lines.length; i++) this.lines[i].hviet = hviet[i]
    this.hviet_loaded = true
  }

  async reload(needle: string, qkind = 'qt_v1', pdict = 'combine', regen = 1) {
    if (!needle) return

    let texts = []
    let l_ids = []

    for (let i = 0; i < this.lines.length; i++) {
      const { index, ztext, trans } = this.lines[i]
      if (trans[qkind] && ztext.includes(needle)) {
        texts.push(ztext)
        l_ids.push(index)
      }
    }

    if (texts.length == 0) return []
    await this.qtran_slice(texts, l_ids, qkind, pdict, regen)
    return l_ids
  }

  async load_prev(qkind = 'qt_v1', pdict = 'combine', regen = 0) {
    // if (this.p_min <= 0) return 0

    let p_min = this.p_min
    let texts = []
    let l_ids = []
    let count = 0

    while (p_min > 1) {
      const rline = this.lines[p_min - 1]

      count += rline.ztext.length
      if (count > 600 && p_min > 2) break
      p_min -= 1

      if (rline.trans[qkind]) continue
      texts.unshift(rline.ztext)
      l_ids.unshift(rline.index)
    }

    if (texts.length > 0) {
      console.log({ type: 'load_prev', from: p_min, upto: this.p_min, size: count })
      await this.qtran_slice(texts, l_ids, qkind, pdict, regen)
    }

    this.p_min = p_min
    // this.p_min_map[qkind] = p_min
    return this.p_min
  }

  async load_more(qkind = 'qt_v1', pdict = 'combine', regen = 0) {
    let texts = []
    let l_ids = []

    const title = this.lines[0]

    if (!title.trans[qkind]) {
      texts.push(title.ztext)
      l_ids.push(title.index)
    }

    let p_idx = this.p_min > 0 ? this.p_min : 1
    let count = 0

    for (; p_idx < this.p_max; p_idx++) {
      const rline = this.lines[p_idx]

      if (p_idx >= this.p_idx || !rline.trans[qkind]) {
        count += rline.ztext.length
        if (count >= 600 && p_idx + 3 < this.p_max) break
      }

      if (rline.trans[qkind]) continue

      texts.push(rline.ztext)
      l_ids.push(rline.index)
    }

    if (texts.length > 0) {
      await this.qtran_slice(texts, l_ids, qkind, pdict, regen)
    }

    let p_min = this.p_idx < 6 ? 0 : this.p_idx
    this.p_idx = p_idx

    // this.p_idx_map[qkind] = p_idx

    // if (p_min > 30 && this.p_min < p_min - 30) {
    //   this.p_min = p_min - 30
    //   this.p_min_map[qkind] = this.p_min
    // }

    return p_min
  }

  async qtran_slice(texts: string[], l_ids: number[], qkind: string, pdict: string, regen: number) {
    const ropts = { pdict, h_sep: l_ids[0] == 0 ? 1 : 0, regen }

    const ztext = texts.join('\n')
    // console.log(`calling ${qkind} for lines: ${l_ids.length}, chars: ${ztext.length}`)

    const qdata = await call_qtran(ztext, qkind, ropts)
    for (let i = 0; i < qdata.length; i++) {
      this.lines[l_ids[i]].trans[qkind] = qdata[i]
    }
  }

  load_slice(qkind: string) {
    const p_min = this.p_min > 0 ? this.p_min : 1
    const p_idx = this.p_idx
    return p_min < p_idx ? this.lines.slice(p_min, p_idx) : []
  }

  // p_idx_of(qkind: string) {
  //   return this.p_idx_map[qkind] || 0
  // }
}

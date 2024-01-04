import { gtran_text } from '$utils/qtran_utils/gg_tran'
import { ms_api_key } from '$utils/qtran_utils/ms_tran'

import {
  gen_ztext_html,
  gen_hviet_text,
  gen_hviet_html,
  gen_mt_ai_html,
  gen_mt_ai_text,
  gen_ctree_html,
  gen_ctree_text,
} from '$lib/mt_data_2'

const call_qtran = async (
  body: string,
  type: string,
  opts = {},
  redo = false
) => {
  if (type == 'gg_zv') return await gtran_text(body)
  let url = `/_sp/qtran/${type}?redo=${redo}`

  if (type.startsWith('ms')) {
    url += `&opts=${await ms_api_key()}`
  } else if (type == 'qt_v1') {
    const wn_id = opts['wn_id'] || 0
    const title = opts['title'] || 1
    url += `&opts=${wn_id}:${title}`
  }

  const start = performance.now()

  const res = await fetch(url, { method: 'POST', body })
  if (!res.ok) return []
  const vtran = await res.text()

  const spent = performance.now() - start
  console.log(`- ${type}: ${body.length} chars, ${spent} milliseconds`)

  return vtran.trim().split('\n')
}

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

  mtran: Record<string, CV.Cvtree>
  qtran: Record<string, string>
  utran: string[]

  constructor(ztext: string) {
    this.ztext = ztext
    this.hviet = []

    this.mtran = {}
    this.qtran = {}
    this.utran = []
  }

  async load_mtran(rmode = 1, mtype = 'mtl_2', pdict = 'combine') {
    const cached = this.mtran[mtype]
    if (rmode == 0 || (rmode == 1 && cached)) return cached
    this.mtran[mtype] = ['', '', 0, 0, '', '', 0]

    const url = `/_ai/qtran?pdict=${pdict}&_algo=${mtype}`
    const res = await fetch(url, { method: 'post', body: this.ztext })
    if (!res.ok) return ['', '', 0, 0, '', '', 0]

    const { lines } = await res.json()
    this.mtran[mtype] = lines[0]

    return lines[0]
  }

  async load_qtran(rmode = 1, qtype = 'qt_v1', ropts = {}) {
    const cached = this.qtran[qtype]
    if (rmode == 0 || (rmode == 1 && cached)) return cached
    this.qtran[qtype] = '...'

    const lines = await call_qtran(this.ztext, qtype, ropts)
    this.qtran[qtype] = lines[0] || 'Không có dữ liệu!'

    return this.qtran[qtype]
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
    const mdata = this.mtran[mtype]
    return mdata ? gen_ctree_text(mdata) : ''
  }

  ctree_html(mtype = 'mtl_2') {
    const mdata = this.mtran[mtype]
    return mdata ? gen_ctree_html(mdata) : ''
  }

  mtran_text(mtype = 'mtl_2') {
    const mdata = this.mtran[mtype]
    return mdata ? gen_mt_ai_text(mdata) : ''
  }

  mtran_html(mtype = 'mtl_2') {
    const mdata = this.mtran[mtype]
    return mdata
      ? gen_mt_ai_html(mdata, { mode: 2, cap: true, und: true, _qc: 0 })
      : ''
  }
}

export class Rdpage {
  lines: Rdline[]
  state: Record<string, boolean>

  constructor(ztext: string) {
    this.lines = ztext.split('\n').map((x) => new Rdline(x))
    this.state = {}
  }

  get ztext() {
    return this.lines.map((x) => x.ztext)
  }

  get_ztext(l_idx: number) {
    return this.lines[l_idx].ztext
  }

  get_qtran(qtype: string) {
    return this.lines.map(({ qtran }) => qtran[qtype])
  }

  get_mtran(mtype: string) {
    return this.lines.map(({ mtran }) => mtran[mtype])
  }

  get hviet() {
    return this.lines.map((x) => x.hviet)
  }

  gen_rinit(cache: number, method = 'GET'): RequestInit {
    return {
      method,
      cache: cache == 2 ? 'no-cache' : 'force-cache',
      body: method == 'POST' ? this.ztext.join('\n') : undefined,
    }
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

  async load_qtran(cache = 0, qtype = 'qt_v1', ropts = {}) {
    if (cache == 0 || (cache == 1 && this.state[qtype])) {
      return this.get_qtran(qtype)
    }

    const lines = await call_qtran(this.ztext.join('\n'), qtype, ropts)
    if (lines.length == 0) return

    for (let i = 0; i < this.lines.length; i++) {
      this.lines[i].qtran[qtype] = lines[i]
    }

    this.state[qtype] = true
    return lines
  }

  async load_mtran(cache = 0, mtype = 'mtl_1', pdict = 'combine') {
    if (cache == 0 || (cache == 1 && this.state[mtype])) {
      return this.get_mtran(mtype)
    }

    const url = `/_ai/qtran?pdict=${pdict}&_algo=${mtype}`
    const res = await globalThis.fetch(url, this.gen_rinit(cache, 'POST'))

    const { lines } = await res.json()

    for (let i = 0; i < this.lines.length; i++) {
      this.lines[i].mtran[mtype] = lines[i]
    }

    this.state[mtype] = true
    return lines
  }
}

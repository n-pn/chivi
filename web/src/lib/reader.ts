import { btran_text } from '$utils/qtran_utils/btran_free'
import { call_baidu } from '$utils/qtran_utils/baidu_free'

import {
  gen_ctree_html,
  gen_ctree_text,
  gen_mt_ai_html,
  gen_ztext_html,
  gen_mt_ai_text,
  gen_hviet_text,
  gen_hviet_html,
} from '$lib/mt_data_2'

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

  mt_ai: CV.Cvtree

  qt_v1: string
  baidu: string

  bt_zv: string
  c_gpt: string
  vtran: string

  constructor(ztext: string) {
    this.ztext = ztext
    this.hviet = []
    this.mt_ai = undefined

    this.baidu = ''
    this.qt_v1 = ''
    this.bt_zv = ''
    this.c_gpt = ''
    this.vtran = ''
  }

  async load_c_gpt(rmode = 0) {
    const c_gpt = this.c_gpt

    if (c_gpt && rmode < 2) return this
    if (rmode == 0) return this

    const rinit = { method: 'POST', cache: 'default', body: this.ztext }
    const res = await fetch('/_sp/c_gpt', rinit as RequestInit)

    this.c_gpt = await res.text()
    return this
  }

  get_ztext(from: number, upto: number) {
    return this.ztext.substring(from, upto)
  }

  gen_ztext(word: Rdword) {
    return this.ztext.substring(word.from, word.upto)
  }

  get_hviet(from: number, upto: number) {
    if (!this.hviet) return ''

    const hviet = this.hviet.slice(from, upto)
    return gen_hviet_text(hviet)
  }

  get ztext_html() {
    if (!this.ztext) return ''
    return gen_ztext_html(this.ztext)
  }

  get ctree_text() {
    if (!this.mt_ai) return ''
    return gen_ctree_text(this.mt_ai)
  }

  get ctree_html() {
    if (!this.mt_ai) return ''
    return gen_ctree_html(this.mt_ai)
  }

  get mt_ai_text() {
    if (!this.mt_ai) return ''
    return gen_mt_ai_text(this.mt_ai)
  }

  get mt_ai_html() {
    if (!this.mt_ai) return ''
    return gen_mt_ai_html(this.mt_ai, { mode: 2, cap: true, und: true, _qc: 0 })
  }

  get hviet_text() {
    if (!this.hviet) return ''
    return gen_hviet_text(this.hviet)
  }

  get hviet_html() {
    if (!this.hviet) return ''
    return gen_hviet_html(this.hviet)
  }
}

interface Rstate {
  hviet: number
  mt_ai: number
  qt_v1: number
  baidu: number
  bt_zv: number
  c_gpt: number
  vtran: number
}

const init_data = {
  hviet: 0,
  mt_ai: 0,
  baidu: 0,
  qt_v1: 0,
  bt_zv: 0,
  c_gpt: 0,
  vtran: 0,
}

export class Rdpage {
  lines: Rdline[]
  ropts: CV.Rdopts
  state: Rstate
  tspan: Rstate
  mtime: Rstate

  constructor(ztext: string[], ropts: CV.Rdopts) {
    this.lines = ztext.map((x) => new Rdline(x))
    this.ropts = ropts

    this.state = { ...init_data }
    this.tspan = { ...init_data }
    this.mtime = { ...init_data }
  }

  get ztext() {
    return this.lines.map((x) => x.ztext)
  }

  get hviet() {
    return this.lines.map((x) => x.hviet)
  }

  set hviet(input: string[][]) {
    for (let i = 0; i < this.lines.length; i++) {
      this.lines[i].hviet = input[i]
    }
    this.state.hviet = 1
  }

  gen_rinit(cache: number): RequestInit {
    return { cache: cache == 2 ? 'no-cache' : 'force-cache' }
  }

  async load_hviet(cache = 0) {
    if (cache < 2 && this.state.hviet > 0) return this
    if (cache == 0) return this

    const url = `/_ai/qt/hviet?fpath=${this.ropts.fpath}`
    const res = await fetch(url, this.gen_rinit(cache))
    if (!res.ok) return this

    this.tspan.hviet = +res.headers.get('X-TSPAN')
    this.mtime.hviet = +res.headers.get('X-MTIME')

    const lines = await res.text().then((x) => x.split('\n'))
    const hviet = lines.map((x) => x.match(/[\s\u200b].[^\s\u200b]*/g))

    this.hviet = hviet || []
    return this
  }

  get baidu() {
    return this.lines.map((x) => x.baidu)
  }

  set baidu(input: string[]) {
    for (let i = 0; i < this.lines.length; i++) {
      this.lines[i].baidu = input[i]
    }

    this.state.baidu = 1
  }

  async load_baidu(cache = 0, force = false) {
    if (cache < 2 && this.state.baidu > 0) return this
    if (cache == 0 || this.lines.length == 0) return this

    const start = performance.now()
    const baidu = await call_baidu(this.ztext.join('\n'))

    if (baidu.length == this.lines.length) {
      this.baidu = baidu

      this.tspan.baidu = performance.now() - start
      this.mtime.baidu = new Date().getTime() / 1000

      return this
    }
  }

  get bt_zv() {
    return this.lines.map((x) => x.bt_zv)
  }

  set bt_zv(input: string[]) {
    for (let i = 0; i < this.lines.length; i++) {
      this.lines[i].bt_zv = input[i]
    }

    this.state.bt_zv = 1
  }

  async load_bt_zv(cache = 0, force = false) {
    if (cache < 2 && this.state.bt_zv > 0) return this
    if (cache == 0 || this.lines.length == 0) return this

    const start = performance.now()
    const bt_zv = await btran_text(this.ztext)

    if (bt_zv.length == this.lines.length) {
      this.bt_zv = bt_zv

      this.tspan.bt_zv = performance.now() - start
      this.mtime.bt_zv = new Date().getTime() / 1000

      return this
    }

    const url = `/_sp/btran?fpath=${this.ropts.fpath}&force=${force}`
    const res = await fetch(url, this.gen_rinit(cache))

    if (!res.ok) {
      this.bt_zv = []
      return this
    }

    const { lines, tspan, mtime } = await res.json()

    this.tspan.bt_zv = tspan
    this.mtime.bt_zv = mtime

    this.bt_zv = lines
    return this
  }

  get qt_v1() {
    return this.lines.map((x) => x.qt_v1)
  }

  set qt_v1(input: string[]) {
    for (let i = 0; i < this.lines.length; i++) {
      this.lines[i].qt_v1 = input[i]
    }
    this.state.qt_v1 = 1
  }

  async load_qt_v1(cache = 0, force = false) {
    if (cache < 2 && this.state.qt_v1 > 0) return this
    if (cache == 0) return this

    const { fpath, wn_id } = this.ropts

    if (!fpath) return this
    const zpath = encodeURIComponent(fpath)

    const url = `/_m1/qtran?fpath=${zpath}&wn_id=${wn_id}`
    const res = await fetch(url, this.gen_rinit(cache))

    if (!res.ok) {
      this.qt_v1 = []
      return this
    }

    const { lines, tspan, mtime } = await res.json()
    this.qt_v1 = lines

    this.tspan.qt_v1 = tspan
    this.mtime.qt_v1 = mtime

    return this
  }

  get mt_ai() {
    return this.lines.map((x) => x.mt_ai)
  }

  set mt_ai(input: CV.Cvtree[]) {
    if (input.length == 0) return

    for (let i = 0; i < this.lines.length; i++) {
      this.lines[i].mt_ai = input[i]
    }
    this.state.mt_ai = 1
  }

  async load_mt_ai(cache = 0, force = false) {
    if (cache == 0 || (cache < 1 && this.state.mt_ai > 0)) return this

    const { fpath, pdict, mt_rm } = this.ropts
    if (!fpath) return this

    const zpath = encodeURIComponent(fpath)
    const zdict = encodeURIComponent(pdict)

    const url = `/_ai/qtran?fpath=${zpath}&pdict=${zdict}&_algo=${mt_rm}&force=${force}`

    const res = await globalThis.fetch(url, this.gen_rinit(cache))

    if (!res.ok) {
      this.mt_ai = []
      return this
    }

    const { lines, tspan, mtime } = await res.json()
    this.mt_ai = lines

    this.tspan.mt_ai = tspan
    this.mtime.mt_ai = mtime

    return this
  }

  get c_gpt() {
    return this.lines.map((x) => x.c_gpt)
  }

  set c_gpt(input: string[]) {
    for (let i = 0; i < input.length; i++) {
      this.lines[i].c_gpt = input[i]
    }
  }

  get_ztext(l_idx: number) {
    return this.lines[l_idx].ztext
  }

  async get_c_gpt(l_idx: number, rmode = 0) {
    const focus = this.lines[l_idx]
    const c_gpt = focus.c_gpt

    if (c_gpt && rmode < 2) return c_gpt
    if (rmode == 0) return ''

    const rinit = { method: 'POST', cache: 'default', body: focus.ztext }
    const res = await fetch('/_sp/c_gpt', rinit as RequestInit)

    focus.c_gpt = await res.text()
  }

  get vtran() {
    return this.lines.map((x) => x.vtran)
  }

  set vtran(input: Record<number, string>) {
    for (const i in input) {
      this.lines[i].vtran = input[i]
    }
  }

  async reload(rmode: Partial<Rstate> = {}) {
    await this.load_hviet(rmode.hviet || 1)
    await this.load_qt_v1(rmode.qt_v1 || 1)
    this.load_bt_zv(rmode.bt_zv || 1)
    this.load_mt_ai(rmode.mt_ai || 1, false)
    return this
  }

  get_vtran() {
    const { rmode, qt_rm } = this.ropts
    if (rmode == 'mt' || qt_rm == 'mt_ai') {
      return this.mt_ai
    } else if (qt_rm == 'baidu') {
      return this.baidu
    } else if (qt_rm == 'bt_zv') {
      return this.bt_zv
    } else if (qt_rm == 'qt_v1') {
      return this.qt_v1
    } else {
      return []
    }
  }

  async load_vtran(cache = 1, force = true) {
    const { rmode, qt_rm } = this.ropts

    if (rmode == 'mt' || qt_rm == 'mt_ai') {
      // const rmode = mt_rm != this.ropts.mt_rm ? 2 : 1
      await this.load_mt_ai(cache, force)
      return this.mt_ai
    } else if (qt_rm == 'baidu') {
      await this.load_baidu(cache, force)
      return this.baidu
    } else if (qt_rm == 'bt_zv') {
      await this.load_bt_zv(cache, force)
      return this.bt_zv
    } else if (qt_rm == 'qt_v1') {
      await this.load_qt_v1(cache, force)
      return this.qt_v1
    }
  }
}

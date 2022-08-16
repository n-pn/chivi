export interface VpTermInit {
  vals?: string[]
  tags?: string[]
  prio?: string

  mtime?: number
  uname?: string
  state?: string
  _mode?: number

  h_vals: string[]
  h_tags: string[]

  h_fval: string
  h_ftag: string
}

export class VpTerm {
  init: VpTermInit

  vals: string[]
  tags: string[]
  prio: string = ''

  o_val: string = ''
  o_tag: string = ''

  _mode: number = 0
  _slot: number = 0

  constructor(init?: VpTermInit) {
    this.init = init || {
      h_vals: [],
      h_tags: [],
      h_fval: '',
      h_ftag: '',
    }

    this.init.state = this.init.state || 'Xoá'

    this.vals = Array.from(this.init.vals || [])
    this.tags = Array.from(this.init.tags || [])

    if (!this.vals[0]) this.vals[0] = this.init.h_fval
    if (!this.tags[0]) this.tags[0] = this.init.h_ftag

    this.prio = this.init.prio || ''

    this._mode = this.init._mode || 0
    this._slot = 0

    this.o_val = this.vals[0]
    this.o_tag = this.tags[0]
  }

  get val(): string {
    return this.vals[this._slot] || ''
  }

  get tag(): string {
    return this.tags[this._slot] || ''
  }

  set val(data: string) {
    this.vals[this._slot] = data
  }

  set tag(data: string) {
    this.tags[this._slot] = data
  }

  reset() {
    this.vals = this.init.vals
    this.tags = this.init.tags
    return this
  }

  clear() {
    if (this.vals[0]) this.vals = []
    else this.tags = []
    return this
  }

  get state() {
    if (!this.vals[0]) return ['Xoá', `_harmful`]
    return this.init.state != 'Xoá' ? ['Sửa', `_primary`] : ['Lưu', `_success`]
  }
}

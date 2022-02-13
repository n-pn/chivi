export interface VpTermInit {
  u_val: string
  b_val: string

  u_ptag: string
  b_ptag: string

  u_rank: number
  b_rank: number

  u_mtime: number
  u_state: string

  b_mtime: number
  b_state: string
  b_uname: string

  h_vals: string[]
  h_fval: string

  h_tags: string[]
  h_ptag: string
}

export class VpTerm {
  init: VpTermInit

  val: string = ''

  ptag: string = ''
  o_ptag: string = ''

  state: number = 0
  _priv: boolean = false

  rank: number = 3

  constructor(init?: VpTermInit) {
    this.init = init

    this.val = this.o_val
    this.state = init.u_val ? 2 : init.b_val ? 1 : 0

    if (init.u_val) {
      this._priv = true
      this.ptag = this.o_ptag = init.u_ptag || ''
      this.rank = init.u_rank || 3
    } else {
      this._priv = false
      this.ptag = this.o_ptag = init.b_ptag || init.h_ptag || ''
      this.rank = init.b_rank || 3
    }
  }

  get h_ptags() {
    const list = [this.init.b_ptag, this.init.u_ptag, ...this.init.h_tags]
    list.push(...similar_tag(this.ptag))

    return list
      .filter((x, i, s) => x && x != this.ptag && s.indexOf(x) == i)
      .slice(0, 2)
  }

  get o_val() {
    return this.init.u_val || this.init.b_val || this.init.h_fval || ''
  }

  reset() {
    this.val = this.o_val
    this.ptag = this.o_ptag
    return this
  }

  clear() {
    if (this.val) this.val = ''
    else if (this.ptag) this.ptag = ''
    else this.val = '[[pass]]'
    return this
  }

  swap_dict() {
    this._priv = !this._priv
    return this
  }

  get_state(_priv = this._priv) {
    const style = _priv ? '_line' : '_fill'
    if (!this.val) return ['Xoá', `${style} _harmful`]

    const o_val = _priv ? this.init.u_val : this.init.b_val
    return o_val ? ['Sửa', `${style} _primary`] : ['Lưu', `${style} _success`]
  }

  get changed() {
    if (this._priv) {
      if (this.val != this.init.u_val) return true
      if (this.ptag != this.init.u_ptag) return true
      if (this.rank != this.init.u_rank) return true
    } else {
      if (this.val != this.init.b_val) return true
      if (this.ptag != this.init.b_ptag) return true
      if (this.rank != this.init.b_rank) return true
    }

    return false
  }
}

function similar_tag(ptag: string) {
  switch (ptag) {
    case '_':
      return ['n', 'a', 'v']

    case 'ng':
    case 'nl':
    case 'np':
      return ['n']

    case 'nz':
      return ['nr', 'nn']

    case 'nn':
      return ['nr', 'nz']

    case 'n':
      return ['na', 't']

    case 'na':
      return ['n', 'an']

    case 'a':
      return ['b', 'an']

    case 'b':
      return ['a', 'n']

    case 'an':
      return ['a', 'na']

    case 'ad':
      return ['a', 'd']

    case 'ag':
      return ['a', 'k']

    case 'v':
      return ['vi', 'vn']

    case 'vd':
      return ['v', 'd']

    case 'vn':
      return ['v', 'n']

    case 'vi':
      return ['v', 'vo']

    case 'vg':
      return ['v', 'kv']

    case 'r':
    case 'rr':
    case 'ry':
    case 'rz':
      return ['rr', 'rz', 'ry']

    case 'al':
      return ['a', 'b']

    case 'vl':
      return ['al', 'nl']

    case 'i':
      return ['nl', 'al']

    case 'm':
    case 'q':
    case 'mp':
      return ['m', 'q', 'mq']

    case 'c':
    case 'cc':
    case 'd':
      return ['d', 'c', 'cc']

    case 'e':
    case 'y':
    case 'o':
      return ['e', 'y', 'o']

    case 'k':
    case 'ka':
    case 'kn':
    case 'kv':
      return ['ka', 'kn', 'kv']

    default:
      return ['n', 'v', 'a']
  }
}

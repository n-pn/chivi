export default class VpTerm {
  constructor(priv = { uname: '' }, main = { uname: '' }) {
    this._priv = priv
    this._main = main

    this.val = this.old = priv.val || main.val
    this.ptag = priv.ptag || main.ptag || ''
    this.rank = priv.rank || main.rank || 3
  }

  get state() {
    return !this.val ? 'Xoá' : this.old ? 'Sửa' : 'Thêm'
  }

  get fresh() {
    return !(this._priv.uname || this._main.uname)
  }

  clear() {
    this.val = ''
    // this.ptag = ''
    return this
  }

  reset() {
    this.val = this.old
    this.ptag = this._priv.ptag || this._main.ptag || ''
    return this
  }

  fix_val(new_val, force = false) {
    if (force || this.val == '') this.val = new_val
  }

  fix_ptag(new_ptag, force = false) {
    if (force || this.ptag == '') this.ptag = new_ptag
  }
}

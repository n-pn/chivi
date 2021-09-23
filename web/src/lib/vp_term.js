export default class VpTerm {
  constructor(term = {}) {
    this._raw = term

    this.val = this.old_val = (term.val || [''])[0]
    this.ptag = term.ptag || ''
    this.rank = term.rank || 3
  }

  get old_uname() {
    return this._raw.uname
  }

  get old_state() {
    return this._raw.state
  }

  get old_mtime() {
    return this._raw.mtime
  }

  get state() {
    return !this.val ? 'Xoá' : this.old_val ? 'Sửa' : 'Thêm'
  }

  get result() {
    return {
      key: this._raw.key,
      val: this.val.replace('', '').trim(),
      attr: this.ptag,
      rank: this.rank,
    }
  }

  clear() {
    this.val = ''
    // this.ptag = ''
    return this
  }

  reset() {
    this.val = this.old_val
    this.ptag = this._raw.ptag
    return this
  }

  fix_val(new_val, force = false) {
    if (force || this.val == '') this.val = new_val
  }

  fix_ptag(new_ptag, force = false) {
    if (force || this.ptag == '') this.ptag = new_ptag
  }
}

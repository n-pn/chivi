export default class VpTerm {
  constructor(term = {}, p_min = 1, p_max = 1) {
    this._raw = term

    this.val = this.old_val = (term.val || [''])[0]
    this.ptag = term.ptag || ''
    this.rank = term.rank || 3

    this.privi = p_min > term.privi ? p_min : term.privi
    if (this.privi > p_max) this.privi = p_max
  }

  get old_uname() {
    return this._raw.uname
  }

  get old_state() {
    return this._raw.state
  }

  get old_privi() {
    return this._raw.privi
  }

  get old_mtime() {
    return this._raw.mtime
  }

  get state() {
    return !this.val ? 'Xoá' : this._raw.val ? 'Sửa' : 'Thêm'
  }

  get result() {
    return {
      key: this._raw.key,
      val: this.val.replace('', '').trim(),
      attr: this.ptag,
      rank: this.rank,
      privi: this.privi,
    }
  }

  reset() {
    this.val = this.old_val
    this.ptag = this._raw.ptag
    return this
  }

  clear() {
    this.val = ''
    this.ptag = ''
    return this
  }

  fix_val(new_val, force = false) {
    if (force || !this.val) this.val = new_val
  }

  fix_ptag(new_ptag, force = false) {
    if (force || !this.ptag) this.ptag = new_ptag
  }
}

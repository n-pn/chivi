export class VpTerm {
  constructor(term = {}) {
    this._raw = term

    this.val = term.val
    this.ptag = term.ptag
    this.rank = term.rank
  }

  get state() {
    return !this.val ? 'Xoá' : this._raw.fresh ? 'Lưu' : 'Sửa'
  }

  get btn_state() {
    if (!this.val) return '_harmful'
    return this._raw.fresh ? '_success' : '_primary'
  }

  get changed() {
    return (
      this._raw.fresh ||
      this.val != this._raw.val ||
      this.ptag != this._raw.ptag ||
      this.rank != this._raw.rank
    )
  }

  clear() {
    this.val = ''
    // this.ptag = ''
    return this
  }

  reset() {
    this.val = this._raw.val
    this.ptag = this._raw.ptag
    return this
  }
}

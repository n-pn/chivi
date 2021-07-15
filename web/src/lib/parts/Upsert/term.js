export default class Term {
  constructor(term = {}, p_min = 1, p_max = 1) {
    this.key = term.key

    const val = term.val || []
    this.val = this.old_val = val[0] || ''

    this.ptag = this.old_ptag = term.ptag || ''
    this.rank = this.old_rank = term.rank || 3

    this.old_privi = term.privi || p_min
    this.old_state = term.state
    this.old_uname = term.uname
    this.old_mtime = term.mtime

    this.privi = p_min > term.privi ? p_min : term.privi
    if (this.privi > p_max) this.privi = p_max
  }

  get state() {
    return !this.val ? 'Xoá' : this.old_val ? 'Sửa' : 'Thêm'
  }

  get result() {
    return {
      key: this.key,
      val: this.val.replace('', '').trim(),
      attr: this.ptag,
      rank: this.rank,
      privi: this.privi,
    }
  }

  reset() {
    this.val = this.old_val
    this.ptag = this.old_ptag
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

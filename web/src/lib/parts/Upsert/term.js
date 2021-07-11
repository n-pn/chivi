export default class Term {
  constructor(term = {}, p_min = 1, p_max = 1) {
    this.key = term.key

    const val = term.val || []
    this.val = this.old_val = val[0] || ''

    this.tag = this.old_tag = term.tag || ''
    this.wgt = this.old_wgt = term.wgt || 3

    this.old_privi = term.privi || p_min
    this.old_state = term.state
    this.old_uname = term.uname
    this.old_mtime = term.mtime

    this.privi = p_min > term.privi ? p_min : term.privi
    if (this.privi > p_max) this.privi = p_max
  }

  get ext() {
    return this.tag == 3 ? this.tag : `${this.tag} ${this.wgt}`
  }

  get state() {
    return !this.val ? 'Xoá' : this.old_val ? 'Sửa' : 'Thêm'
  }

  get result() {
    return {
      key: this.key,
      val: this.val.replace('', '').trim(),
      ext: this.ext,
      privi: this.privi,
    }
  }

  reset() {
    this.val = this.old_val
    this.tag = this.old_tag

    return this
  }

  clear() {
    this.val = ''
    this.tag = ''

    return this
  }

  fix_val(new_val) {
    if (!this.val) this.val = new_val
  }

  fix_tag(new_tag) {
    if (!this.tag) this.tag = new_tag
  }
}

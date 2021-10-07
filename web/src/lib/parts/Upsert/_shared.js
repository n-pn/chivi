import { writable } from 'svelte/store'

export const fhint = writable('')

export function hint(node, msg) {
  const show = () => fhint.set(msg)
  const hide = () => fhint.set('')

  node.addEventListener('mouseenter', show, true)
  node.addEventListener('mouseleave', hide, true)

  return {
    destroy: () => {
      node.removeEventListener('mouseenter', show)
      node.removeEventListener('mouseleave', hide)
    },
  }
}

export class VpTerm {
  constructor(priv = {}, base = { mtime: -1 }) {
    this._priv = priv
    this._base = base

    this.val = this.old_val = this._priv.val || this._base.val || ''
    this.ptag = this.old_ptag = this._priv.ptag || this._base.ptag || ''
    this.rank = this._priv.rank || this._base.rank || 3
  }

  get fresh() {
    return this._priv.mtime < 0 && this._base.mtime < 0
  }

  get state() {
    return !this.val ? 'Xoá' : this.fresh ? 'Lưu' : 'Sửa'
  }

  get btn_state() {
    return !this.val ? '_harmful' : this.fresh ? '_success' : '_primary'
  }

  dirty(name) {
    return (
      this[name].mtime < 0 ||
      this.val != this[name].val ||
      this.ptag != this[name].ptag ||
      this.rank != this[name].rank
    )
  }

  clear() {
    if (this.val != '') {
      this.val = ''
      this.ptag = ''
    } else {
      this.val = '[[pass]]'
      this.ptag = '_'
    }

    return this
  }

  reset() {
    this.val = this.old_val
    this.ptag = this.old_ptag
    return this
  }
}

import { writable } from 'svelte/store'

export const fhint = writable('')

function get_rect(node) {
  const rects = node.getClientRects()
  return rects[rects.length - 1]
}

function get_place(target, parent) {
  const target_rect = get_rect(target)
  const parent_rect = get_rect(parent)

  let top = target_rect.bottom - parent_rect.top + 4
  let left = target_rect.left - parent_rect.left + target_rect.width / 2

  return [top, left]
}

export function hint(node, data) {
  const parent = document.querySelector('upsert-wrap') || node
  parent.style.position = 'relative'

  const tip = document.createElement('tool-tip')
  tip.innerText = data

  const show = () => {
    const [top, left] = get_place(node, parent)
    tip.style.top = top + 'px'
    tip.style.left = left + 'px'
    parent.appendChild(tip)
  }

  const hide = () => tip.remove()

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
    return this.old_val == '' || (this._priv.mtime < 0 && this._base.mtime < 0)
  }

  get state() {
    if (!this.val) return 'Xoá'
    return this._base.mtime < 0 || this._base.val == '' ? 'Lưu' : 'Sửa'
  }

  btn_state(type = '_base') {
    if (!this.val) return '_harmful'

    const blank = this.blank(type)
    if (type == '_base') return blank ? '_success' : '_primary'

    if (!blank) return '_primary'
    return this.blank('_base') ? '_success' : '_primary'
  }

  blank(type) {
    return this[type].mtime < 0 || this[type].val == ''
  }

  dirty(type) {
    return (
      this[type].mtime < 0 ||
      this.val != this[type].val ||
      this.ptag != this[type].ptag ||
      this.rank != this[type].rank
    )
  }

  disabled(type, privi, p_min) {
    if (privi < p_min) return true
    if (!this.dirty(type)) return true
    if (p_min < 3) return false
    return type != '_base'
  }

  clear() {
    if (this.val) this.val = ''
    else if (this.ptag) this.ptag = ''
    else {
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

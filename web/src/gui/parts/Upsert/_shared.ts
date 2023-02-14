function get_rect(node: HTMLElement) {
  const rects = node.getClientRects()
  return rects[rects.length - 1]
}

function get_place(target: HTMLElement, parent: HTMLElement) {
  const target_rect = get_rect(target)
  const parent_rect = get_rect(parent)

  let top = target_rect.bottom - parent_rect.top + 4
  let left = target_rect.left - parent_rect.left + target_rect.width / 2

  return [top, left]
}

export function hint(node: HTMLElement, data: string) {
  const parent = (document.querySelector('.upsert') as HTMLElement) || node
  parent.style.position = 'relative'

  const tip = document.createElement('tool-tip')
  tip.innerText = data

  const show = () => {
    const [top, left] = get_place(node, parent)
    tip.style.top = top + 'px'
    tip.style.left = left + 'px'
    parent.appendChild(tip)
  }

  // const hide = () => document.querySelector('tool-tip').remove()
  const hide = () => tip.remove()

  node.addEventListener('mouseenter', show, true)
  node.addEventListener('mouseleave', hide, true)

  // node.addEventListener('focus', show, true)
  node.addEventListener('blur', hide, true)

  return {
    update: (data: string) => (tip.innerText = data),
    destroy: () => {
      tip.remove()

      node.removeEventListener('mouseenter', show)
      node.removeEventListener('mouseleave', hide)

      // node.removeEventListener('focus', show)
      node.removeEventListener('blur', hide)
    },
  }
}

const mapping = [
  [0, 0],
  [-1, 0],
  [1, 0],
  [0, 1],
  [0, -1],
  [-2, 0],
  [0, 2],
  [-1, -1],
  [-1, 1],
  // [1, -1],
  // [1, 1],
]

export const related_words = (ztext: string, zfrom: number, zupto: number) => {
  return mapping.map(([x, y]) => ztext.substring(zfrom + x, zupto + y))
}

export class VpForm {
  init: Partial<CV.VpTerm>
  form: Partial<CV.VpTerm>

  static from(key: string, tab: number = 0, dic: number = 0) {
    const term = { key, tab, dic }
    return new VpForm(term)
  }

  constructor(init: Partial<CV.VpTerm>, val_hints = [], tag_hints = []) {
    init.val ||= val_hints[0] || ''
    init.ptag ||= tag_hints[0] || ''

    this.init = init
    this.form = Object.assign({}, init)

    this.init.state ||= 'Xoá'
  }

  get val(): string {
    return this.form.val || ''
  }

  get tag(): string {
    return this.form.ptag || ''
  }

  get prio(): number {
    return this.form.prio || 2
  }

  set val(data: string) {
    this.form.val = data
  }

  set tag(data: string) {
    this.form.ptag = data
  }

  set prio(data: number) {
    this.form.prio = data
  }

  reset() {
    this.form.val = this.init.val
    this.form.ptag = this.init.ptag
    return this
  }

  clear() {
    if (this.form.val) this.form.val = ''
    else this.form.ptag = ''
    return this
  }

  get state() {
    if (!this.form.val) return ['Xoá', `_harmful`]
    return this.init.state != 'Xoá' ? ['Sửa', `_primary`] : ['Lưu', `_success`]
  }
}

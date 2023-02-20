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
  return mapping
    .map(([x, y]) => ztext.substring(zfrom + x, zupto + y))
    .filter(Boolean)
}

export class VpForm {
  init: Partial<CV.VpTerm>

  static from(key: string, tab: number = 0, dic: number = 0) {
    const term = { key, tab, dic }
    return new VpForm(term, [], [], dic)
  }

  key: string
  val: string

  ptag: string
  prio: number

  dic: number = 0

  constructor(
    init: Partial<CV.VpTerm>,
    val_hints = [],
    tag_hints = [],
    dic = -4
  ) {
    this.dic = dic
    this.key = init.key

    this.init = Object.assign({}, init)
    this.init.state ||= 'Xoá'

    this.val = init.val || val_hints[0] || ''
    this.ptag = init.ptag || tag_hints[0] || ''
    this.prio = init.prio || 2
  }

  reset() {
    this.val = this.init.val || ''
    this.ptag = this.init.ptag || ''
    this.prio = this.init.prio || 2

    return this
  }

  clear() {
    if (this.val) this.val = ''
    else this.ptag = ''

    return this
  }

  get state() {
    if (!this.val) return ['Xoá', `_harmful`]
    return this.init.state != 'Xoá' ? ['Sửa', `_primary`] : ['Lưu', `_success`]
  }

  changed() {
    const fields = ['val', 'ptag', 'prio']

    for (const field of fields) {
      if (this[field] != this.init[field]) return true
    }

    return false
  }

  min_privi() {
    if (this.dic == -4 || this.dic > 0) return 0
    if (this.dic == -1 || this.dic == 10) return 1
    return 2
  }

  toJSON(ztext: string, zfrom: number) {
    const _ctx = `${ztext}:${zfrom}:${this.dic}`

    return JSON.stringify({
      key: this.key,
      val: this.val,
      ptag: this.ptag,
      prio: this.prio,
      dic: this.dic,
      _ctx,
    })
  }
}

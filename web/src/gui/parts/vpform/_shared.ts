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

export const req_privi = (dic: number, tab: number = 1) => {
  const privi = [0, 2, 1, 3][tab]
  return dic < 0 ? privi : privi - 1
}

export class CvtermForm {
  init: Partial<CV.Cvterm>

  static from(key: string, dic: number = 0, privi = -1) {
    const term = { key, val: '', ptag: '', wseg: 2, dic, tab: 1 }
    return new CvtermForm(term, dic, privi)
  }

  key: string
  val: string

  ptag: string
  prio: number

  dic: number = 0
  tab: number = 0

  constructor(init: Partial<CV.Cvterm>, wn_id = 0, privi = 0) {
    this.init = init

    this.key = init.key
    this.val = init.val
    this.ptag = init.ptag
    this.prio = init.prio

    if (privi < 1) {
      this.dic = wn_id
      this.tab = 2
    } else if (privi == 1) {
      this.dic = wn_id
      this.tab = 1
    } else {
      this.dic = this.init.dic
      this.tab = Math.abs(this.init.tab)
    }
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

  changed() {
    if (!this.val) return false
    if (this.init.id == 0) return true

    const fields = ['val', 'ptag', 'prio', 'dic', 'tab']

    for (const field of fields) {
      if (this[field] != this.init[field]) return true
    }

    return false
  }

  get req_privi() {
    return req_privi(this.dic, this.tab)
  }

  toJSON(wn_id: number, input: string, index: number) {
    return JSON.stringify({
      key: this.key,
      val: this.val,
      ptag: this.ptag,
      prio: this.prio,
      dic: this.dic,
      _ctx: { wn_id, input, index },
    })
  }
}

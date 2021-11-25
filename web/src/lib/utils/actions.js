export function get_rect(node) {
  const rects = node.getClientRects()
  return rects[rects.length - 1]
}

export function get_offset(target, parent) {
  const target_rect = get_rect(target)
  const parent_rect = get_rect(parent)

  let top = target_rect.bottom - parent_rect.top + 4
  let left = target_rect.left - parent_rect.left + target_rect.width / 2

  return [top, left]
}

export function tooltip(node, text) {
  const anchor = node.dataset.anchor || '#svelte'
  const parent = document.querySelector(anchor)
  parent.style.position = 'relative'

  const tip = document.createElement('tool-tip')
  tip.innerHTML = text

  const show = () => {
    const [top, left] = get_offset(node, parent)

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
    update: (text) => (tip.innerHTML = text),
    destroy: () => {
      node.removeEventListener('mouseenter', show)
      node.removeEventListener('mouseleave', hide)

      // node.removeEventListener('focus', show)
      node.removeEventListener('blur', hide)

      tip.remove()
    },
  }
}

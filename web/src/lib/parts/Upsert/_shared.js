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

  // const hide = () => document.querySelector('tool-tip').remove()
  const hide = () => tip.remove()

  node.addEventListener('mouseenter', show, true)
  node.addEventListener('mouseleave', hide, true)

  // node.addEventListener('focus', show, true)
  node.addEventListener('blur', hide, true)

  return {
    update: (data) => (tip.innerText = data),
    destroy: () => {
      tip.remove()

      node.removeEventListener('mouseenter', show)
      node.removeEventListener('mouseleave', hide)

      // node.removeEventListener('focus', show)
      node.removeEventListener('blur', hide)
    },
  }
}

export function enrich_term(data = {}) {
  data.val = data.o_val = data.u_val || data.b_val || data.h_val || ''
  data.state = data.u_val ? 2 : data.o_val ? 1 : 0

  if (data.u_val) {
    data._priv = true
    data.ptag = data.o_ptag = data.u_ptag || ''
    data.rank = data.u_rank || 3
  } else {
    data._priv = false
    data.ptag = data.o_ptag = data.b_ptag || data.h_ptag || ''
    data.rank = data.b_rank || 3
  }

  data.get_state = (_priv = data._priv) => {
    if (!data.val) return ['Xoá', '_harmful']
    const o_val = _priv ? data.u_val : data.b_val
    return o_val ? ['Sửa', '_primary'] : ['Lưu', '_success']
  }

  data.swap_dict = () => {
    data._priv = !data._priv
    return data
  }

  data.clear = () => {
    if (data.val) data.val = ''
    else if (data.ptag) data.ptag = ''
    else data.val = '[[pass]]'
    return data
  }

  data.reset = () => {
    data.val = data.o_val
    data.ptag = data.o_ptag
    return data
  }

  data.disabled = (privi) => {
    if (data._priv) {
      if (privi < data.u_privi) return true
      if (data.val != data.u_val) return false
      if (data.ptag != data.u_ptag) return false
      if (data.rank != data.u_rank) return false

      return true
    } else {
      if (privi < data.b_privi) return true
      if (data.val != data.b_val) return false
      if (data.ptag != data.b_ptag) return false
      if (data.rank != data.b_rank) return false

      return true
    }
  }

  return data
}

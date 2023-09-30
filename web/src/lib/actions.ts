import { get_client_rect } from '../utils/dom_utils'

export function get_offset(target: HTMLElement, parent: Element) {
  const target_rect = get_client_rect(target)
  const parent_rect = get_client_rect(parent)

  let top = target_rect.bottom - parent_rect.top + 4
  let left = target_rect.left - parent_rect.left + target_rect.width / 2

  return [top, left]
}

export function tooltip(node: HTMLElement, text: string) {
  const anchor = node.dataset.anchor || '#svelte'
  const parent = document.querySelector(anchor)

  if (!(parent instanceof HTMLElement)) return
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
    update: (text: string) => (tip.innerHTML = text),
    destroy: () => {
      node.removeEventListener('mouseenter', show)
      node.removeEventListener('mouseleave', hide)

      // node.removeEventListener('focus', show)
      node.removeEventListener('blur', hide)

      tip.remove()
    },
  }
}

// export function navigate(node: Element, { href = null, replace, scrollto }) {
//   const opts = { replaceState: replace, noscroll: !!scrollto }

//   const action = async (event: Event) => {
//     href = href || node.getAttribute('href')
//     await goto(href, opts)

//     event.preventDefault()
//     event.stopPropagation()

//     if (scrollto) {
//       const elem = document.querySelector(scrollto)
//       elem?.scrollIntoView({ block: 'start' })
//     }
//   }

//   if (!replace && !scrollto) return { destroy: () => {} } // return noop

//   node.addEventListener('click', action)
//   return { destroy: () => node.removeEventListener('click', action) }
// }

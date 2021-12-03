const fallback_rect = { left: 0, right: 0, bottom: 0, top: 0 }

export function get_client_rect(node) {
  if (!node) return fallback_rect
  const rects = node.getClientRects()
  return rects[0] || fallback_rect
}

export function scroll_into_view(child, parent, behavior = 'auto') {
  if (typeof child == 'string') {
    child = parent?.querySelector(child)
    if (!child) return
  }

  if (elem_in_viewport(child)) return
  child.scrollIntoView({ behavior, block: 'center' })
}

export function elem_in_viewport(elem) {
  const rect = elem.getBoundingClientRect()
  return rect.top > 0 && rect.bottom <= window.innerHeight
}

export function read_selection() {
  const selection = document.getSelection()
  if (selection.isCollapsed) return [null]

  const range = get_selected(selection.getRangeAt(0))
  // selection.removeAllRanges()

  const nodes = range.filter((x) => x.nodeName == 'V-N' || x.nodeName == 'Z-N')
  if (nodes.length == 0) return [null]

  let from = 99999
  let upto = 0

  for (const node of nodes) {
    // if (node.nodeType != 1) continue

    const lower = +node.dataset.l
    const upper = +node.dataset.u
    if (lower < from) from = lower
    if (upper > upto) upto = upper
  }

  if (from > upto) from = upto
  return [nodes, from, upto]
}

function get_selected(range) {
  let node = range.startContainer
  if (node.nodeName == 'CV-DATA') node = node.firstChild
  const stop = range.endContainer

  // Special case for a range that is contained within a single node
  if (node == stop) return [node]

  // Iterate nodes until we hit the end container
  const nodes = []
  while (node && node != stop) {
    node = next_node(node)
    if (node) nodes.push(node)
  }

  // Add partially selected nodes at the start of the range
  node = range.startContainer
  while (node && node != range.commonAncestorContainer) {
    nodes.unshift(node)
    node = node.parentNode
  }

  return nodes
}

// function next_node(node) {
//   if (node.hasChildNodes()) return node.firstChild

//   while (node && !node.nextElementSibling) node = node.parentNode
//   if (!node) return null
//   return node.nextSibling
// }

function next_node(node) {
  if (node.firstChild) return node.firstChild

  while (node) {
    if (node.nextElementSibling) return node.nextElementSibling
    else node = node.parentNode
  }

  return null
}

export function prev_elem(node, skip = false) {
  if (!node) return
  const name = node.nodeName

  while (!node.previousSibling) {
    node = node.parentNode
    if (node.nodeName == 'CV-DATA') return null
  }

  let prev = node.previousSibling
  while (prev && prev.nodeName != name) {
    prev = prev.nodeType == 1 ? prev.lastChild : prev.previousSibling
  }

  return skip && prev && +prev.dataset.d == 0 ? prev_elem(prev) : prev
}

export function next_elem(node, skip = false) {
  if (!node) return
  const name = node.nodeName

  while (!node.nextElementSibling) {
    node = node.parentNode
    if (node.nodeName == 'CV-DATA') return null
  }

  let next = node.nextSibling
  while (next && next.nodeName != name) {
    next = next.nodeType == 1 ? next.firstChild : next.nextSibling
  }

  return skip && next && +next.dataset.d == 0 ? next_elem(next) : next
}

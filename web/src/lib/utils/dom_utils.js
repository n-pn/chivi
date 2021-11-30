const fallback_rect = { left: 0, right: 0, bottom: 0, top: 0 }

export function get_client_rect(node) {
  if (!node) return fallback_rect

  const rects = node.getClientRects()
  return rects[rects.length - 1] || fallback_rect
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

  const nodes = get_selected(selection.getRangeAt(0))
  selection.removeAllRanges()
  if (nodes.length == 0) return [null]

  let from = 99999
  let upto = 0

  for (const node of nodes) {
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

  return nodes.filter((x) => x.nodeName == 'V-N' || x.nodeName == 'Z-N')
}

function next_node(node) {
  if (node.hasChildNodes()) return node.firstChild

  while (node && !node.nextSibling) node = node.parentNode
  if (!node) return null
  return node.nextSibling
}

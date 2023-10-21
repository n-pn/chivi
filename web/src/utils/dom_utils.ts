const fallback_rect = {
  left: 0,
  right: 0,
  bottom: 0,
  top: 0,
  width: 0,
  height: 0,
}

export function get_client_rect(node: Element | null) {
  if (!node) return fallback_rect
  const rects = node.getClientRects()
  return rects[0] || fallback_rect
}

export function scroll_into_view(
  child: Element | string,
  parent: Element | null | undefined,
  behavior: 'auto' | 'smooth' = 'auto'
) {
  if (typeof child == 'string') {
    child = parent?.querySelector(child)
    if (!child) return
  }

  if (elem_in_viewport(child)) return
  child.scrollIntoView({ block: 'center', behavior })
}

export function elem_in_viewport(elem: Element) {
  const rect = elem.getBoundingClientRect()
  return rect.top > 0 && rect.bottom <= window.innerHeight
}

export function read_selection(): Array<Element> {
  const selection = document.getSelection()
  if (selection.isCollapsed) return null

  const nodes = get_selected(selection.getRangeAt(0))

  navigator.clipboard.writeText(selection.toString())
  selection.removeAllRanges()

  return nodes.filter((x) => x.nodeName == 'V-N' || x.nodeName == 'Z-N')
}

function get_selected(range: Range) {
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

//   while (node && !node.nextElementSibling) node = node.parentElement
//   if (!node) return null
//   return node.nextSibling
// }

function next_node(node: Node) {
  if (node.firstChild) return node.firstChild

  while (node) {
    if (node.nextSibling) return node.nextSibling
    else node = node.parentNode
  }

  return null
}

export function prev_elem(node: Node) {
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

  return prev
}

export function next_elem(node: Node) {
  if (!node) return
  const name = node.nodeName

  while (!node.nextSibling) {
    node = node.parentNode
    if (node.nodeName == 'CV-DATA') return null
  }

  let next = node.nextSibling
  while (next && next.nodeName != name) {
    next = next.nodeType == 1 ? next.firstChild : next.nextSibling
  }

  return next
}

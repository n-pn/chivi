export default function read_selection() {
  const selection = document.getSelection()
  if (selection.isCollapsed) return [0, 0]

  const nodes = get_selected(selection.getRangeAt(0))
  if (nodes.length == 0) return [0, 0]

  let from = 99999
  let upto = 0

  for (const node of nodes) {
    const lower = +node.dataset.l
    const upper = +node.dataset.u
    if (lower < from) from = lower
    if (upper > upto) upto = upper
  }

  if (from > upto) from = upto
  return [from, upto]
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

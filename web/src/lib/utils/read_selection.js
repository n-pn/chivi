export default function read_selection() {
  const nodes = get_selected().filter((x) => x.nodeName == 'C-V')
  if (nodes.length == 0) return [0, 0]

  let lower = 99999
  let upper = 0
  for (const node of nodes) {
    const i = +node.dataset.i
    const j = i + +node.dataset.l
    if (i < lower) lower = i
    if (j > upper) upper = j
  }

  if (lower > upper) lower = upper
  return [lower, upper]
}

function get_selected() {
  const selection = document.getSelection()
  if (selection.isCollapsed) return []

  const range = selection.getRangeAt(0)

  let node = range.startContainer
  const stop = range.endContainer

  // Special case for a range that is contained within a single node
  if (node == stop) return [node]

  // Iterate nodes until we hit the end container
  let nodes = []
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

function next_node(node) {
  if (node.hasChildNodes()) return node.firstChild

  while (node && !node.nextSibling) node = node.parentNode
  if (!node) return null
  return node.nextSibling
}

export default function read_selection() {
  const selected = get_selected()

  let nodes = selected.filter((x) => x.nodeName == 'X-V')
  if (nodes.length == 0) nodes = selected.filter((x) => x.nodeName == 'C-V')
  nodes = nodes.map((x) => x.dataset.k).filter((x) => x)

  if (nodes.length == 0) return

  let input = ''
  let lower = 0
  let upper = 0

  let idx = 0
  let pos = 0

  for (; idx < nodes.length; idx++) {
    const key = nodes[idx]

    input += key
    pos += key.length
  }

  lower = pos

  for (; idx < nodes.length; idx++) {
    const key = nodes[idx]
    input += key
    pos += key.length
  }

  return [input, lower, upper]
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

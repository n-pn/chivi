export default function read_selection() {
  const nodes = get_selected()

  let res = ''
  let idx = 0

  for (; idx < nodes.length; idx++) {
    const node = nodes[idx]
    const name = node.nodeName

    if (name === 'X-Z') break
    else if (name === 'X-V') {
      const dic = +node.dataset.d
      const key = node.dataset.k
      if (dic > 0 || key === '的' || key === '') break
    }
  }

  for (; idx < nodes.length; idx++) {
    const node = nodes[idx]
    const name = node.nodeName

    if (name === 'X-V') {
      const dic = +node.dataset.d
      const key = node.dataset.k
      if (dic > 0 || key === '的' || key === '') res += key
      else break
    } else if (name === 'X-Z') res += node.textContent.trim()
    else if (name !== '#text') break
  }

  return res
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

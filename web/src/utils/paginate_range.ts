export default function paginate_range(caret = 1, total = 1, limit = 5) {
  const output = [[caret, 0]]

  let from = caret - 1
  let upto = caret + 1
  let level = 1

  while (from >= 1 || upto <= total) {
    if (output.length >= limit) break

    if (from >= 1) output.unshift([from--, level])
    else if (upto <= total) output.push([upto++, level])

    if (upto <= total) output.push([upto++, level])
    else if (from >= 1) output.unshift([from--, level])

    level += 1
  }

  // console.log({ output })
  return output
}

// paginate_range(10, 20, 5)
// paginate_range(1, 20, 5)

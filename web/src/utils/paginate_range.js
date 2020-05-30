export default function paginate_range(focus, total, limit = 5) {
  const output = [[focus, 0]]

  let left = focus - 1
  let right = focus + 1
  let level = 1

  while (left > 1 || right < total) {
    if (output.length >= limit) break

    if (left > 1) output.unshift([left--, level])
    else if (right < total) output.push([right++, level])

    if (right < total) output.push([right++, level])
    else if (left > 1) output.unshift([left--, level])

    level += 1
  }

  // console.log({ output })
  return output
}

// paginate_range(10, 20, 5)
// paginate_range(1, 20, 5)

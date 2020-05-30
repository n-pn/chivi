export default function paginate_range(currPage, pageMax) {
  let pageFrom = currPage - 2
  if (pageFrom < 1) pageFrom = 1

  let pageUpto = pageFrom + 4
  if (pageUpto > pageMax) {
    pageUpto = pageMax
    pageFrom = pageUpto - 4
    if (pageFrom < 1) pageFrom = 1
  }

  // console.log({ pageFrom, pageUpto })
  let output = []
  for (let i = pageFrom; i <= pageUpto; i++) output.push(i)
  return output
}

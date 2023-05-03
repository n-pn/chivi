type Payback = { like_count: number; memo_liked: number }

type Callback = (data: Payback) => void

export const toggle_like = async (
  type: string,
  o_id: number,
  liked: number,
  callback: Callback
) => {
  const action = liked > 0 ? 'unlike' : 'like'

  const path = `/_db/memos/${type}/${o_id}/${action}`
  const resp = await fetch(path, { method: 'PUT' })

  if (!resp.ok) alert(await resp.text())
  else callback((await resp.json()) as Payback)
}

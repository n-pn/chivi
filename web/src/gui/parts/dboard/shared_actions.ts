export async function toggle_like(
  memoir: CV.Memoir,
  target: CV.Dtopic | CV.Rpnode,
  type: string
) {
  const action = memoir.liked > 0 ? 'unlike' : 'like'

  const api_url = `/_db/memos/${type}/${target.id}/${action}`
  const api_res = await fetch(api_url, { method: 'PUT' })

  if (!api_res.ok) {
    alert(await api_res.text())
  } else {
    const { like_count, memo_liked } = await api_res.json()
    target.like_count = like_count
    memoir.liked = memo_liked
  }
}

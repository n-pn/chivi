export const mark_rdchap = async (
  rmemo: CV.Rdmemo,
  rdata: CV.Chpart,
  ropts: CV.Rdopts,
  mtype = -1
) => {
  rmemo.rmode = ropts.rmode
  rmemo.qt_rm = ropts.qt_rm
  rmemo.mt_rm = ropts.mt_rm

  if (is_new_chmark(mtype, rmemo, rdata)) {
    if (mtype >= 0) rmemo.lc_mtype = mtype

    rmemo.lc_ch_no = rdata.ch_no
    rmemo.lc_p_idx = rdata.p_idx
    rmemo.lc_title = rdata.title
  }

  return await upsert_memo(rmemo, 'chmark')
}

function is_new_chmark(mtype: number, rmemo: CV.Rdmemo, rdata: CV.Chpart) {
  if (rmemo.lc_mtype < 1) return true
  if (rmemo.lc_mtype > 1) return mtype >= 0
  return rdata.ch_no == rmemo.lc_ch_no || rdata.ch_no == rmemo.lc_ch_no + 1
}

export const upsert_memo = async (rmemo: CV.Rdmemo, action: string) => {
  const rinit = {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(rmemo),
  }

  const res = await fetch(`/_rd/rdmemos/${action}`, rinit)
  if (res.ok) {
    return (await res.json()) as CV.Rdmemo
  } else {
    alert(await res.text())
    return rmemo
  }
}

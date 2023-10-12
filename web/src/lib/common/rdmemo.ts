export const mark_rdchap = async (
  rmemo: CV.Rdmemo,
  rdata: CV.Chpart,
  ropts: CV.Rdopts,
  force: boolean = false
) => {
  const cinfo: CV.Rdchap = {
    title: rdata.title,
    p_idx: rdata.p_idx,
    rmode: ropts.rmode,
    qt_rm: ropts.qt_rm,
    mt_rm: ropts.mt_rm,
  }

  rmemo.last_ch_no = rdata.ch_no
  rmemo.last_cinfo = cinfo

  return await upsert_memo(rmemo, force ? 'chmark' : 'chlast')
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

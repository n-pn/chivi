import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

const init_form = {
  id: 0,

  wn_id: 0,

  wndic: false,

  owner: -1,
  sname: '',

  zname: '',
  vname: '',

  au_zh: '佚名',
  au_vi: 'Dật Danh',

  zdesc: '',
  vdesc: '',
  img_og: '',
  labels: [],

  guard: 0,
}

export const load = (async ({ url: { searchParams }, parent, fetch }) => {
  const { _user, _navs } = await parent()
  const wn_id = +searchParams.get('wn') || 0

  const sname = '@' + _user.uname
  const owner = _user.vu_id

  let uform = { ...init_form, sname, owner, wn_id }

  const sn_id = +searchParams.get('id')
  if (sn_id) {
    const rdurl = `/_rd/tsrepos/up${sname}/${sn_id}`
    const { xstem: ustem } = await api_get<{ xstem: CV.Upstem }>(rdurl, fetch)
    uform = { ...uform, ...ustem }
  } else if (wn_id) {
    const wnurl = `/_db/books/${wn_id}/edit_form`
    const binfo = await api_get<CV.Wnform>(wnurl, fetch)

    uform.zname = binfo.btitle_zh
    uform.vname = binfo.btitle_vi
    uform.au_zh = binfo.author_zh
    uform.au_vi = binfo.author_vi
    uform.zdesc = binfo.intro_zh
    uform.vdesc = binfo.intro_vi
    uform.img_og = binfo.bcover
    uform.labels = binfo.genres
  }

  return {
    uform,
    ontab: '+proj',
    _meta: { title: 'Thêm/sửa sưu tầm cá nhân' },
    _navs: [
      ..._navs,
      { href: '/up/+proj', text: 'Thêm sửa', hd_icon: 'file-plus' },
    ],
  }
}) satisfies PageLoad

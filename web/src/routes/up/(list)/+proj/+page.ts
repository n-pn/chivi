import { api_get } from '$lib/api_call'

import { nav_link } from '$utils/header_util'
import type { PageLoad } from './$types'

const _meta: App.PageMeta = {
  left_nav: [
    nav_link('/up', 'Sưu tầm', 'album', { show: 'pm' }),
    nav_link('/up/+proj', 'Thêm mới', 'file-plus'),
  ],
  right_nav: [],
}

const init_form = {
  id: 0,
  wn_id: 0,

  owner: -1,
  sname: '',

  zname: '',
  vname: '',
  uslug: '',

  vintro: '',
  labels: [],

  guard: 0,
}

export const load = (async ({ url: { searchParams }, parent, fetch }) => {
  const { _user } = await parent()
  const wn_id = +searchParams.get('wn') || 0

  const sname = '@' + _user.uname
  const owner = _user.vu_id

  let uform = { ...init_form, sname, owner, wn_id }

  const sn_id = +searchParams.get('id')
  if (sn_id) {
    const rdurl = `/_rd/tsrepos/up${sname}/${sn_id}`
    const { xstem: ustem } = await api_get<{ xstem: CV.Upstem }>(rdurl, fetch)
    uform = { ...uform, ...ustem }
  }

  return { uform, ontab: '+new', _meta, _title: 'Thêm/sửa sưu tầm cá nhân' }
}) satisfies PageLoad

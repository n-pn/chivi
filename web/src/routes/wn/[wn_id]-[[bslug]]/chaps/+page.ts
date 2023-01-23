import { redirect } from '@sveltejs/kit'
import { to_pgidx } from '$utils/route_utils'

export async function load({ parent }) {
  const { nvinfo, ubmemo } = await parent()
  const { sname, chidx } = ubmemo

  const location = seed_url(nvinfo.bslug, sname, chidx)
  throw redirect(302, location)
}

function seed_url(bslug: string, sname: string, ch_no: number) {
  if (!sname || sname == '=base') sname = '-'
  const base = `/wn/${bslug}/chaps/${sname}`
  const pg_no = to_pgidx(ch_no)
  return pg_no < 2 ? base : `${base}?pg=${pg_no}`
}

import { redirect } from '@sveltejs/kit';
import { page } from '$app/stores'
import { map_status } from '$utils/nvinfo_utils'

throw new Error("@migration task: Migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ params, stuff, url }) {
  const bslug = params.book

  const res = await stuff.api.nvbook(bslug)
  if (!res.error) throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return { props: res, stuff: res }
  if (res.status != 301) throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return res

  const redirect = url.pathname.replace(bslug, res.error).trim()
  throw redirect(301, encodeURI(redirect));
}

function gen_keywords(nvinfo: CV.Nvinfo) {
  const kw = [
    nvinfo.btitle_zh,
    nvinfo.btitle_vi,
    nvinfo.btitle_hv,
    nvinfo.author_zh,
    nvinfo.author_vi,
    ...nvinfo.genres,
  ]
  return kw.filter((v, i, a) => i != a.indexOf(v)).join(',')
}

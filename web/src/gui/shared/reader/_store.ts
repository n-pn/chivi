import { browser } from '$app/environment'
import { Rdpage } from '$lib/reader'
const rpages = new Map<string, Rdpage>()

export function init_page(fpath: string, ztext: string[], ropts: CV.Rdopts) {
  if (!fpath || !browser) return new Rdpage(ztext, ropts)

  let rpage = rpages.get(fpath)

  if (!rpage) {
    rpage = new Rdpage(ztext, ropts)
    rpages.set(fpath, rpage)
  } else {
    if (rpage.ropts.mt_rm != ropts.mt_rm) rpage.state.mt_ai = 0
    rpage.ropts = ropts
    // TODO: invalidate mt_ai data if algorithm changed
  }

  return rpage
}

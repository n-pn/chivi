import { browser } from '$app/environment'
import { Rdpage } from '$lib/reader'
const rpages = new Map<string, Rdpage>()

export function init_page(fpath: string, ztext: string, ropts: CV.Rdopts) {
  if (!fpath || !browser) return new Rdpage(ztext)

  let rpage = rpages.get(fpath)

  if (!rpage) {
    rpage = new Rdpage(ztext)
    rpages.set(fpath, rpage)
  }

  return rpage
}

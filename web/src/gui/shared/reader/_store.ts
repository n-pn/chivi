import { browser } from '$app/environment'
import { Rdpage } from '$lib/reader'
const rpages = new Map<string, Rdpage>()

export function init_page(fpath: string, ztext: string, p_idx = 0) {
  if (!fpath || !browser) return new Rdpage(ztext, p_idx)

  let rpage = rpages.get(fpath)

  if (rpage) {
    rpage.p_min = p_idx
    rpage.p_idx = p_idx
  } else {
    rpage = new Rdpage(ztext, p_idx)
    rpages.set(fpath, rpage)
  }

  return rpage
}

throw new Error("@migration task: Migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ stuff }) {
  const { nvinfo, nslist, nvseed } = stuff

  stuff.topbar = gen_topbar(nvinfo)
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return { props: { nvinfo, nslist, nvseed }, stuff }
}

function gen_topbar({ btitle_vi, bslug }) {
  return {
    left: [
      [btitle_vi, 'book', { href: `/-${bslug}`, kind: 'title' }],
      ['Tinh chỉnh', 'settings', { href: '.', show: 'pl' }],
    ],
  }
}

interface PatchForm {
  chmin: number
  chmax: number
  o_sname: string
  i_chmin: number
}

function init_data(nslist: CV.Nslist, { sname }): [CV.Chroot[], PatchForm] {
  let seeds = [...nslist.other, ...nslist.users]
  seeds = seeds.filter((x) => x.sname != sname)

  const { chmax, sname: o_sname } = seeds[0] || { chmax: 0, sname: '' }

  const form = { chmin: 1, i_chmin: 1, chmax: chmax, o_sname }
  return [seeds, form]
}

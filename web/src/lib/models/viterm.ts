// import { gen_ctree_text } from '$lib/mt_data_2'

// export class Viform {
//   // static from(key: string, dic: number = 0, privi = -1) {
//   //   const term = { key, val: '', ptag: '', wseg: 2, dic, tab: 1 }
//   //   return new CvtermForm(term, dic, privi)
//   // }

//   init: CV.Vtdata
//   term: CV.Vtdata

//   vtmp: string

//   constructor(init: CV.Vtdata, privi = 0) {
//     this.init = init
//     this.term = { ...init }

//     this.fix_plock(privi)
//     if (privi < this.min_privi) this.local = true

//     this.vtmp = init.vstr
//   }

//   fix_plock(privi: number) {
//     if (this.plock < 0) this.plock = privi > 0 ? 1 : 0
//     else if (this.plock == 0 && privi > this.min_privi) this.plock = 1
//   }

//   get min_privi() {
//     return this.local ? 0 : 1
//   }

//   get req_privi() {
//     return this.min_privi + this.plock
//   }

//   get zstr() {
//     return this.term.zstr
//   }

//   get vstr() {
//     return this.term.vstr
//   }

//   set vstr(vstr: string) {
//     this.vtmp = this.term.vstr
//     this.term.vstr = vstr
//   }

//   get attr() {
//     return this.term.attr
//   }

//   set attr(attr: string) {
//     this.term.attr = attr
//   }

//   get cpos() {
//     return this.term.cpos
//   }

//   set cpos(cpos: string) {
//     this.term.cpos = cpos
//   }

//   get local() {
//     return this.term.local
//   }

//   set local(local: boolean) {
//     this.term.local = local
//   }

//   get plock() {
//     return this.term.plock
//   }

//   set plock(plock: number) {
//     this.term.plock = plock
//   }

//   reset() {
//     if (this.term.vstr != this.vtmp) {
//       this.term.vstr = this.vtmp
//     } else if (this.term.vstr != this.init.vstr) {
//       this.term.vstr = this.init.vstr
//     } else {
//       this.term = { ...this.init }
//     }

//     return this
//   }

//   clear() {
//     if (this.term.vstr) {
//       this.term.vstr = ''
//     } else if (this.term.attr) {
//       this.term.attr = ''
//     } else {
//       this.term.vstr = '⛶'
//       this.term.attr = 'Hide'
//     }

//     return this
//   }

//   changed() {
//     if (!this.term.vstr) return false

//     const fields = ['vstr', 'cpos', 'attr', 'plock', 'local']

//     for (const field of fields) {
//       if (this[field] != this.init[field]) return true
//     }

//     return false
//   }

//   // get req_privi() {
//   //   return req_privi(this.dic, this.tab)
//   // }

//   to_form_body(ropts: CV.Rdopts, vtree: CV.Cvtree, zfrom: number) {
//     return {
//       zstr: this.zstr,
//       vstr: this.vstr,

//       cpos: this.cpos,
//       attr: this.attr,

//       plock: this.plock,
//       dname: this.local ? ropts.pdict : 'regular',

//       _ctx: { ...ropts, vtree: gen_ctree_text(vtree), zfrom },
//     }
//   }
// }

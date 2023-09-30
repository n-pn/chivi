declare namespace CV {
  interface Cvterm {
    id: number

    dic: number
    tab: number

    key: string
    val: string

    ptag: string
    prio: number

    uname: string
    mtime: number

    state: string
  }

  interface Viterm {
    zstr: string
    cpos: string

    vstr: string
    attr: string

    uname: string
    mtime: number

    plock: number
  }

  export type Cvtree = [
    string, // cpos
    number, // from
    number, // size
    string, // attr
    string | Array<Cvtree>, // zstr or children
    string?, // vstr
    number? // vdic
  ]

  export interface Vtform {
    zline: string

    zfrom: number
    zupto: number
    icpos: string

    vtree: CV.Cvtree
    hvarr: Array<[string, string]>
  }

  export interface Vtdata {
    zstr: string
    vstr: string
    cpos: string
    attr: string

    plock: number
    local: boolean

    hviet: string
  }
}

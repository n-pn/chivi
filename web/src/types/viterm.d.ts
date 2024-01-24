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
    local: boolean
    hviet: string
  }

  export type Cvtree = [
    string, // cpos
    string, // attr
    number, // from
    number, // upto
    string | Array<Cvtree>, // vstr or children
    number // dnum
  ]
}

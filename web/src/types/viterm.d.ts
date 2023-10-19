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
    string | Array<Cvtree>, // zstr or children

    number, // from
    number, // upto

    string, // vstr
    string, // attr
    number // dnum
  ]
}

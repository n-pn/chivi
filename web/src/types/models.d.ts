declare global {
  interface Nvinfo {
    id: number
    vname: number
  }

  interface Dboard {
    id: number
    bname: string
    bslug: string
  }

  interface Dtopic {
    id: string
    title: string
    tslug: string
    brief: string
    bhtml: string
    labels: string[]
    dboard?: Dboard
    ctime: number
    utime: number
    u_dname: string
    u_privi: number
    post_count?: number
    view_count?: number
    like_count?: number
  }

  interface Paginate {
    pgidx: number
    pgmax: number
    total?: number
  }

  interface Dtlist extends Paginate {
    items: any[]
  }

  interface Yscrit {
    id: string
    vhtml: string
    stars: number

    uname: string
    uslug: string

    bid: string
    bname: string
    bslug: string
    author: string
    bgenre: string

    mftime: number
    like_count: number
    repl_count: number
  }
}

export {}

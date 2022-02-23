declare namespace CV {
  interface Dtopic {
    dboard?: Dboard

    id: string

    title: string
    tslug: string

    labels: string[]

    brief: string
    bhtml: string

    ctime: number
    utime: number

    op_uname: string
    op_privi: number

    lp_uname: string
    lp_privi: number

    post_count?: number
    view_count?: number
    like_count?: number
  }
}

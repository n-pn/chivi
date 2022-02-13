declare namespace CV {
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
}

declare namespace CV {
  interface Ysrepl {
    yu_id: number
    uname: string
    u_pic: string

    vhtml: string
    ctime: number

    like_count: number
    repl_count: number
  }

  interface YsreplPage extends Paginate {
    repls: CV.Ysrepl[]
  }
}

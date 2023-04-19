declare namespace CV {
  interface Ysrepl {
    yu_id: number

    vhtml: string
    ctime: number

    like_count: number
    repl_count: number
  }

  interface YsreplPage extends Paginate {
    repls: CV.Ysrepl[]
    users: Record<number, CV.Ysuser>
  }
}

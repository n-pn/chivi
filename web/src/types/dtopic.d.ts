declare namespace CV {
  interface Dtopic {
    user_id: number
    u_uname: string
    u_privi: number

    b_title: string
    b_uslug: string

    dt_id: number
    title: string
    tslug: string
    dtags: string[]
    bhtml: string = ''

    ctime: number
    utime: number

    like_count: number
    repl_count: number
    view_count: number

    me_liked: number = 0
  }

  interface DtopicFull {
    post: Dtopic
    user: Viuser
    memo: Memoir
  }

  interface DtopicForm {
    id: number
    title: string
    btext: string
    labels: string
  }

  interface Dtlist extends Paginate {
    posts: Dtopic[]
  }

  type DtlistType = 'book' | 'show' | 'star' | 'seen' | 'mine' | ''
}

declare namespace CV {
  interface Dtopic {
    dboard?: Dboard

    id: number
    user_id: number

    title: string
    tslug: string

    labels: string[]

    brief: string
    bhtml: string

    ctime: number
    utime: number

    post_count?: number
    view_count?: number
    like_count?: number
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
    users: Record<number, Cvuser>
    memos: Record<number, Memoir>
  }
}

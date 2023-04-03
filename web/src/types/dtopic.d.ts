declare namespace CV {
  interface Cvpost {
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

  interface CvpostFull {
    post: Cvpost
    user: Viuser
    memo: Memoir
  }

  interface Dtlist extends Paginate {
    posts: Cvpost[]
    users: Record<number, Cvuser>
    memos: Record<number, Memoir>
  }
}

declare namespace CV {
  interface VcoinXlog {
    id: number

    sender_id: number
    target_id: number

    amount: number
    reason: string

    ctime: number
  }

  interface QtranXlog {
    id: number
    viuser_id: number

    char_count: number
    point_cost: number
    input_hash: number

    wn_dic: number

    mt_ver: number

    created_at: string
  }

  interface QtranXlogPage extends Paginate {
    xlogs: QtranXlog[]
    users: Record<number, Viuser>
    books: Record<number, Wninfo>
  }

  interface QtranBookStat {
    wninfo_id: number
    point_cost: number
  }

  interface QtranUserStat {
    viuser_id: number
    point_cost: number
  }

  interface QtranStat {
    user_stats: QtranUserStat[]
    book_stats: QtranBookStat[]
    user_infos: Record<number, Viuser>
    book_infos: Record<number, Wninfo>
  }
}

declare namespace CV {
  interface QtranXlog {
    id: number
    viuser_id: number

    char_count: number
    point_cost: number
    input_hash: number

    wn_dic: number
    w_udic: boolean

    mt_ver: number
    cv_ner: boolean
    ts_sdk: boolean
    ts_acc: boolean

    created_at: string
  }

  interface QtranXlogPage extends CV.Paginate {
    xlogs: CV.QtranXlog[]
    users: Record<number, CV.Viuser>
    books: Record<number, CV.Wninfo>
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
    user_infos: Record<number, CV.Viuser>
    book_infos: Record<number, CV.Wninfo>
  }
}

declare namespace CV {
  interface Unlock {
    vu_id: number
    ulkey: string

    owner: number
    zsize: number

    real_multp: number
    user_multp: number

    owner_got: number
    user_lost: number

    ctime: number
  }
}

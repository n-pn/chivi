declare namespace CV {
  interface VcoinXlog {
    id: number

    sender_id: number
    target_id: number

    amount: number
    reason: string

    ctime: number
  }
}

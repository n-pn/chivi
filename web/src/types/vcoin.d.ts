declare namespace CV {
  interface VcoinXlog {
    id: number

    sender: number
    sendee: number

    amount: number
    reason: string

    ctime: number
  }
}

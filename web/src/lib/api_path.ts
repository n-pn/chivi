// TODO!

export class ApiPath {
  base: string

  constructor(base: string = '/api') {
    this.base = base
  }

  index() {
    // todo : render query string
    return this.base
  }

  show(id: any) {
    return `${this.base}/${id}`
  }

  delete(id: any) {
    return `${this.base}/${id}`
  }
}

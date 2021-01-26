export default class MemoryStorage {
  constructor() {
    this._map = new Map()
  }

  get length() {
    this._map.size
  }

  getItem(key) {
    return this._map.get(key)
  }

  setItem(key, val) {
    if (typeof val === 'undefined') this._map.delete(key)
    else this._map.set(key, '' + val)
  }

  removeItem(key) {
    this._map.delete(key)
  }

  key(index) {
    return this._map.keys[index]
  }

  clear() {
    this._map.clear()
  }
}

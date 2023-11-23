import { read_confg } from '$lib/stores.js'

export async function load({ locals, cookies }) {
  return {
    _conf: read_confg(cookies),
    _user: locals._user as App.CurrentUser,
  }
}

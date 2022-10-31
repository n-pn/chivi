export async function load({ locals }) {
  return {
    _user: locals._user as App.Session,
  }
}

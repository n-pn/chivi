export async function load({ locals, cookies }) {
  return {
    theme: cookies.get('theme') || 'light',
    _user: locals._user as App.CurrentUser,
  }
}

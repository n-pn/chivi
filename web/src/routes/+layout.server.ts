export async function load({ locals, cookies }) {
  return {
    showzh: cookies.get('showzh') || 'f',
    w_temp: cookies.get('w_temp') || 't',
    theme: cookies.get('theme') || 'light',
    _user: locals._user as App.CurrentUser,
  }
}

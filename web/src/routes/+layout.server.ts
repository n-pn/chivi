export async function load({ locals, cookies }) {
  return {
    showzh: cookies.get('showzh') || 'f',
    w_temp: cookies.get('w_temp') || 't',
    w_init: cookies.get('w_init') || 'f',
    theme: cookies.get('theme') || 'light',
    _user: locals._user as App.CurrentUser,
  }
}

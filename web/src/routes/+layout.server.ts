export async function load({ locals, cookies }) {
  return {
    _conf: {
      theme: cookies.get('theme') || 'light',
      show_z: cookies.get('show_z') || 'f',
    },
    _user: locals._user as App.CurrentUser,
  }
}

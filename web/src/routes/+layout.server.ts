export async function load({ locals, cookies }) {
  return {
    _conf: {
      wtheme: cookies.get('wtheme') || 'light',
      ftsize: +cookies.get('ftsize') || 3,
      ftface: +cookies.get('ftface') || 1,
      textlh: +cookies.get('textlh') || 150,
      r_mode: +cookies.get('r_mode'),
      show_z: cookies.get('show_z') == 't',
    },
    _user: locals._user as App.CurrentUser,
  }
}

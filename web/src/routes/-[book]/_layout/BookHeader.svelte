<script context="module">
  import { page, session } from '$app/stores'
  import { invalidate } from '$app/navigation'
  import { call_api } from '$api/_api_call'

  import { kit_chap_url } from '$utils/route_utils'
  import { status_types, status_names, status_icons } from '$lib/constants.js'
</script>

<script>
  import { data as appbar } from '$lib/sects/Appbar.svelte'

  $: ubmemo = $page.stuff.ubmemo || {}
  $: nvinfo = $page.stuff.nvinfo || {}
  $: status = ubmemo.status || 'default'

  async function update_ubmemo(status) {
    if ($session.privi < 0) return
    if (status == ubmemo.status) status = 'default'
    ubmemo.status = status

    const url = `_self/books/${nvinfo.id}/status`
    const [stt, msg] = await call_api(fetch, url, { status }, 'PUT')
    if (stt) return console.log(`error update book status: ${msg}`)
    else invalidate(`/api/books/${nvinfo.bslug}`)
  }

  $: has_chap = ubmemo.chidx != 0

  $: appbar.set({
    left: [[nvinfo.vname, 'book', `/-${nvinfo.bslug}`, null, '_title']],
    right: [
      [
        status_names[status],
        status_icons[status],
        'menu',
        {
          _item: '_menu' + $session.privi < 0 ? ' _disable' : '',
          _text: '_show-md',
          on_click: (value) => update_ubmemo(value),
          menu: status_types.map((value) => [
            value,
            status_names[value],
            status_icons[value],
            status == value ? 'check' : '',
          ]),
        },
      ],
      [
        ubmemo.chidx > 0 ? 'Đọc tiếp' : 'Đọc thử',
        ubmemo.locked ? 'player-skip-forward' : 'player-play',
        has_chap ? 'link' : 'text',
        {
          href: kit_chap_url(nvinfo.bslug, ubmemo),
          _item: has_chap ? '' : '_disable',
          _text: '_show-lg',
        },
      ],
    ],
  })
</script>

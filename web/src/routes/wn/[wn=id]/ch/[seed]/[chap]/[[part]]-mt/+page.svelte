<script lang="ts">
  // import { get_user } from '$lib/stores'
  // const _user = get_user()

  import MtPage from '$gui/sects/MtPage.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ nvinfo, curr_seed, chinfo, chdata } = data)

  async function do_fixraw(line_no: number, orig: string, edit: string) {
    const url = `/_wn/texts/${nvinfo.id}/${curr_seed.sname}/${chinfo.ch_no}`
    const body = { part_no: data.cpart, line_no, orig, edit }

    const res = await fetch(url, {
      method: 'PATCH',
      body: JSON.stringify(body),
      headers: { 'Content-Type': 'application/json' },
    })

    if (res.ok) return null
    return await res.json().then((r) => r.message)
  }
</script>

<!-- <Chtabs {nvinfo} {seeds} {nvseed} {chmeta} {chinfo} /> -->

<MtPage
  cvmtl={data.cvmtl}
  ztext={data.ztext}
  mtime={chinfo.mtime}
  wn_id={nvinfo.id}
  {do_fixraw} />

<style lang="scss">
</style>

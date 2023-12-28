<script lang="ts">
  // import SIcon from '$gui/atoms/SIcon.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ustem } = data)
  let from_ch = 1
  let upto_ch = 10

  let auto_unlock = true

  let msg_text = ''
  let msg_type = ''

  const to_half_width = (input: string) => {
    const to_half = (c: string) => String.fromCharCode(c.charCodeAt(0) - 0xfee0)
    return input.replace(/[\uff01-\uff5e]/g, to_half).replace(/　/g, ' ')
  }

  const load_raw_text = async () => {
    let full_text = ''

    try {
      for (let ch_no = from_ch; ch_no <= upto_ch; ch_no++) {
        msg_text = `Đang tải chương thứ ${ch_no}`
        const chap_text = await load_raw_chap(ch_no)
        full_text += chap_text + '\n\n\n'
      }
    } catch (ex) {
      msg_type = 'err'
      msg_text = ex.message
    }

    const fname = `[${ustem.sname}_${ustem.id}]${from_ch}-${upto_ch}.raw.txt`
    send_file(to_half_width(full_text), fname)
  }

  const load_raw_chap = async (ch_no: number) => {
    const first = await load_raw_part(ch_no, 1)
    let ctext = first.zname + '\n\n' + first.ztext.join('\n')

    if (first.p_max > 1) {
      for (let p_idx = 2; p_idx <= first.p_max; p_idx++) {
        const cpart = await load_raw_part(ch_no, p_idx)
        ctext += '\n\n' + cpart.ztext.join('\n')
      }
    }

    return ctext
  }

  const load_raw_part = async (ch_no: number, p_idx: number) => {
    const url = `/_rd/cdata/up/${ustem.sname}/${ustem.id}/${ch_no}/${p_idx}?force=${auto_unlock}`
    const res = await fetch(url)

    if (!res.ok) throw await res.text()
    const cpart: CV.Chpart = await res.json()

    if (cpart.error == 414) {
      cpart.ztext = ['Chương hiện tại chưa có trên hệ thống!']
    } else if (cpart.error == 413) {
      cpart.ztext = ['Bạn chưa mở khóa cho chương!']
    } else if (cpart.error == 415) {
      cpart.ztext = ['Bạn chưa đủ vcoin để mở khóa chương!']
    } else {
      cpart.ztext.shift()
    }

    return cpart
  }

  const send_file = (cdata: string, fname: string = 'untitled.txt') => {
    const link = document.createElement('a')
    const file = new Blob([cdata], { type: 'text/plain' })
    link.href = URL.createObjectURL(file)
    link.download = fname
    link.click()
    URL.revokeObjectURL(link.href)
  }
</script>

<div class="form">
  <div class="x-field _flex">
    <div class="x-group">
      <div class="x-label">Từ chương:</div>
      <input
        class="m-input"
        type="number"
        name="from_ch"
        bind:value={from_ch} />
    </div>

    <div class="x-group">
      <div class="x-label">Tới chương:</div>
      <input
        class="m-input"
        type="number"
        name="upto_ch"
        bind:value={upto_ch} />
    </div>
  </div>

  <div class="x-field">
    <label class="x-label x-check">
      <input
        type="checkbox"
        name="force"
        class="check"
        bind:checked={auto_unlock} />
      <span>Tự động mở khóa chương bằng Vcoin</span>
    </label>
  </div>

  <footer>
    <button class="m-btn _primary _fill" on:click={load_raw_text}>
      Tải text gốc!
    </button>

    <div class="form_msg _{msg_type}">{msg_text}</div>
  </footer>
</div>

<style lang="scss">
  .form {
    padding: 1rem 0;
    // width: min(20rem, 100%);
    // margin: 0 auto;
  }

  .x-field {
    margin-top: 0.75rem;
  }

  footer {
    padding: 0.75rem 0;
  }
</style>

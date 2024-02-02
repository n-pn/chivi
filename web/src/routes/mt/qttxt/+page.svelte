<script lang="ts" context="module">
  const available_modes = {
    qt_v1: 'Máy dịch cũ',
    bd_zv: 'Dịch bằng Baidu',
    ms_zv: 'Dịch bằng Bing',
    c_gpt: 'GPT Tiên Hiệp',
  }
</script>

<script lang="ts">
  import Cztext from '$gui/shared/upload/Cztext.svelte'
  import Csplit from '$gui/shared/upload/Csplit.svelte'
  import type { Czdata } from '$gui/shared/upload/czdata'

  import { SIcon, Footer } from '$gui'

  import type { PageData } from './$types'
  export let data: PageData

  export let tmode = 'qt_v1'
  export let pdict = 'combine'

  let ztext = ''
  let state = 0
  let reuse = true

  let chaps: Czdata[] = []
  let trans: string[] = []

  let on_ch_no = 0
  let err_text = ''

  $: if (chaps) err_text = ''

  let out_time = 0
  let out_href = ''

  $: wn_id = pdict.startsWith('wn') ? +pdict.slice(2) : 0

  const translate = async () => {
    err_text = ''
    state = 1
    out_href = ''

    try {
      const trans = await do_translate(chaps, 0)
      const file = new Blob([trans.join('\n\n\n')], { type: 'text/plain' })
      out_time = new Date().getTime()
      out_href = URL.createObjectURL(file)
      state = 2
    } catch (ex) {
      err_text = ex
      state = 0
      alert(ex)
    }
  }

  const do_translate = async (chaps: Czdata[], start = 0) => {
    for (on_ch_no = start; on_ch_no < chaps.length; on_ch_no++) {
      const { chdiv, parts } = chaps[on_ch_no]

      let [fpart, ...extra] = parts
      if (chdiv && chdiv != '正文') fpart = `［${chdiv}］${fpart}`

      let vtran = await call_qtran(fpart, 1)
      vtran = vtran.replace('\n', '\n\n')

      for (const cpart of extra) {
        const vbody = await call_qtran(cpart, 0)
        vtran += '\n' + vbody
      }

      trans[on_ch_no] = vtran
    }

    return trans
  }

  const call_qtran = async (ztext: string, title = 0) => {
    let url = `/_sp/qtran/${tmode}?redo=${!reuse}`
    if (tmode == 'qt_v1') url += `&opts=${wn_id},${title}`

    const res = await fetch(url, { method: 'POST', body: ztext })
    const txt = await res.text()
    if (res.ok) return txt.trim()
    else throw txt
  }
</script>

<div class="zform">
  <div class="input">
    <Cztext bind:ztext bind:state />
  </div>

  <div class="split">
    <Csplit {ztext} bind:state bind:chaps />
  </div>
</div>

<Footer>
  {#if err_text}
    <div class="form-msg _err">{err_text}</div>
  {:else}
    <div class="x-label">
      <label class="u-show-tm" for="tmode">Chọn cách dịch:</label>

      <select class="m-input _sm" name="tmode" id="tmode" bind:value={tmode}>
        {#each Object.entries(available_modes) as [value, label], index}
          <option {value}>{label}</option>
        {/each}
      </select>
    </div>

    <div class="x-label">
      <label class="u-show-ts" for="pdict">Từ điển riêng:</label>
      <input
        class="m-input _sm"
        name="pdict"
        id="pdict"
        disabled={['c_gpt', 'bd_zv', 'ms_zv'].includes(tmode)}
        bind:value={pdict} />
    </div>
  {/if}

  {#if state == 0}
    <button
      class="m-btn _warning _fill u-right"
      disabled={data._user.privi < 2 || chaps.length == 0}
      on:click={translate}>
      <span>Bắt đầu</span>
    </button>
  {:else if state == 1}
    <button class="m-btn _warning _fill u-right" disabled>
      <SIcon name="loader-2" spin={true} />
      <span class="u-show-ts">Đang dịch</span>
      <span>{on_ch_no + 1}/{chaps.length}</span>
    </button>
  {:else if state == 2}
    <a
      href={out_href}
      class="m-btn _success _fill u-right"
      download="{out_time}-{tmode}.txt">
      <SIcon name="download" />
      <span>Tải xuống</span>
    </a>
  {/if}
</Footer>

<style lang="scss">
  .zform {
    margin: 1rem 0 0.5rem;
    padding-bottom: 1rem;

    @include border($loc: bottom);
    @include flex($gap: 0.75rem);

    flex-direction: column;
    @include bp-min(tm) {
      flex-direction: row;
    }
  }

  .input,
  .split {
    flex: 1;
  }

  input[name='pdict'] {
    text-align: center;
    width: 6rem;
  }

  select {
    width: 9rem;
    text-align: center;
  }

  .x-label {
    margin-right: 0.5rem;
    gap: 0.25rem;

    .m-input {
      padding-left: 0.5rem;
      padding-right: 0.5rem;
    }
  }
</style>

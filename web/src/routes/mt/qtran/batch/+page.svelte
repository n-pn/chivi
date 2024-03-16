<script lang="ts" context="module">
  const available_modes = {
    qt_v1: 'Máy dịch cũ',
    mtl_1: 'Máy dịch AI 1',
    mtl_2: 'Máy dịch AI 2',
    mtl_3: 'Máy dịch AI 3',
    bd_zv: 'Dịch bằng Baidu',
    ms_zv: 'Dịch bằng Bing',
    c_gpt: 'GPT Tiên Hiệp',
  }
</script>

<script lang="ts">
  import { beforeNavigate } from '$app/navigation'
  import { get_user } from '$lib/stores'

  import Cztext from '$gui/shared/upload/Cztext.svelte'
  import Csplit from '$gui/shared/upload/Csplit.svelte'
  import { split_parts, type Czdata } from '$gui/shared/upload/czdata'

  import { SIcon } from '$gui'

  import type { PageData } from './$types'
  export let data: PageData

  let ztext = ''
  let state = 0
  let regen = 1
  let fname = ''

  let chaps: Czdata[] = []
  let trans: string[] = []

  let on_ch_no = 0
  let err_text = ''

  $: if (chaps) err_text = ''
  const _user = get_user()

  const qcost_map = { qt_v1: 2, mtl_1: 4, mtl_2: 5, mtl_3: 5, ms_zv: 8, bd_zv: 10, c_gpt: 10 }
  $: vcoin_needed = (ztext.length * (qcost_map[data.qkind] || 1)) / 100_000

  const translate = async () => {
    err_text = ''
    state = 1

    try {
      const tran = await do_translate(chaps, 0)
      const file = new Blob([tran.join('\n\n\n')], { type: 'text/plain' })
      const elem = document.createElement('a')
      const name = `${fname || new Date().getTime()} [1-${chaps.length}]`

      elem.setAttribute('href', URL.createObjectURL(file))
      elem.setAttribute('download', `${name}.${data.qkind}.txt`)
      elem.style.display = 'none'

      document.body.appendChild(elem)
      elem.click()
      document.body.removeChild(elem)

      state = 2
    } catch (ex) {
      err_text = ex
      state = 0
      alert(ex)
    }
  }

  const do_translate = async (chaps: Czdata[], start = 0) => {
    const limit = data.qkind == 'c_gpt' ? 500 : 2000

    for (on_ch_no = start; on_ch_no < chaps.length; on_ch_no++) {
      const { chdiv, lines } = chaps[on_ch_no]

      let [fpart, ...extra] = split_parts(lines, limit)
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

  const call_qtran = async (ztext: string, h_sep = 0) => {
    const url = `/_sp/qtran/${data.qkind}?pd=${data.pdict}&op=text&rg=${regen}&hs=${h_sep}`
    const res = await fetch(url, { method: 'POST', body: ztext })
    const txt = await res.text()
    if (res.ok) return txt.trim()
    else throw txt
  }

  beforeNavigate(({ cancel }) => {
    if (state != 1) return
    if (!confirm('Hủy bỏ chương trình đang chạy?')) cancel()
  })
</script>

<article class="article island">
  <header class="m-flex">
    <div class="x-label">
      <label class="u-show-tm" for="qkind">Chọn cách dịch:</label>

      <select class="m-input _sm" name="qkind" id="qkind" bind:value={data.qkind}>
        {#each Object.entries(available_modes) as [value, label]}
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
        disabled={['c_gpt', 'bd_zv', 'ms_zv'].includes(data.qkind)}
        bind:value={data.pdict} />
    </div>
  </header>
  <div class="zform">
    <div class="input"><Cztext bind:ztext bind:state /></div>
    <div class="split"><Csplit {ztext} bind:state bind:chaps /></div>
  </div>

  <footer class="m-flex _cy">
    {#if err_text}
      <div class="form-msg _err">{err_text}</div>
    {:else}
      <div class="form-msg">Nhập văn bản phía trên để dịch</div>
    {/if}

    <div class="u-right">
      {#if state == 0}
        <button
          class="m-btn _warning _fill"
          data-umami-event="qtran-batch"
          disabled={chaps.length == 0 || $_user.privi < 0}
          on:click={translate}>
          <SIcon name="language" />
          <span>Dịch văn bản</span>
        </button>
      {:else if state == 1}
        <button class="m-btn _primary _fill" disabled>
          <SIcon name="loader-2" spin={true} />
          <span>{on_ch_no + 1}/{chaps.length}</span>
        </button>
      {:else}
        <button class="m-btn _success _fill" on:click={() => (state = 0)}>
          <SIcon name="rotate" />
          <span>Dịch mới</span>
        </button>
      {/if}
    </div>
  </footer>
</article>

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

  footer {
    margin-top: 1rem;
  }
</style>

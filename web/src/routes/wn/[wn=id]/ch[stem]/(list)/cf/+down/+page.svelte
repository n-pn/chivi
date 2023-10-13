<script lang="ts">
  import { invalidate } from '$app/navigation'

  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { PageData } from './$types'
  import { browser } from '$app/environment'
  import DlcvList from './DlcvList.svelte'
  import { debounce } from '$lib/svelte'
  export let data: PageData

  $: ({ nvinfo, ustem, dlcvs, pg_no } = data)

  let from = 1
  let upto = data.ustem.chmax || 1

  let _onload = true
  let err_msg: string

  let word_count = 0
  let vcoin_cost = 0

  let timer: number

  $: if (browser && from > 0 && upto >= from) {
    clearTimeout(timer)
    timer = setTimeout(() => {
      caculate_cost(nvinfo.id, ustem.sname, from, upto)
    }, 300)
  }

  async function caculate_cost(
    wn_id: number,
    sname: string,
    from: number,
    upto: number
  ) {
    _onload = true
    const url = `/_wn/seeds/${wn_id}/${sname}/word_count?from=${from}&upto=${upto}`
    const res = await fetch(url)
    if (!res.ok) alert(await res.text())

    word_count = (await res.json()).word_count
    vcoin_cost = Math.round((word_count / 100_000) * 100) / 100
    _onload = false
  }

  async function submit() {
    _onload = true

    const url = '/_db/dlcvs'

    const body = {
      wn_id: nvinfo.id,
      sname: ustem.sname,
      from,
      upto,
      texsmart_pos: false,
      texsmart_ner: false,
      mt_version: 1,
    }

    const headers = { 'Content-Type': 'application/json' }

    const res = await fetch(url, {
      headers,
      body: JSON.stringify(body),
      method: 'POST',
    })

    _onload = false
    if (res.ok) {
      await invalidate('dlcvs')
    } else {
      err_msg = await res.text()
    }
  }
</script>

<article class="article island">
  <h2>Tải xuống hàng loạt</h2>

  <div class="form">
    <div class="inputs">
      <span class="field">
        <label class="label" for="from">Từ chương thứ</label>
        <input
          type="number"
          name="from"
          class="m-input _sm"
          bind:value={from}
          disabled={_onload}
          min={1}
          max={ustem.chmax} />
      </span>

      <span class="field">
        <label class="label" for="upto">Tới chương thứ</label>
        <input
          type="number"
          name="upto"
          class="m-input _sm"
          bind:value={upto}
          disabled={_onload}
          min={from}
          max={ustem.chmax} />
      </span>
    </div>

    <div class="stats">
      <span>
        Số chương muốn tải: <em>{upto - from + 1}</em> chương
      </span>
      <span>
        Tổng số ký tự: <em>{word_count}</em> chữ
      </span>
    </div>

    {#if err_msg}<div class="error">{err_msg}</div>{/if}

    <div class="action">
      <span class="label">Số vcoin cần thiết để yêu cầu tải xuống:</span>
      <span class="x-vcoin">{vcoin_cost}</span>
      <SIcon iset="icons" name="vcoin" />

      <button class="m-btn _primary _fill" disabled={_onload} on:click={submit}>
        <SIcon name={_onload ? 'refresh' : 'send'} spin={_onload} />
        <span>Tạo yêu cầu</span>
      </button>
    </div>
  </div>

  <h3>Lịch sử yêu cầu tải xuống:</h3>

  {#if dlcvs.length > 0}
    <DlcvList {dlcvs} {pg_no} />
  {:else}
    <div class="d-empty">Bạn chưa có yêu cầu tải xuống.</div>
  {/if}
</article>

<style lang="scss">
  .form {
    margin: var(--gutter) 0;
  }

  .inputs {
    display: flex;
    gap: 0.75rem;
  }

  input[type='number'] {
    display: inline-block;
    text-align: center;
    width: 4.5rem;
  }

  .field {
    display: flex;
    align-items: center;
    gap: 0.5rem;

    // flex-direction: column;
  }

  .label {
    @include fgcolor(tert);
    font-weight: 500;
  }

  .stats {
    margin: 0.5rem 0;
    font-style: italic;
    @include fgcolor(tert);
    display: flex;
    gap: 0.75rem;

    em {
      @include fgcolor(warning);
    }
  }

  .action {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    margin-top: 0.75rem;
  }
</style>

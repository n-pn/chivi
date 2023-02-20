<script context="module" lang="ts">
  import { api_call } from '$lib/api_call'
  import { config, vdict, ztext, zfrom, zupto } from '$lib/stores'

  import Postag from '$gui/parts/Postag.svelte'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Vhint from './TranHint.svelte'
  import Vutil from './Vutil.svelte'
  import { rel_time } from '$utils/time_utils'

  const save_modes = [
    {
      text: 'Tự động',
      desc: 'Tự động chọn chế độ tuỳ theo quyền hạn của bạn',
    },
    {
      text: 'Cộng đồng',
      desc: 'Ngay lập tức cập nhật nghĩa dịch cho tất cả mọi người. Ghi đè lên nghĩa "Lưu tạm" nếu có.',
    },
    {
      text: 'Lưu nháp',
      desc: 'Tạm thời chỉ áp dụng nghĩa dịch cho riêng bạn cho tới khi nghĩa được kiểm tra kỹ.',
    },
    {
      text: 'Riêng bạn',
      desc: 'Chỉ áp dụng cho riêng bạn, không bị ảnh hưởng khi người khác cập nhật nghĩa của từ.',
    },
  ]
</script>

<script lang="ts">
  export let active = false
  export let vpterm: CV.VpTerm

  export let val_hints: string[]
  export let tag_hints: string[]

  export let on_change = () => {}

  // $: [lbl_state, btn_state] = vpterm.state

  async function submit() {
    vpterm['_ctx'] = `${$ztext}:${$zfrom}:${$vdict.dname}`

    const res = await fetch('/_m1/defns', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(vpterm),
    })

    if (res.ok) {
      on_change()
    } else {
      const body = await res.json()
      alert(body.message)
    }
  }

  const map_dname = (dic: number) => {}

  const tabs = { 1: 'Chung', 2: 'Nháp', 3: 'Riêng' }
</script>

<div class="term">
  <header>
    <span class="dic">{vpterm.dic} </span>
    <span class="tab">{tabs[vpterm.tab]}</span>
  </header>
  <section>
    <span class="val">{vpterm.val}</span>
    <span class="tag">{vpterm.ptag}</span>
  </section>

  <footer>
    {#if vpterm.uname}
      <span class="state">{vpterm.state}:</span>
      <span class="mtime">{rel_time(vpterm.mtime)}</span>
      <span>bởi</span>
      <span class="uname">{vpterm.uname}</span>
    {/if}
  </footer>
</div>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<!--


  <upsert-body on:click={refocus}>
    <Emend {vpterm} />

    <upsert-main>
      <Vhint {dname} bind:vpterm />

      <div class="value" class:_fresh={vpterm.init.state == 'Xoá'}>
        <input
          type="text"
          class="-input"
          bind:this={inputs[0]}
          bind:value={vpterm.vals[vpterm._slot]}
          autocomplete="off"
          autocapitalize={$ctrl.tab < 1 ? 'words' : 'off'} />

        {#if !dname.startsWith('$')}
          <button class="ptag" data-kbd="w" on:click={() => ctrl.set_state(2)}>
            {pt_labels[vpterm.tags[0]] || 'Phân loại'}
          </button>
        {/if}
      </div>

      <Vutil {key} tab={$ctrl.tab} bind:vpterm />
    </upsert-main>

    {#if show_opts}
      <section class="opts">
        {#each save_modes as { text, desc, pmin }, index}
          {@const privi = $ctrl.tab + pmin}
          <label class="label" class:_active={vpterm._mode == index}
            ><input
              type="radio"
              name="_mode"
              bind:group={vpterm._mode}
              disabled={$session.privi < privi}
              value={index} />
            <span class="-text" use:hint={desc}>{text}</span>
            <span class="-icon" use:hint={'Yêu cần quyền hạn: ' + privi}>
              <SIcon name="privi-{privi}" iset="sprite" />
            </span>
          </label>
        {/each}
      </section>
    {/if}

    <upsert-foot>
      <Vprio {vpterm} bind:prio={vpterm.prio} />

      <btn-group>
        <button
          class="m-btn _lg"
          class:_active={show_opts}
          data-kbd="&bsol;"
          data-key="Backslash"
          use:hint={'Thay đổi chế độ lưu trữ'}
          on:click={() => (show_opts = !show_opts)}>
          <SIcon name="tools" />
        </button>

        <button
          class="m-btn _lg _fill {btn_state}"
          data-kbd="↵"
          disabled={!changed(vpterm)}
          on:click={submit_val}>
          <span class="submit-text">{lbl_state}</span>
        </button>
      </btn-group>
    </upsert-foot>
  </upsert-body>
  -->
<!-- {#if $ctrl.state == 2}
  <Postag bind:ptag={vpterm.tags[vpterm._slot]} bind:state={$ctrl.state} />
{/if} -->

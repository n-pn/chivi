<script lang="ts">
  import { goto, invalidateAll } from '$app/navigation'

  import Cztext from '$gui/shared/upload/Cztext.svelte'
  import Csplit from '$gui/shared/upload/Csplit.svelte'

  import { SIcon, Footer } from '$gui'

  import type { PageData } from './$types'
  import { _pgidx } from '$lib/kit_path'
  import type { Czdata } from '$gui/shared/upload/czdata'
  export let data: PageData

  let zform = data.zform
  let ch_no = zform.ch_no

  let state = 0
  let fixed = data.fixed

  let chaps: Czdata[] = []
  let pg_no = 0

  const headers = { 'Content-Type': 'application/json' }

  const guess_ukind = (index: number, total: number) => {
    return total <= 32 ? 3 : index == 0 ? 1 : index + 32 < total ? 0 : 2
  }

  async function submit(event: Event) {
    event.preventDefault()

    state = 2

    for (let index = 0; index < chaps.length; index += 32) {
      pg_no = index / 32 + 1

      const page = chaps.slice(index, index + 32)
      const body = JSON.stringify(page)

      const ukind = guess_ukind(index, chaps.length) | (fixed ? 4 : 0)

      const ulurl = `/_rd/czdatas/${data.crepo.sroot}?ukind=${ukind}`
      const ulres = await fetch(ulurl, { headers, method: 'POST', body })

      if (ulres.ok) continue
      alert(await ulres.text())

      state = 0
      return
    }

    state = 3

    await invalidateAll()
    if (chaps.length > 1) {
      goto(`${data.sroot}?pg=${_pgidx(ch_no)}`)
    } else {
      goto(`${data.sroot}/c${ch_no}`)
    }
  }

  $: plock = data.crepo.plock
</script>

<section class="zmain">
  <div class="zform">
    <div class="input">
      <Cztext bind:ztext={zform.ztext} bind:state />
    </div>

    <div class="split">
      <Csplit ztext={zform.ztext} {ch_no} bind:state bind:chaps />
    </div>
  </div>

  <Footer>
    <label
      class="x-label u-right"
      data-tip="Các chương được đánh dấu sửa tay sẽ không bị ghi đè bởi chế độ đăng tải tự động">
      <input type="checkbox" bind:checked={fixed} />
      <span>Đánh dấu sửa tay</span>
    </label>

    <button
      class="m-btn _primary _fill"
      disabled={data._user.privi < plock || chaps.length == 0}
      on:click={submit}>
      {#if state == 2}
        <SIcon name="loader-2" spin={true} />
        <span>Tiến độ {pg_no + 1}/{_pgidx(chaps.length)}</span>
      {:else if state == 3}
        <SIcon name="check" />
        <span>Hoàn thành</span>
      {:else}
        <SIcon name="send" />
        <span>Đăng tải</span>
      {/if}
      <SIcon name="privi-{plock}" iset="icons" />
    </button>
  </Footer>
</section>

<style lang="scss">
  .zmain {
    padding: 1rem 0 0.5rem;
  }
  .zform {
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

  .x-label {
    margin-right: 1rem;
  }
</style>

<script lang="ts">
  import { goto, invalidateAll } from '$app/navigation'

  import Cztext from '$gui/shared/upload/Cztext.svelte'
  import Csplit from '$gui/shared/upload/Csplit.svelte'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { SIcon, Footer } from '$gui'

  import type { PageData } from '../$types'
  import { _pgidx } from '$lib/kit_path'
  import type { Czdata } from '$gui/shared/upload/czdata'
  export let data: PageData

  let { ch_no = 0 } = data
  let state = 0

  let chaps: Czdata[] = []
  let pg_no = 0

  const headers = { 'Content-Type': 'application/json' }

  async function submit(event: Event) {
    event.preventDefault()

    state = 2

    for (let index = 0; index < chaps.length; index += 32) {
      pg_no = index / 32 + 1

      const page = chaps.slice(index, index + 32)
      const body = JSON.stringify(page)
      const res = await fetch(`/_rd/czdatas/${data.crepo.sroot}`, {
        headers,
        method: 'POST',
        body,
      })

      if (res.ok) continue
      alert(await res.text())
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

<section class="zform">
  <div class="input">
    <Cztext bind:ztext={data.ztext} bind:state />
  </div>

  <div class="split">
    <Csplit ztext={data.ztext} {ch_no} bind:state bind:chaps />
  </div>
</section>

<section class="zfoot">
  <Footer>
    {#if state == 2}
      Đang đăng lên {pg_no + 1}/{_pgidx(chaps.length)}
    {:else if state == 3}
      Đăng tải hoàn thành!
    {/if}

    <button
      class="m-btn _primary _fill u-right"
      disabled={data._user.privi < plock || chaps.length == 0}
      on:click={submit}>
      <SIcon name="send" />
      <span>Đăng tải</span>
      <SIcon name="privi-{plock}" iset="icons" />
    </button>
  </Footer>
</section>

<style lang="scss">
  .zform {
    margin-top: 1rem;

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

  .zfoot {
    padding-bottom: 0.5rem;
  }
</style>

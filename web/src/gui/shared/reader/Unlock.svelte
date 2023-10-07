<script lang="ts">
  import { invalidateAll } from '$app/navigation'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let cstem: CV.Chstem
  export let rdata: CV.Chpart

  $: ({ stype, sname, sn_id } = cstem)
  $: ({ ch_no, p_idx } = rdata)

  $: vcoin_cost = Math.round(cstem.multp * rdata.zsize * 0.01) / 1000

  let msg_text = ''
  let msg_type = ''

  const unlock_chap = async () => {
    msg_text = 'Đang mở khoá chương...'

    const url = `/_rd/unlock/${stype}/${sname}/${sn_id}/${ch_no}/${p_idx}`
    const res = await fetch(url, { method: 'PUT' })

    if (!res.ok) return alert(await res.text())
    const [ok, remain] = await res.json()

    if (ok) {
      msg_text = 'Mở khoá thành công, trang đang tải lại..'
      msg_type = 'ok'

      $_user.vcoin = remain
      invalidateAll()
    } else {
      msg_text = 'Mở khóa chương thất bại. Mời thử lại!'
      msg_type = 'err'
    }
  }
</script>

<section>
  <h1 class="em">
    Lỗi: Chương {ch_no} phần {p_idx} cần thiết mở khóa bằng vcoin.
  </h1>

  <p>
    Theo hệ số, bạn cần thiết <v-vcoin
      >{vcoin_cost}
      <SIcon name="vcoin" iset="icons" /></v-vcoin>
    để mở khóa cho chương. Số vcoin bạn đang có:
    <v-vcoin
      >{Math.round($_user.vcoin * 1000) / 1000}
      <SIcon name="vcoin" iset="icons" /></v-vcoin>
  </p>

  <p>
    <em> Công thức tính: </em>
    <code>số lượng chữ / 100_000 * hệ số nhân = số vcoin cần thiết</code>
    <br />
    Hệ số nhân hiện tại của danh sách chương:
    <strong class="em">{cstem.multp}</strong>.
    {#if cstem.stype == 'up'}<em
        >(Thử liên hệ với chủ sở hữu dự án nếu thấy chưa phù hợp!)</em
      >{/if}
  </p>
  <footer class="actions">
    <div>Thanh toán vcoin và mở khóa chương:</div>

    <button
      type="button"
      class="m-btn _fill _lg _warning"
      class:_disable={$_user.vcoin < vcoin_cost}
      on:click={unlock_chap}>
      <SIcon name="lock-open" />
      <span>Mở khóa</span>
    </button>

    {#if msg_text}
      <div class="form-msg _{msg_type}">{msg_text}</div>
    {:else if $_user.vcoin < vcoin_cost}
      <div class="em">
        <em>
          Bạn chưa đủ vcoin để mở khóa cho chương. Nạp vcoin theo <a
            href="/hd/donation">hướng dẫn ở đây</a
          >.
        </em>
      </div>
    {/if}
  </footer>
</section>

<style lang="scss">
  a:not(.m-btn) {
    @include fgcolor(primary, 5);
    &:hover {
      border-bottom: 1px solid currentColor;
    }
  }

  div {
    font-size: var(--para-fs);
  }

  .actions {
    @include flex-ca($gap: 0.5rem);
    flex-direction: column;
    padding: 0.75rem 0;
    @include border(--bd-soft, $loc: top);
  }
</style>

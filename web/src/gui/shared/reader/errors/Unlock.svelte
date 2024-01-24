<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let crepo: CV.Tsrepo
  export let rdata: CV.Chpart
  export let state = 0

  $: ({ ch_no, p_idx } = rdata)

  $: privi = $_user.privi + 1
  $: vcost = Math.floor(((5 - privi) * rdata.zsize) / 200) / 1000

  let msg_text = ''
  let msg_type = ''

  $: if (rdata.error == 415) {
    msg_text = 'Không đủ vcoin để mở khóa chương.'
    msg_type = 'err'
  }

  const unlock_chap = async () => {
    msg_text = 'Đang mở khoá chương...'
    msg_type = ''

    const url = `/_rd/chaps/${crepo.sroot}/${ch_no}/${p_idx}?force=true`
    const res = await fetch(url, { method: 'GET' })

    if (!res.ok) return alert(await res.text())

    state = 3
    rdata = await res.json()

    if (rdata.error == 0) {
      msg_type = 'ok'
      msg_text = 'Mở khoá thành công, trang đang tải lại...'
      $_user.vcoin -= vcost
      window.location.reload()
    } else if (rdata.error == 415) {
      msg_text = 'Không đủ vcoin để mở khóa chương'
      msg_type = 'err'
    } else {
      msg_text = 'Không rõ lỗi, mời thử lại!'
      msg_type = 'err'
    }
  }
</script>

<h1 class="u-warn">
  Lỗi: Chương {ch_no} phần {p_idx} cần thiết mở khóa bằng vcoin.
</h1>

{#if $_user.uname == 'Khách'}
  <p>
    <em
      >Bạn chưa đăng nhập. Nếu bạn đã có tài khoản, đăng nhập tại đây: <a
        href="/_u/login">Đăng nhập</a>
      . Nếu chưa có tài khoản, hãy đăng ký mới tại đây:
      <a href="/_u/signup">Đăng ký tài khoản mới</a>
    </em>
  </p>
{:else}
  <p>
    Phần hiện tại có <strong class="u-warn">{rdata.zsize}</strong> ký tự. Bạn
    cần thiết
    <x-vcoin
      >{vcost}
      <SIcon name="vcoin" iset="icons" /></x-vcoin>
    để mở khóa cho chương. Số vcoin bạn đang có:
    <x-vcoin
      >{Math.round($_user.vcoin * 1000) / 1000}
      <SIcon name="vcoin" iset="icons" /></x-vcoin>
  </p>

  <p>
    <em> Công thức tính: </em>
    <code
      >[5 - quyền hạn] * [Số ký tự] / 200_000 = [Số vcoin cần thanh toán]</code>
  </p>

  <p class="u-fg-tert">
    <em>
      Gợi ý 1: Giảm chi phí mở khoá chương bằng nâng cấp quyền hạn tài khoản.
    </em>
  </p>

  <p class="u-fg-tert">
    <em>
      Gợi ý 2: Vào [Cài đặt] phía trên để bật chế độ Tự động mở khóa chương.
    </em>
  </p>

  <footer class="actions">
    <div>Thanh toán vcoin và mở khóa chương:</div>

    <button
      type="button"
      class="m-btn _fill _lg _warning"
      class:_disable={$_user.vcoin < vcost}
      data-umami-event="unlock-chap"
      on:click={unlock_chap}>
      <SIcon name="lock-open" />
      <span>Mở khóa</span>
    </button>

    {#if msg_text}
      <div class="form-msg _{msg_type}">{msg_text}</div>
    {:else if $_user.vcoin < vcost}
      <div class="u-warn">
        <em>
          Bạn chưa đủ vcoin để mở khóa cho chương. Nạp vcoin theo <a
            href="/hd/donation">hướng dẫn ở đây</a
          >.
        </em>
      </div>
    {/if}
  </footer>
{/if}

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
  .form-msg {
    margin-top: 0;
  }
</style>

<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let crepo: CV.Chrepo
  export let rdata: CV.Chpart
  export let state = 0

  $: ({ ch_no, p_idx } = rdata)

  $: vcoin_cost = Math.round(rdata.multp * rdata.zsize * 0.01) / 1000

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
      $_user.vcoin -= vcoin_cost
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

{#if $_user.privi < 0}
  <p>
    <em>Bạn chưa đăng nhập. Bấm vào <a href="/_auth/login">đây</a></em> để đăng nhập
    hoặc đăng ký tài khoản mới.
  </p>
{:else}
  <p>
    Phần hiện tại có <span class="u-warn">{rdata.zsize}</span> ký tự. Theo hệ
    số, bạn cần thiết
    <x-vcoin
      >{vcoin_cost}
      <SIcon name="vcoin" iset="icons" /></x-vcoin>
    để mở khóa cho chương. Số vcoin bạn đang có:
    <x-vcoin
      >{Math.round($_user.vcoin * 1000) / 1000}
      <SIcon name="vcoin" iset="icons" /></x-vcoin>
  </p>

  <p>
    <em> Công thức tính: </em>
    <code>[Số ký tự] / 100_000 * [Hệ số nhân] = [Số vcoin cần thiết]</code>
    <br />
    Hệ số nhân hiện tại của chương:
    <strong class="u-warn">{crepo.multp}</strong>.
  </p>
  <p class="u-fg-tert">
    <em>
      {#if crepo.stype == 'up'}
        Gợi ý: Hệ số nhân của nguồn sưu tầm cá nhân do người dùng tự thiết đặt.
        Thử liên hệ với chủ sở hữu dự án nếu thấy chưa phù hợp!
      {:else}
        Gợi ý: Hệ số nhân của chương được tính bằng hệ số nhân mặc định của
        nguồn truyện trừ cho quyền hạn hiện tại của bạn. Quyền hạn càng cao thì
        hệ số nhân càng giảm.
      {/if}
    </em>
  </p>

  <footer class="actions">
    <div>Thanh toán vcoin và mở khóa chương:</div>

    <button
      type="button"
      class="m-btn _fill _lg _warning"
      class:_disable={$_user.vcoin < vcoin_cost}
      data-umami-event="unlock-chap"
      on:click={unlock_chap}>
      <SIcon name="lock-open" />
      <span>Mở khóa</span>
    </button>

    {#if msg_text}
      <div class="form-msg _{msg_type}">{msg_text}</div>
    {:else if $_user.vcoin < vcoin_cost}
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

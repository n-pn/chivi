<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import SIcon from '$gui/atoms/SIcon.svelte'
  import { invalidateAll } from '$app/navigation'

  export let rdata: CV.Chpart
  export let multp: number = 2

  $: vcoin_cost = Math.round(multp * rdata.zsize * 0.01) / 1000
  $: [ftype, sname, sn_id, ch_no, _cksum, p_idx] = rdata.fpath.split(/[:\/\-]/)

  let msg_text = ''
  let msg_type = ''

  const unlock_chap = async () => {
    msg_text = 'Đang mở khoá chương...'

    const url = `/_${ftype}/unlock/${sname}/${sn_id}/${ch_no}/${p_idx}`
    const res = await fetch(url, { method: 'PUT' })

    if (!res.ok) return alert(await res.text())
    const [ok, remain] = await res.json()

    if (ok) {
      msg_text = 'Mở khoá thành công, trang đang tải lại'
      msg_type = 'ok'

      $_user.vcoin = remain
      invalidateAll()
    } else {
      msg_text = 'Mở khóa chương thất bại. Mời thử lại!'
      msg_type = 'err'
    }
  }
</script>

<section class="unlock">
  <h1>
    Lỗi: Chương {rdata.ch_no} phần {rdata.p_idx} cần thiết mở khóa bằng vcoin.
  </h1>

  <p>
    Theo hệ số, bạn cần thiết <span class="vcoin"
      >{vcoin_cost}
      <SIcon name="vcoin" iset="icons" /></span>
    để mở khóa cho chương. Số vcoin bạn đang có:
    <span class="vcoin"
      >{$_user.vcoin}
      <SIcon name="vcoin" iset="icons" /></span>
  </p>

  <p>
    <em> Công thức tính: </em>
    <code>số lượng chữ / 100_000 * hệ số nhân = số vcoin cần thiết</code>
    <br />
    Hệ số nhân hiện tại của danh sách chương:
    <strong class="em">{multp}</strong>.
    {#if ftype == 'up'}<em
        >(Thử liên hệ với chủ sở hữu dự án nếu thấy chưa phù hợp!)</em
      >{/if}
  </p>
  <footer class="actions">
    <div>Thanh toán vcoin để mở khóa chương:</div>

    <button
      type="button"
      class="m-btn _fill _lg _warning"
      class:_disable={$_user.vcoin < vcoin_cost}
      on:click={unlock_chap}>
      <SIcon name="lock-open" />
      <span>Mở khóa</span>
    </button>

    {#if msg_text}<div class="form-msg _{msg_type}">{msg_text}</div>{/if}

    {#if $_user.vcoin < vcoin_cost}
      <div class="em">
        <em>
          Bạn chưa đủ vcoin để mở khóa cho chương. Nạp vcoin theo <a
            href="/hd/donation">hướng dẫn ở đây</a>
        </em>
      </div>
    {/if}
  </footer>
</section>

<style lang="scss">
  .unlock {
    // padding: var(--gutter) ;
    margin-top: 1rem;
    padding: var(--gutter-large) var(--gutter);

    font-size: rem(18px);
    line-height: rem(28px);

    @include fgcolor(secd);

    h1 {
      margin-bottom: 2rem;
    }

    p {
      margin: 1em 0;
      // line-height: var(--textlh);
      text-align: justify;
    }
  }

  a:not(.m-btn) {
    @include fgcolor(primary, 5);
    &:hover {
      text-decoration: underline;
    }
  }

  .em {
    @include fgcolor(warning, 5);
    margin-bottom: 1.5rem;
  }

  .actions {
    @include flex-ca($gap: 0.5rem);
    flex-direction: column;
    padding: 0.75rem 0;
    @include border(--bd-soft, $loc: top);
  }

  .vcoin {
    display: inline-flex;
    align-items: center;
    font-weight: 500;
    @include fgcolor(warning);
    gap: 0.1em;
  }
</style>

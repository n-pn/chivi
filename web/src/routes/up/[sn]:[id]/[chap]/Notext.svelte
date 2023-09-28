<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import type { Pager } from '$lib/pager'

  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { LayoutData } from './$types'

  export let data: LayoutData
  export let pager: Pager

  $: ({ ustem, cinfo, rdata, error, xargs } = data)
  $: vcoin_cost = Math.round(ustem.multp * rdata.zsize * 0.01) / 1000
</script>

<section class="notext">
  {#if error == 413}
    <h1>
      Lỗi: Chương {cinfo.ch_no} phần {xargs.p_idx} cần thiết mở khóa bằng vcoin.
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
      Hệ số nhân hiện tại của dự án: <strong class="em">{ustem.multp}</strong>.
      <em>(Thử liên hệ với chủ sở hữu dự án nếu thấy chưa phù hợp!)</em>
    </p>

    <footer class="actions">
      <div>Thanh toán vcoin để mở khóa chương:</div>
      <a
        class="m-btn _fill _lg _warning"
        class:_disable={$_user.vcoin < vcoin_cost}
        href={pager.gen_url({ force: true })}>
        <SIcon name="lock-open" />
        <span>Mở khóa</span>
      </a>

      {#if $_user.vcoin < vcoin_cost}
        <div class="em">
          <em>
            Bạn chưa đủ vcoin để mở khóa cho chương. Nạp vcoin theo <a
              href="/hd/donation">hướng dẫn ở đây</a>
          </em>
        </div>
      {/if}
    </footer>
  {:else if error == 414}
    <h1>Lỗi: Chương tiết không có nội dung.</h1>
    <p class="em">Liên hệ với chủ sở hữu của dự án để khắc phục.</p>
  {:else if error == 415}
    <h1>Lỗi: Chương {cinfo.ch_no} cần thiết mở khóa.</h1>
    <p>Bạn đã thử mở khóa cho chương, nhưng số lượng vcoin của bạn không đủ.</p>
    <p>
      Hãy nạp vcoin bằng cách ủng hộ trang web theo <a href="/hd/donation"
        >hướng dẫn ở đây</a>
    </p>
  {/if}
</section>

<style lang="scss">
  .notext {
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

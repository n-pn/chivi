<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { seed_path } from '$lib/kit_path'
  import { recrawl_chap } from './shared'

  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { LayoutData } from './$types'
  export let data: LayoutData

  export let _onload = false

  $: ({ nvinfo, cinfo, rdata } = data)

  $: search = `"${nvinfo.ztitle}" ${rdata.ztext[0].replace('　', ' ')}`
  $: seed_href = seed_path(nvinfo.bslug, data.curr_seed.sname)
  $: edit_href = `${seed_href}/+text?ch_no=${cinfo.ch_no}`

  const reload_chap = async () => {
    _onload = true
    const json = await recrawl_chap(data)
    data = { ...data, ...json }
    _onload = false
  }
</script>

<section class="notext">
  {#if $_user.privi < rdata.plock}
    <h1>Bạn không đủ quyền hạn để xem chương {cinfo.ch_no}.</h1>

    <p>
      <strong>
        Quyền hạn tối thiểu để xem chương hiện tại: <x-chap
          >{rdata.plock}</x-chap>
      </strong>
    </p>

    <p class="em">
      <em>
        {#if $_user.privi < 0}
          Bạn chưa đăng nhập, hãy bấm biểu tượng <SIcon name="login" /> bên phải
          màn hình để đăng nhập hoặc đăng ký tài khoản mới.
        {:else}
          Quyền hạn hiện tại của bạn là {$_user.privi}, nâng cấp quyền hạn lên
          <strong>{rdata.plock}</strong> để xem nội dung chương tiết.
        {/if}
      </em>
    </p>

    <h2>Quy ước quyền hạn xem chương:</h2>

    <ul>
      <li>
        Bạn cần quyền hạn tối thiểu là <x-chap>1</x-chap> để xem các chương tiết
        từ nguồn
        <x-seed>Tổng hợp</x-seed>.
      </li>
      <li>
        Bạn cần quyền hạn tối thiểu là <x-chap>2</x-chap> để xem các chương tiết
        từ nguồn cá nhân (bắt đầu bằng <x-seed>@</x-seed>)
      </li>

      <li>
        Bạn cần quyền hạn tối thiểu là <x-chap>3</x-chap> để xem các chương tiết
        từ các nguồn ngoài (bắt đầu bằng <x-seed>!</x-seed>)
      </li>
    </ul>
    <p>
      <em>
        Lưu ý: 1/3 chương đầu của một nguồn truyện thường được đặc cách giảm
        quyền hạn xuống một bậc so với giá trị mặc định.
      </em>
    </p>

    <p>
      <em>
        Lưu ý 2: Quyền hạn xem nội dung của danh sách chương người dùng có thể
        thay đổi theo thiết đặt của cá nhân người dùng.
      </em>
    </p>
  {:else}
    <h1>Chương tiết không có nội dung.</h1>

    <p class="em">
      Bạn có đủ quyền hạn để xem chương, nhưng vì lý do nào đó mà text gốc của
      chương không có trên hệ thống.
    </p>

    <p>
      Nếu bạn đang xem chương tiết từ [Nguồn khác], khả năng cao là nguồn đó đã
      chết trước khi hệ thống kịp lưu text gốc vào ổ cứng.
    </p>

    {#if rdata.rlink}
      <p>
        Chương tiết có liên kết tới nguồn ngoài. Hãy kiểm tra xem nguồn còn đang
        hoạt động hay không: <a href={rdata.rlink} target="_blank"
          >{rdata.rlink}</a>
      </p>
      <p>
        <em
          >Lưu ý: Một số nguồn còn sống, nhưng có cài đặt tường lửa phía trước
          thì hệ thống cũng không tải xuống được. Một số nguồn khác có thể cấm
          truy cập theo vùng địa lý.
        </em>
      </p>
    {/if}

    <h2>Các biện pháp khắc phục:</h2>
    <p>
      Cách tốt nhất khi chương tiết không có nội dung là liên hệ ban quản trị
      chờ xử lý. Tuy vậy, bạn cũng có thể tự mình sửa text chương mà không cần
      phải tốn thời gian chờ đợi sự phản hồi của ban quản trị.
    </p>

    <p>
      Ngoài ra, một số chương tiết được liên kết với nguồn bên ngoài để tải
      xuống tự động, bạn có thể thử bấm [Tải lại nguồn] phía dưới để hệ thống
      thử tải lại text gốc từ nguồn ngoài.
    </p>

    <p>
      <em
        >Lưu ý 1: Liên hệ ban quản trị qua
        <a href="https://discord.gg/mdC3KQH" target="_blank" rel="noreferrer"
          >Discord</a>
        để nhận được phản hồi nhanh nhất.</em>
    </p>

    <p>
      <em
        >Lưu ý 2: Để chắc chắn nhất là chương tiết được kết nối với nguồn ngoài,
        hãy bấm [Cập nhật] bên danh sách chương.
      </em>
    </p>

    <p>
      <em
        >Lưu ý 3: Một số nguồn ngoài có thể ngừng hoạt động theo thời gian, bạn
        có thể vào phần [Cài đặt] để chỉnh sửa các liên kết tới nguồn ngoài.
      </em>
    </p>

    <h3>Tự thêm text gốc cho chương:</h3>
    {#if $_user.privi >= data.seed_data.edit_privi}
      <p>
        Bạn có đủ quyền hạn để thêm text gốc cho bộ truyện, bấm vào nút
        <a href={edit_href}>Thêm text gốc</a>
        bên dưới để tự thêm text của chương.
      </p>

      <p>
        <em>
          Gợi ý: Tìm kiếm nhanh text gốc của chương thông qua các công cụ tìm
          kiếm:
          <a
            href="https://www.google.com/search?q={search}"
            target="_blank"
            rel="noreferrer">Google</a>
          <a
            href="https://www.baidu.com/s?wd={search}"
            target="_blank"
            rel="noreferrer">Baidu</a>
        </em>
      </p>
    {:else}
      <p>
        Bạn chưa đủ quyền hạn dể thêm text gốc cho bộ truyện. Hãy nâng cấp quyền
        hạn ngay hôm nay để mở khóa các tính năng.
      </p>
    {/if}

    <div class="actions">
      <a class="m-btn _primary _fill" href={edit_href}>
        <SIcon name="edit" />
        <span>Thêm text gốc</span>
      </a>

      <button
        class="m-btn _harmful"
        on:click={reload_chap}
        disabled={$_user.privi < rdata.plock}>
        <SIcon name="rotate-rectangle" spin={_onload} />
        <span>Tải lại nguồn</span>
      </button>
    </div>

    <div class="actions">
      <a
        class="m-btn"
        href="https://discord.gg/mdC3KQH"
        target="_blank"
        rel="noreferrer">
        <SIcon name="brand-discord" />
        <span>Liên hệ quản trị</span>
      </a>
    </div>
  {/if}
</section>

<style lang="scss">
  .notext {
    max-width: 48rem;
    // width: 100%;
    // min-height: 30vh;
    margin: auto;

    // padding: var(--gutter) ;
    padding: 1.5rem var(--gutter) 0.75rem;

    font-size: rem(18px);
    line-height: rem(28px);

    // font-size: var(--para-fs);

    // @include flex($center: both);
    @include fgcolor(secd);

    h1 {
      // font-weight: 500;
      @include ftsize(x4);
      // text-align: center;

      margin-bottom: 2rem;
      @include fgcolor(secd);
    }

    h2 {
      @include ftsize(x3);
      // text-align: center;

      margin-top: 1em;
      margin-bottom: 1rem;
    }

    h3 {
      @include ftsize(x2);
      // font-weight: 500;
      @include fgcolor(tert);
      margin-top: 1em;
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

  // ul {
  //   margin-left: 1.5rem;
  // }

  li + li {
    margin-top: 1rem;
  }

  .em {
    @include fgcolor(warning, 5);
    margin-bottom: 1.5rem;
  }

  .actions {
    @include flex-ca($gap: 0.75rem);
    padding-bottom: 0.75rem;
  }

  x-seed {
    display: inline;
    text-transform: uppercase;
    font-weight: 500;
    padding: 0.125em 0.25em;
    font-size: em(13, 16);

    @include fgcolor(primary, 5);
    // @include border(primary, 5);
    // @include bdradi();
  }

  x-chap {
    @include fgcolor(primary, 5);
    font-weight: 500;
  }
</style>

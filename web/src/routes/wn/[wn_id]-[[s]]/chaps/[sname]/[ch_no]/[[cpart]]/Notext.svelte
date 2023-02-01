<script lang="ts">
  import { page } from '$app/stores'
  import { seed_path } from '$lib/kit_path'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let book_info: CV.Nvinfo
  export let curr_seed: CV.Chroot
  export let seed_data: CV.WnSeed
  export let curr_chap: CV.Chinfo
  export let chap_data: CV.Zhchap

  $: _privi = $page.data._user?.privi || 0
  $: search = `"${book_info.btitle_zh}" ${chap_data.title}`
  $: seed_href = seed_path(book_info.bslug, curr_seed.sname)
  $: edit_href = `${seed_href}/${curr_chap.chidx}/+edit`
</script>

<div class="notext">
  {#if !chap_data.grant}
    <h1>Bạn không đủ quyền hạn để xem chương {curr_chap.chidx}.</h1>

    <p>
      <strong>
        Quyền hạn tối thiểu để xem chương hiện tại: <x-chap
          >{chap_data.privi}</x-chap>
      </strong>
    </p>

    <p class="em">
      <em>
        {#if _privi < 0}
          Bạn chưa đăng nhập, hãy bấm biểu tượng <SIcon name="login" /> bên phải
          màn hình để đăng nhập hoặc đăng ký tài khoản mới.
        {:else}
          Quyền hạn hiện tại của bạn là {_privi}, nâng cấp quyền hạn lên
          <strong>{chap_data.privi}</strong> để xem nội dung chương tiết.
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

    <h2>Các biện pháp khắc phục:</h2>
    <p>
      Cách tốt nhất khi chương tiết không có nội dung là liên hệ ban quản trị
      chờ xử lý. Tuy vậy, bạn cũng có thể tự mình sửa text chương mà không cần
      phải tốn thời gian chờ đợi sự phản hồi của ban quản trị.
    </p>
    <p>
      <em
        >Lưu ý: Liên hệ ban quản trị qua
        <a
          href="https://discord.gg/mdC3KQH"
          target="_blank"
          rel="noreferrer noopener">Discord</a>
        để nhận được phản hồi nhanh nhất.</em>
    </p>

    <h3>Tự text gốc cho chương:</h3>
    {#if _privi >= seed_data.edit_privi}
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
            rel="noreferrer noopener">Google</a>
          <a
            href="https://www.baidu.com/s?wd={search}"
            target="_blank"
            rel="noreferrer noopener">Baidu</a>
        </em>
      </p>

      <div class="actions">
        <a class="m-btn _primary _fill _lg" href={edit_href}>
          <SIcon name="edit" />
          <span>Thêm text gốc</span>
        </a>

        <a
          class="m-btn  _lg"
          href="https://discord.gg/mdC3KQH"
          target="_blank"
          rel="noreferrer noopener">
          <SIcon name="brand-discord" />
          <span>Liên hệ quản trị</span>
        </a>
      </div>
    {:else}
      <p>
        Bạn chưa đủ quyền hạn dể thêm text gốc cho bộ truyện. Hãy nâng cấp quyền
        hạn ngay hôm nay để mở khóa các tính năng.
      </p>
    {/if}
  {/if}
</div>

<style lang="scss">
  .notext {
    max-width: 48rem;
    // width: 100%;
    // min-height: 30vh;
    margin: 0 auto;

    // padding: var(--gutter) ;
    padding: 1.5rem 0 0.75rem;

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
    @include flex-ca($gap: 1rem);

    padding-bottom: 1.5rem;
    @include border(--bd-soft, $loc: bottom);
    // margin-bottom: var(--gutter);
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

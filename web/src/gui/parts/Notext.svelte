<script lang="ts">
  import { session } from '$lib/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let nvseed: CV.Chroot
  export let chmeta: CV.Chmeta
  export let chinfo: CV.Chinfo

  function check_privi({ chidx, chars }): number {
    if (chidx <= nvseed.free_chap) return nvseed.privi_map[0]
    else if (chars > 0) return nvseed.privi_map[1]
    else return nvseed.privi_map[2]
  }
</script>

<div class="notext cv-line">
  {#if $session.privi < check_privi(chinfo)}
    <h1>Bạn không đủ quyền hạn để xem chương.</h1>

    <p class="warn">
      <em>
        {#if $session.privi < 0}
          Bạn chưa đăng nhập, hãy bấm biểu tượng <SIcon name="user" /> bên phải màn
          hình để đăng nhập hoặc đăng ký tài khoản mới.
        {:else}
          Nâng cấp quyền hạn của bạn ngay hôm nay để mở khoá các tính năng.
        {/if}
      </em>
    </p>

    <h2>Quy ước quyền hạn xem chương:</h2>

    <ul>
      <li>
        Với các nguồn <x-seed>Tổng hợp</x-seed> và <x-seed>Nhiều người</x-seed>,
        bạn cần thiết đăng nhập để xem nội dung chương.
      </li>
      <li>
        Với các nguồn tải ngoài (ký hiệu <SIcon name="cloud" />), bạn cần quyền
        hạn tối thiểu là <x-chap>1</x-chap>.
      </li>
      <li>
        Một số nguồn tải ngoài nhưng tốc độ hạn chế (ký hiệu <SIcon
          name="cloud-fog" />), bạn cần thiết quyền hạn tối thiểu là
        <x-chap>2</x-chap> để tải xuống các chương chưa được lưu trên máy chủ.
      </li>
      <li>
        Với các danh sách chương tạo bởi người dùng, thông thường bạn cần quyền
        hạn là <x-chap>1</x-chap>, nhưng thông số này có thể sẽ được thay đổi
        bởi cá nhân người sử dụng.
      </li>
    </ul>
    <p>
      Bổ sung: Với các chương nhỏ hơn giá trị đặc biệt là <x-chap
        >{nvseed.free_chap}</x-chap
      >, yêu cầu quyền hạn được giảm xuống 1 mức độ.
    </p>
  {:else}
    <h1>Chương tiết không có nội dung.</h1>

    {#if nvseed.sname == 'users'}
      <p>
        Chương tiết nguồn <x-seed>users</x-seed> được đăng tải bởi người dùng của
        Chivi.
      </p>
      <p>
        Các chương có tựa là "Thiếu chương" là các chương chưa được đăng tải.
      </p>
      <p>
        Bạn có thể liên hệ với các bạn có quyền hạn từ <x-chap>2</x-chap> trở lên
        để khắc phục các chương bị thiếu.
      </p>
    {:else if nvseed.sname == 'zxcs_me'}
      <p>
        Nguồn <x-seed>zxcs.me</x-seed> được tải thủ công từ trang
        <a href="http://www.zxcs.me/" rel="noopener noferrer">zxcs.me</a><br />
        Không có nội dung nghĩa là có lỗi hệ thống. Hãy liên hệ ban quản trị.
      </p>
    {:else if nvseed.sname == 'shubaow'}
      <p>
        Nguồn <x-seed>shubaow</x-seed> không cho phép các IP server truy cập.
      </p>
      <p>
        Liên hệ với ban quản trị nếu bạn thực sự muốn đọc truyện từ nguồn này.
      </p>
    {:else if nvseed.stype == 2}
      <p>Nguồn truyện này hiện tại đã chết hoặc ngừng được hỗ trợ.</p>
      <p>Bạn hãy đổi sang nguồn khác còn sống để xem nội dung chương.</p>
    {:else}
      <p>
        Bạn có quyền xem chương tiết từ nguồn này, nhưng vì lý do nào đó chương
        tiết bị lỗi.
      </p>
      <p>
        Hãy kiểm tra từ <a
          href={chmeta.clink}
          rel="noopener noreferrer"
          target="_blank">trang gốc</a> xem có phải vấn đề từ bên đó hay không.
      </p>
      <p>
        Nếu vấn đề thuộc về bên Chivi, hãy liên hệ với ban quản trị để khắc
        phục.
      </p>
    {/if}
  {/if}
</div>

<style lang="scss">
  .notext {
    max-width: 48rem;
    min-height: 30vh;
    margin: 0 auto;
    padding: 1rem;

    font-size: var(--para-fs);

    // @include flex($center: both);
    @include fgcolor(secd);

    h1 {
      // font-weight: 500;
      @include ftsize(x4);
      text-align: center;

      margin-bottom: 2rem;
      @include fgcolor(secd);
    }

    h2 {
      @include ftsize(x3);
      text-align: center;

      margin-top: 1rem;
      margin-bottom: 1rem;
    }

    p {
      margin: 1em;
      line-height: var(--textlh);
      text-align: justify;
    }

    li {
      line-height: var(--textlh);
      text-align: justify;
    }

    :global(svg) {
      margin-bottom: 0.2em;
    }
  }

  a {
    @include fgcolor(primary, 5);
    &:hover {
      text-decoration: underline;
    }
  }

  ul {
    margin-left: 1.5rem;
  }

  li + li {
    margin-top: 1rem;
  }

  .warn {
    @include fgcolor(warning, 5);
    margin-bottom: 1.5rem;
  }

  x-seed {
    display: inline;
    text-transform: uppercase;
    font-weight: 500;
    padding: 0.125em 0.25em;
    font-size: em(12, 16);

    @include fgcolor(primary, 5);
    @include border(primary, 5);
    @include bdradi();
  }

  x-chap {
    @include fgcolor(primary, 5);
    font-weight: 500;
  }
</style>

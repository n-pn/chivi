<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let crepo: CV.Tsrepo
  export let rdata: CV.Chpart
  export let state = 0

  $: search = crepo.zname ? `${crepo.zname} ${rdata.zname}` : ''

  let _loading = false

  const reload_chap = async () => {
    _loading = true

    const { ch_no, p_idx } = rdata

    const url = `/_rd/chaps/${crepo.sroot}/${ch_no}/${p_idx}?regen=true`
    const res = await fetch(url, { cache: 'no-cache' })

    _loading = false

    if (res.ok) {
      state = 3
      rdata = await res.json()
      window.location.reload()
    } else {
      alert(await res.text())
    }
  }
</script>

<section class="notext">
  <h1 class="u-warn">Lỗi: Chương tiết không có nội dung.</h1>

  {#if $_user.privi < -1}
    <p class="u-warn">
      Bạn chưa đăng nhập! Chức năng tự tải chương tiết từ nguồi ngoài chỉ được
      áp dụng cho người dùng đã đăng nhập vào hệ thống!
    </p>
  {:else if $_user.privi == -1}
    <p class="u-warn">
      Tài khoản của bạn chưa được kích hoạt, bạn cần nâng cấp lên ít nhất là 0
      để xem các chương tiết chưa được tải xuống.
    </p>
  {/if}

  {#if crepo.stype == 1}
    <p>
      Bạn đang đọc nội dung do người dùng Chivi tự quản lý. Thử liên hệ với chủ
      sở hữu của dự án để họ tìm cách khắc phục.
    </p>
  {:else if crepo.stype == 2}
    <p>
      Bạn đang xem chương tiết được liên kết với nguồn ngoài. Khả năng cao là do
      nguồn ngoài đã chết nên text gốc không tải xuống được.
    </p>
    <p>
      Hãy thử đổi sang các nguồn nhúng ngoài khác, hoặc thử các danh sách chương
      tiết khác được liên kết với bộ truyện.
    </p>
  {:else}
    <p>
      Liên hệ ban quản trị để tìm cách khắc phục. Hoặc bạn có thể tự thêm text
      gốc cho chương nếu đủ quyền hạn.
    </p>
  {/if}

  {#if rdata.rlink}
    <p>
      Chương tiết có liên kết tới trang ngoài. Bấm <a
        href={rdata.rlink}
        target="_blank">vào đây</a> để kiểm tra xem nguồn còn sống hay không. Nếu
      nguồn còn sống, hãy thử bấm vào [Tải lại nguồn] phía dưới.
    </p>
    <p>
      <em
        >Lưu ý: Một số nguồn còn sống, nhưng có cài đặt tường lửa phía trước thì
        hệ thống cũng không tải xuống được. Một số nguồn khác có thể cấm truy
        cập theo vùng địa lý. Liên hệ với ban quản trị nếu còn gặp lỗi.
      </em>
    </p>
  {/if}

  <h2 class="u-warn">Tự thêm text gốc cho chương:</h2>
  {#if $_user.privi >= crepo.plock}
    <p>
      Bạn có đủ quyền hạn để thêm text gốc cho bộ truyện, bấm vào nút
      <a href="up?start={rdata.ch_no}">Thêm text gốc</a>
      bên dưới để tự thêm text của chương.
    </p>

    {#if search}
      <p class="flow">
        <em>
          Gợi ý: Thử tìm text gốc thông qua
          <a
            href="https://www.google.com/search?q={search}"
            target="_blank"
            rel="noreferrer">Google</a>
          hoặc
          <a
            href="https://www.baidu.com/s?wd={search}"
            target="_blank"
            rel="noreferrer">Baidu</a>
          .
        </em>
      </p>
    {/if}
  {:else if crepo.stype < 1}
    <p>
      Các danh sách chương tiết <x-sname>Tổng hợp</x-sname>,
      <x-sname>Tạm thời</x-sname> và <x-sname>Chính thức</x-sname> của truyện chữ
      cho phép các bạn tải text gốc lên nếu bạn có đủ quyền hạn.
    </p>

    <p>
      Để nâng cấp quyền hạn bạn có thể tham khảo: <a
        href="/hd/nang-cap-quyen-han"
        target="_blank">Hướng dẫn nâng cấp quyền hạn</a
      >.
    </p>
  {:else if crepo.stype == 2}
    <p>Chương tiết do chủ sưu tầm quản lý.</p>
  {:else}
    <p>
      Text từ nguồn nhúng ngoài thường được tải tự động, nhưng bạn có thể tự sửa
      text gốc nếu quyền hạn của bạn tối thiểu là <strong class="u-warn"
        >3</strong>
    </p>

    <p>
      Để nâng cấp quyền hạn bạn có thể tham khảo: <a
        href="/hd/nang-cap-quyen-han"
        target="_blank">Hướng dẫn nâng cấp quyền hạn</a
      >.
    </p>
  {/if}

  <div class="actions">
    <a class="m-btn _primary _fill" href="up?start={rdata.ch_no}">
      <SIcon name="edit" />
      <span>Thêm text gốc</span>
    </a>

    <button
      class="m-btn _harmful"
      on:click={reload_chap}
      disabled={$_user.privi < 0 || !rdata.rlink}
      data-umami-event="reinit-chap">
      <SIcon name="rotate-rectangle" spin={_loading} />
      <span>Tải lại nguồn</span>
    </button>
  </div>

  <div class="actions">
    <a
      class="m-btn _success"
      href="https://discord.gg/mdC3KQH"
      target="_blank"
      rel="noreferrer"
      data-umami-event="goto-discord">
      <SIcon name="brand-discord" />
      <span>Liên hệ ban quản trị</span>
    </a>
  </div>
</section>

<style lang="scss">
  a:not(.m-btn) {
    @include fgcolor(primary, 5);
    &:hover {
      text-decoration: underline;
    }
  }

  .actions {
    @include flex-ca($gap: 0.5rem);
    // padding-bottom: 0.75rem;
    padding: 0.75rem 0;
    @include border(--bd-soft, $loc: top);
  }
</style>

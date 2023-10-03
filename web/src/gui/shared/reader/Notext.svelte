<script lang="ts">
  import { invalidateAll } from '$app/navigation'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let rstem: CV.Rdstem
  export let rdata: CV.Chpart

  $: search = rstem.zname ? `${rstem.zname} ${rdata.ztext[0]}` : ''

  let _loading = false
  let msg_text = ''
  let msg_type = ''

  const reload_chap = async () => {
    _loading = true

    const url = `/_wn/${rstem.sname}/${rstem.sn_id}/${rdata.ch_no}`
    const res = await fetch(url, { method: 'PUT' })
    _loading = false

    if (res.ok) {
      msg_text = 'Tải lại thành công, trang đang tải lại..'
      msg_type = 'ok'
      invalidateAll()
    } else {
      msg_text = await res.text()
      msg_type = 'err'
    }
  }
</script>

<section class="notext">
  <h1 class="em">Lỗi: Chương tiết không có nội dung.</h1>

  {#if rstem.stype == 'up'}
    <p>
      Bạn đang đọc nội dung do người dùng Chivi tự quản lý. Thử liên hệ với chủ
      sở hữu của dự án để họ tìm cách khắc phục.
    </p>
  {:else if rstem.stype == 'rm'}
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

  <h2 class="em">Tự thêm text gốc cho chương:</h2>
  {#if $_user.privi >= rstem.plock}
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
  {:else if rstem.stype == 'wn'}
    <p>
      Các danh sách chương tiết <x-sname>Tổng hợp</x-sname>,
      <x-sname>Tạm thời</x-sname> và <x-sname>Chính thức</x-sname> của truyện chữ
      cho phép các bạn tải text gốc lên nếu bạn có đủ quyền hạn.
    </p>
    <ul>
      <li>
        Nguồn <x-sname>Tổng hợp</x-sname> cần quyền hạn tối thiểu là
        <strong class="em">2</strong> để thêm sửa text.
      </li>
      <li>
        Nguồn <x-sname>Tạm thời</x-sname> cần quyền hạn tối thiểu là
        <strong class="em">1</strong> để thêm sửa text.
      </li>
      <li>
        Nguồn <x-sname>Chính thức</x-sname> cần quyền hạn tối thiểu là
        <strong class="em">3</strong> để thêm sửa text.
      </li>
    </ul>

    <p>
      Để nâng cấp quyền hạn bạn có thể tham khảo: <a
        href="/hd/nang-cap-quyen-han"
        target="_blank">Hướng dẫn nâng cấp quyền hạn</a
      >.
    </p>
  {:else if rstem.stype == 'up'}
    <p>
      Chương tiết do <x-sname>{rstem.sname}</x-sname> quản lý. Hãy liên hệ với {rstem.sname}
      nếu muốn đóng góp text gốc.
    </p>
  {:else}
    <p>
      Text từ nguồn nhúng ngoài thường được tải tự động, nhưng bạn có thể tự sửa
      text gốc nếu quyền hạn của bạn tối thiểu là <strong class="em">3</strong>
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
      disabled={$_user.privi < rdata.plock || !rdata.rlink}>
      <SIcon name="rotate-rectangle" spin={_loading} />
      <span>Tải lại nguồn</span>
    </button>
  </div>

  {#if msg_text}
    <div class="form-msg _{msg_type}">{msg_text}</div>
  {/if}

  <div class="actions">
    {#if rstem.stype == 'up'}
      <a class="m-btn _success" href="/{rstem.sname}" target="_blank">
        <SIcon name="at" />
        <span>Liên hệ chủ dự án</span>
      </a>
    {:else}
      <a
        class="m-btn _success"
        href="https://discord.gg/mdC3KQH"
        target="_blank"
        rel="noreferrer">
        <SIcon name="brand-discord" />
        <span>Liên hệ ban quản trị</span>
      </a>
    {/if}
  </div>
</section>

<style lang="scss">
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
    // padding-bottom: 0.75rem;
    padding: 0.75rem 0;
    @include border(--bd-soft, $loc: top);
  }
</style>

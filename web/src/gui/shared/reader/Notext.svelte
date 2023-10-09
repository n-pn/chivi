<script lang="ts">
  import { invalidateAll } from '$app/navigation'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let cstem: CV.Chstem
  export let rdata: CV.Chpart
  export let state = 0

  $: search = cstem.zname ? `${cstem.zname} ${rdata.zname}` : ''

  let _loading = false

  const reload_chap = async () => {
    _loading = true

    const { stype, sname, sn_id } = cstem
    const { ch_no, p_idx } = rdata

    const url = `/_rd/chaps/${stype}/${sname}/${sn_id}/${ch_no}/${p_idx}?regen=true`
    const res = await fetch(url, { cache: 'no-cache' })

    _loading = false

    if (res.ok) {
      rdata = await res.json()
      invalidateAll()

      // state = 3
    } else {
      alert(await res.text())
    }
  }
</script>

<section class="notext">
  <h1 class="em">Lỗi: Chương tiết không có nội dung.</h1>

  {#if cstem.stype == 'up'}
    <p>
      Bạn đang đọc nội dung do người dùng Chivi tự quản lý. Thử liên hệ với chủ
      sở hữu của dự án để họ tìm cách khắc phục.
    </p>
  {:else if cstem.stype == 'rm'}
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
  {#if $_user.privi >= cstem.plock}
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
  {:else if cstem.stype == 'wn'}
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
  {:else if cstem.stype == 'up'}
    <p>
      Chương tiết do <x-sname>{cstem.sname}</x-sname> quản lý. Hãy liên hệ với {cstem.sname}
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
      disabled={$_user.privi < 0 || !rdata.rlink}>
      <SIcon name="rotate-rectangle" spin={_loading} />
      <span>Tải lại nguồn</span>
    </button>
  </div>

  <div class="actions">
    {#if cstem.stype == 'up'}
      <a class="m-btn _success" href="/{cstem.sname}" target="_blank">
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

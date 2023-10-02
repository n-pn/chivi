<script lang="ts">
  import Unlock from './Unlock.svelte'

  export let rstem: CV.Rdstem

  export let cinfo: CV.Wnchap
  export let rdata: CV.Chpart
  export let xargs: CV.Chopts

  export let error = 0
  $: [ftype] = rdata.fpath.split(/[:\/\-]/)
</script>

<section class="notext">
  {#if error == 413}
    <Unlock multp={rstem.multp} {cinfo} {rdata} {xargs} />
  {:else if error == 414}
    <h1>Lỗi: Chương tiết không có nội dung.</h1>

    <p class="em">
      Bạn có đủ quyền hạn để xem chương, nhưng vì lý do nào đó mà text gốc của
      chương không có trên hệ thống.
    </p>

    {#if ftype == 'up'}
      <p>
        Bạn đang đọc nội dung do người dùng Chivi tự quản lý. Thử liên hệ với
        chủ sở hữu của dự án để họ tìm cách khắc phục.
      </p>
    {:else if ftype == 'rm'}
      <p>
        Bạn đang xem chương tiết được liên kết với nguồn ngoài. Khả năng cao là
        do nguồn ngoài đã chết nên text gốc không tải xuống được.
      </p>
      <p>
        Hãy thử đổi sang các nguồn ngoài khác, hoặc thử các danh sách chương
        tiết khác được liên kết với bộ truyện.
      </p>
    {:else}
      <p />
    {/if}
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

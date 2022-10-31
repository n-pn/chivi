<script lang="ts">
  import { page } from '$app/stores'

  export let tab = 3

  $: session = $page.data._user
</script>

<p class="lead">Vcoin là đơn vị tiền tệ ảo được dùng trong Chivi.</p>
<p>
  Bạn có thể dùng vcoin để nâng cấp quyền hạn, biếu tặng người khác, hoặc sử
  dụng các tiện ích nâng cao khác sẽ được phát triển trong tương lai gần.
</p>

{#if session.vcoin_avail >= 10 && session.privi < 1}
  <button class="btn-link" on:click={() => (tab = 2)}>
    <span>Dùng vcoin để nâng cấp quyền hạn</span>
  </button>
{/if}

<h3>Làm sao để có vcoin</h3>

<h4>Ủng hộ trang web trực tiếp bằng tiền mặt</h4>

<p>Tham khảo: <a href="/guide/donation">Ủng hộ Chivi</a></p>

<p class="em">
  Chvi hiện không sống bằng quảng cáo, tiền ủng hộ của các bạn là đầu vào duy
  nhất để nuôi sống trang web.
</p>

<h4>Đóng góp vào sự phát triển của trang web</h4>
<p>
  Bạn sẽ được thưởng một lượng vcoin nhỏ từ 1~50 vcoin bằng cách tích cực đóng
  góp nội dung cho trang web, báo lỗi hệ thống, thảo luận tính năng...
</p>

<p class="em">(Phần này đang được hoàn thiện, sẽ bổ sung chi tiết sau)</p>
<ul />

<style lang="scss">
  .lead {
    font-weight: 500;
    font-size: rem(17px);
  }

  // @include ftsize(sm);
  * + * {
    margin-top: 0.5rem;
    line-height: 1.375rem;
  }

  a {
    @include fgcolor(primary, 5);
    font-weight: 500;
  }

  h3 {
    @include border($loc: bottom);
    margin-top: 1rem;
  }

  h4 {
    font-weight: 500;
    font-size: rem(17px);
    margin-top: 1rem;
  }

  .em {
    font-style: italic;
    @include fgcolor(warning, 5);
  }
</style>

<script lang="ts">
  import { session } from '$app/stores'

  export let tab = 3
</script>

<p class="lead">Vcoin là đơn vị tiền tệ ảo được dùng trong Chivi.</p>
<p>
  Bạn có thể dùng vcoin để nâng cấp quyền hạn, biếu tặng người khác, hoặc sử
  dụng các tiện ích nâng cao khác sẽ được phát triển trong tương lai gần.
</p>

{#if $session.vcoin_avail >= 10 && $session.privi < 1}
  <button class="btn-link" on:click={() => (tab = 2)}>
    <span>Dùng vcoin để nâng cấp quyền hạn</span>
  </button>
{/if}

<h3>Làm sao để có vcoin</h3>

<h4>Ủng hộ trang web trực tiếp bằng tiền mặt</h4>

<h5>Quốc tế</h5>
<ul>
  <li>
    Ko-fi: <a href="https://ko-fi.com/chivi" rel="external">ko-fi.com/chivi</a>
  </li>
  <li>
    Paypay:
    <a href="https://www.paypal.com/paypalme/nipinium" rel="external"
      >paypal.me/nipinium</a>
  </li>
</ul>

<h5>Việt Nam</h5>

<ul>
  <li>
    Ví Momo: <a href="https://nhantien.momo.vn/aJ5Ks0ug0Hp" rel="external"
      >aJ5Ks0ug0Hp</a>
  </li>
  <li>Techcombank: <strong>19034964108016</strong></li>
</ul>
<p class="sm">Quy ước trao đổi: 1000 VND = 1 vcoin, $1 USD = 20 vcoin.</p>
<p class="em">
  Chvi hiện không sống bằng quảng cáo, tiền ủng hộ của các bạn là điều sống còn
  cho sự tồn tại và phát triển của trang web.
</p>

<h4>Đóng góp vào sự phát triển của trang web</h4>
<p>
  Bạn sẽ được thưởng một lượng vcoin nhỏ (từ 1 ~ 50 vcoin) bằng cách tích cực
  đóng góp nội dung cho trang web, báo lỗi hệ thống, thảo luận tính năng...
</p>

<p class="em">Phần này đang được hoàn thiện, sẽ bổ sung chi tiết sau</p>
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

  h3 {
    @include border($loc: bottom);
    margin-top: 1rem;
  }

  h4 {
    font-weight: 500;
    font-size: rem(17px);
    margin-top: 1rem;
  }

  h5 {
    @include fgcolor(tert);
  }

  li + li {
    margin-top: 0.25rem;
  }

  .sm {
    @include ftsize(sm);
    line-height: 1.25rem;
    @include fgcolor(secd);
  }

  .em {
    font-style: italic;
    @include fgcolor(warning, 5);
  }
</style>

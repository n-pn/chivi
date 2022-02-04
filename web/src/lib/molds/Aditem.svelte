<script>
  export let type = 'banner'
</script>

<section>
  <ins
    class="adsbygoogle"
    style="display:block; text-align:center;"
    data-ad-client="ca-pub-5468438393284967"
    data-ad-slot={type == 'banner' ? '2323076740' : '1006213923'}
    data-ad-format={type == 'banner' ? 'auto' : 'fluid'}
    data-ad-layout={type == 'banner' ? '' : 'in-article'}
    data-full-width-responsive="true" />
  <div>
    <p>Bạn đang bật adblock, hoặc adsense vì lý do nào đó không chạy :(</p>
    <p>Quảng cáo là yếu tố thiết yếu để trang tiếp tục tồn tại.</p>
    <p>
      Xin hãy tắt adblock, hoặc nâng cấp quyền hạn lên <strong>2</strong> để không
      phải xem quảng cáo.
    </p>
  </div>

  <script>
    ;(window.adsbygoogle = window.adsbygoogle || []).push({})
  </script>
</section>

<style lang="scss">
  section {
    margin: 1rem 0;
  }

  ins:empty + div {
    padding: 0.75rem var(--gutter);
    text-align: center;

    @include bdradi();
    @include fgcolor(neutral, 7);
    @include bgcolor(harmful, 1);
  }

  ins:not(:empty) + div {
    display: none;
  }

  p {
    font-size: 500;
    margin: 0;
    @include ftsize(lg);
  }
</style>

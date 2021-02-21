<script>
  export let type = 'banner'
</script>

<section>
  <ins
    class="adsbygoogle"
    data-ad-client="ca-pub-5468438393284967"
    data-ad-slot={type == 'banner' ? 2323076740 : 4952630589}
    data-ad-format={type == 'banner' ? 'auto' : 'fluid'}
    data-ad-layout={type == 'banner' ? '' : 'in-article'}
    data-full-width-responsive="true">
    <div>Quảng cáo nuôi server. Xin đừng bật adblock.</div>
  </ins>

  <script
    async
    src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>

  <script>
    try {
      setTimeout(() => (window.adsbygoogle || []).push({}), 100)
    } catch (ads_error) {
      console.log(ads_error)
    }
  </script>
</section>

<style lang="scss">
  ins {
    display: block;
    max-width: 100%;
    text-align: center;
    text-decoration: none;
  }

  div {
    padding: 2rem;
    text-transform: uppercase;
    font-size: 400;

    @include radius();
    @include fgcolor(neutral, 7);
    @include bgcolor(yellow, 1, 0.9);
  }
</style>

<script>
  export let type = 'banner'
  $: ad_slot = type == 'banner' ? 2323076740 : 4952630589
  $: ad_format = type == 'banner' ? 'auto' : 'fluid'
  $: ad_layout = type == 'banner' ? '' : 'in-article'
</script>

<section>
  <ins
    class="adsbygoogle"
    data-ad-client="ca-pub-5468438393284967"
    data-ad-slot={ad_slot}
    data-ad-format={ad_format}
    data-ad-layout={ad_layout}
    data-full-width-responsive="true">
    <div>Quảng cáo để kiếm tiền nuôi server, xin đừng vội block 😢</div>
  </ins>
  <script>
    try {
      setTimeout(() => {
        ;(window.adsbygoogle = window.adsbygoogle || []).push({})
      }, 200)
    } catch (ads_error) {
      console.log(ads_error)
    }
  </script>
</section>

<style lang="scss">
  ins {
    display: block;
    min-width: 250px;
    max-width: 100%;
    text-align: center;
    text-decoration: none;
  }

  div {
    padding: 2rem;
    text-transform: uppercase;
    @include radius();
    @include fgcolor(neutral, 7);
    @include bgcolor(yellow, 1);
  }
</style>

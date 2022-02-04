<script>
  export let type = 'banner'
</script>

<section>
  {@html `<ins class="adsbygoogle" style="display:block; text-align:center;"
    data-ad-client="ca-pub-5468438393284967"
    data-ad-slot=${type == "banner" ? "2323076740" : "1006213923"}
    data-ad-format=${type == "banner" ? 'auto' : "fluid"}
    data-ad-layout=${type == "banner" ? '' : "in-article"}
    data-full-width-responsive="true" />`}
  {@html "<script>;(window.adsbygoogle = window.adsbygoogle || []).push({})</script>"}
</section>

<style lang="scss">
  section {
    margin: 1rem 0;
  }
</style>

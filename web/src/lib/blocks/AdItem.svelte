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
    <div>Hãy ủng hộ cho chivi <a href="/notes/donation">tại đây</a> nếu không muốn xem quảng cáo.</div>
  </ins>

  <script>
    if (typeof window != undefined) {
      try {
        ;(window.adsbygoogle = window.adsbygoogle || []).push({})
      } catch (aderr) {
        console.log({aderr})
      }
    }
  </script>
</section>

<style lang="scss">
  ins {
    display: block;
    margin: 1rem 0;
    max-width: 100%;
    text-align: center;
    text-decoration: none;
  }

  div {
    padding: 3rem;
    text-transform: uppercase;
    font-size: 500;

    @include radius(6px);
    @include fgcolor(neutral, 7);
    @include bgcolor(red, 1, 0.7);

  }
  a {
    @include fgcolor(primary, 6);
    font-weight: 600;
  }
</style>

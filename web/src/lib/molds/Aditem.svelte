<script context="module">
  export function ad_indexes(len, min = 15) {
    let res = []

    for (let idx = 0; idx < len; idx += random_int(min - 5, min + 5)) {
      res.push(idx)
    }

    return res
  }

  function random_int(min, max) {
    return Math.round(Math.random() * (max - min)) + min
  }
</script>

<script>
  export let type = 'banner'
</script>

<ins
  class="adsbygoogle"
  data-ad-client="ca-pub-5468438393284967"
  data-ad-slot={type == 'banner' ? 2323076740 : 4952630589}
  data-ad-format={type == 'banner' ? 'auto' : 'fluid'}
  data-ad-layout={type == 'banner' ? '' : 'in-article'}
  data-full-width-responsive="true">
  <div>
    Hãy ủng hộ cho chivi <a href="/notes/donation">tại đây</a> nếu không muốn xem
    quảng cáo.
  </div>
  <script>
    if (browser) {
      try {
        ;(window.adsbygoogle = window.adsbygoogle || []).push({})
      } catch (aderr) {
        console.log({ aderr })
      }
    }
  </script>
</ins>

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

    @include bdradi();
    @include fgcolor(neutral, 7);
    @include bgcolor(harmful, 1);
  }

  a {
    @include fgcolor(primary, 6);
    font-weight: 600;
  }
</style>

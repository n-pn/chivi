<script>
  export let key = ''
</script>

<style lang="scss">
  footer {
    display: flex;
    align-items: center;
    justify-content: center;

    margin: 0;
    border-top: 1px solid color(neutral, 3);

    @include bgcolor(neutral, 1);
    @include radius($sides: bottom);
  }

  a {
    // display: inline-block;
    cursor: pointer;
    line-height: 1rem;
    padding: 0.5rem;
    // border-left: 1px solid color(neutral, 3);

    // max-width: 25vw;
    // overflow: hidden;
    // @include truncate();

    @include font-size(2);
    @include fgcolor(neutral, 7);

    &:hover {
      background-color: color(neutral, 3);
    }
  }
</style>

<footer>
  <a
    class="footer-link"
    href="https://www.iciba.com/word?w={key}"
    target="_blank"
    rel="noopener noreferer">
    iCIBA
  </a>

  <a
    class="footer-link"
    href="https://translate.google.com/#view=home&op=translate&sl=zh-CN&tl=en&text={key}"
    target="_blank"
    rel="noopener noreferer">
    GTrans
  </a>

  <a
    class="footer-link"
    href="https://www.google.com/search?q={key}"
    target="_blank"
    rel="noopener noreferer">
    Google
  </a>

  <a
    class="footer-link"
    href="https://fanyi.baidu.com/#zh/en/{key}"
    target="_blank"
    rel="noopener noreferer">
    Fanyi
  </a>

  <a
    class="footer-link"
    href="https://baike.baidu.com/item/{key}"
    target="_blank"
    rel="noopener noreferer">
    Baike
  </a>

  <a
    class="footer-link"
    href="http://www.baidu.com/s?wd={key}"
    target="_blank"
    rel="noopener noreferer">
    Baidu
  </a>
</footer>

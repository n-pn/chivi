<script context="module">
  function gen_links(input) {
    return [
      [
        'Gtrans',
        `https://translate.google.com/#view=home&op=translate&sl=zh-CN&tl=en&text=${input}`,
      ],
      ['Google', `https://www.google.com/search?q=${input}`],
      ['Fanyi', `https://fanyi.baidu.com/#zh/en/${input}`],
      ['Baidu', `http://www.baidu.com/s?wd=${input}`],
      ['Baike', `https://baike.baidu.com/item/${input}`],
      ['iCIBA', `https://www.iciba.com/${input}`],
    ]
  }
</script>

<script>
  export let input = ''
  $: links = gen_links(input)
</script>

<footer>
  {#each links as [name, href]}
    <a {href} target="_blank" rel="noopener noreferer"> {name} </a>
  {/each}
</footer>

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
    padding: 0.5rem;
    line-height: 1rem;
    // border-left: 1px solid color(neutral, 3);

    // max-width: 25vw;
    // overflow: hidden;
    // @include truncate();

    @include font-size(2);
    @include fgcolor(neutral, 7);

    &:hover {
      @include bgcolor(neutral, 3);
    }
  }
</style>

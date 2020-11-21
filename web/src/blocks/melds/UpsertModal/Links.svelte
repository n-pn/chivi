<script context="module">
  function gen_links(str) {
    return [
      [
        'G.Trans',
        `https://translate.google.com/#view=home&op=translate&sl=zh-CN&tl=en&text=${str}`,
      ],
      ['Google', `https://www.google.com/search?q=${str}`],
      ['Fanyi', `https://fanyi.baidu.com/#zh/en/${str}`],
      ['Baidu', `http://www.baidu.com/s?wd=${str}`],
      ['Baike', `https://baike.baidu.com/item/${str}`],
      ['iCIBA', `https://www.iciba.com/${str}`],
    ]
  }
</script>

<script>
  export let hanzi = ''
  $: links = gen_links(hanzi)
</script>

<div>
  {#each links as [name, href]}
    <a {href} target="_blank" rel="noopener noreferer"> {name} </a>
  {/each}
</div>

<style lang="scss">
  // div {
  //   display: flex;
  //   // align-items: center;
  //   justify-content: center;
  // }

  // a {
  //   cursor: pointer;
  //   padding: 0.5rem;
  //   line-height: 1rem;

  //   @include font-size(2);
  //   @include fgcolor(neutral, 7);

  //   &:hover {
  //     @include bgcolor(neutral, 3);
  //   }
  // }
</style>

<script>
  export let key = ''
  $: links = [
    [
      'G.Trans',
      `https://translate.google.com/?sl=zh-CN&tl=en&text=${key}&op=translate`,
    ],
    ['Fanyi', `https://fanyi.baidu.com/#zh/en/${key}`],
    ['iCIBA', `https://www.iciba.com/word?w=${key}`],
    ['Baidu', `http://www.baidu.com/s?wd=${key}`],
    ['G.Search', `https://www.google.com/search?q=${key}`],
  ]
</script>

<footer class="foot">
  {#each links as [name, href]}
    <a class="link" {href} target="_blank" rel="noopener noreferer">{name}</a>
  {/each}
</footer>

<style lang="scss">
  .foot {
    @include flex($center: horz);
    @include border(--bd-main, $sides: top);
  }

  .link {
    cursor: pointer;
    padding: 0 0.75rem;
    line-height: 2.25rem;

    @include ftsize(sm);
    @include fgcolor(secd);

    &:hover {
      @include fgcolor(primary, 5);
    }
  }
</style>

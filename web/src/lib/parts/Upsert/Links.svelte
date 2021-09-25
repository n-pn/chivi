<script>
  import { fhint } from './_shared'

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
  {#if $fhint}
    <div class="hint">{@html $fhint}</div>
  {:else}
    {#each links as [name, href]}
      <a class="link" {href} target="_blank" rel="noopener noreferer">{name}</a>
    {/each}
  {/if}
</footer>

<style lang="scss">
  .foot {
    @include flex($center: horz);
    @include border(--bd-soft, $loc: top);
  }

  $height: 2.25rem;

  .link {
    cursor: pointer;
    padding: 0 0.75rem;
    line-height: $height;

    @include ftsize(sm);
    @include fgcolor(secd);

    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  .hint {
    $line-height: 1.5rem;
    @include ftsize(sm);
    margin: math.div($height - $line-height, 2) 0;
    line-height: $line-height;
    @include clamp();
    @include fgcolor(tert);
  }
</style>

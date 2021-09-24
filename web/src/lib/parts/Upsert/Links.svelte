<script>
  export let key = ''
  export let vhint = -1
  export let dlabel = ''

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

  const hints = [
    'Gợi ý: Nhập nghĩa là <code>[[pass]]</code> nếu bạn muốn xoá đè.',
    'Lưu dữ liệu vào từ điển cộng đồng (mọi người dùng chung)',
    'Lưu dữ liệu vào từ điển cá nhân (chỉ dành cho bạn)',
    `Từ điển riêng cho bộ truyện ${dlabel}`,
    'Từ điển chung cho tất cả các bộ truyện',
    'Phiên âm Hán Việt cho tên người, sự vật...',
    'Độ ưu tiên của từ trong câu văn: Hơi cao',
    'Độ ưu tiên của từ trong câu văn: Trung bình',
    'Độ ưu tiên của từ trong câu văn: Hơi thấp',
    'Độ ưu tiên của từ trong câu văn: Rất thấp',
  ]

  $: hint = hints[vhint]
</script>

<footer class="foot" on:mouseenter|stopPropagation={() => (vhint = -1)}>
  {#if hint}
    <div class="hint">{@html hint}</div>
  {:else}
    {#each links as [name, href]}
      <a class="link" {href} target="_blank" rel="noopener noreferer">{name}</a>
    {/each}
  {/if}
</footer>

<style lang="scss">
  .foot {
    @include flex($center: horz);
    @include border(--bd-main, $loc: top);
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

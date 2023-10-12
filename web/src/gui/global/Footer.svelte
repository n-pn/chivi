<script>
  const links = [
    ['Discord', 'https://discord.gg/mdC3KQH'],
    ['Github', 'https://github.com/np-nam/chivi'],
    ['Facebook', 'https://www.facebook.com/chivi.fb/'],
  ]

  const tools = [
    ['Dịch nhanh', '/sp/qtran'],
    ['Phồn -> Giản', '/sp/opencc'],
  ]
</script>

<footer class="foot">
  <div class="main">
    <a href="/hd/donation" class="foot-link">Ủng hộ trang</a>

    <span class="sep" />
    <strong>Liên kết: </strong>
    {#each links as [text, href], index}
      {#if index > 0} <span class="sep" />{/if}
      <a {href} class="foot-link" target="_blank" rel="noreferrer">{text}</a>
    {/each}
  </div>
</footer>

<style lang="scss">
  .foot {
    line-height: 1rem;

    margin-top: auto;
    padding: 0.75rem;

    @include ftsize(sm);
    @include border($loc: top);
    @include fgcolor(tert);
    // @include bgcolor(tert);
  }

  // .secd {
  //   margin-top: 0.25rem;
  // }

  // .secd,
  .main {
    @include flex-cx;
    flex-wrap: wrap;
    width: 100%;
    gap: 0.375rem;
  }

  .sep {
    &:before {
      @include fgcolor(mute);
      content: '|';
    }
  }

  // prettier-ignore
  .foot-link {
    font-weight: 500;
    @include fgcolor(primary, 6);
    &:hover { @include fgcolor(primary, 4); }
  }
</style>

<script>
  const links = [
    ['Discord', 'https://discord.gg/mdC3KQH'],
    ['Github', 'https://github.com/np-nam/chivi'],
    ['Facebook', 'https://www.facebook.com/chivi.fb/'],
  ]
</script>

<footer class="foot">
  <div class="foot-left">
    <a href="/guide/donation" class="foot-link">Ủng hộ trang</a>
  </div>

  <div class="foot-right">
    <strong>Liên kết: </strong>
    {#each links as [text, href]}
      <a {href} class="foot-link" target="_blank" rel="noreferrer noopener"
        >{text}</a>
    {/each}
  </div>
</footer>

<style lang="scss">
  .foot {
    line-height: 1.25rem;
    display: flex;
    flex-wrap: wrap;
    width: 100%;
    justify-content: center;
    margin-top: auto;
    padding: var(--gutter-pl);

    @include ftsize(sm);
    @include border($loc: top);
    @include fgcolor(tert);
    @include bgcolor(tert);
  }

  .foot-right {
    &:before {
      @include fgcolor(mute);
      margin: 0 0.5rem;
      content: '|';
    }
  }

  // prettier-ignore
  .foot-link {
    font-weight: 500;
    @include fgcolor(primary, 6);
    &:hover { @include fgcolor(primary, 4); }
    & + & { margin-left: 0.5rem; }
  }
</style>

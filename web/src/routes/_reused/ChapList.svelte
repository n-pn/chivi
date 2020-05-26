<script>
  export let label = 'Chính văn'
  export let bslug = ''
  export let chaps = []
</script>

<h3 class="volume">
  <span class="label">{label}</span>
  <span class="count">({chaps.length} chương)</span>
</h3>

<ul class="chap-list">
  {#each chaps as chap}
    <li class="chap-item">
      <a class="chap-link" href="/{bslug}/{chap.url_slug}">
        <span class="chap-text">{chap.vi_title}</span>
      </a>
    </li>
  {/each}
</ul>

<style type="text/scss">
  .volume {
    margin-top: 0.75rem;
    padding-left: 0.75rem;
  }

  .count {
    @include fgcolor(color(neutral, 6));
  }

  .chap-list {
    margin-top: 0.25rem;
    &:last-child {
      margin-bottom: 0.75rem;
    }
    @include grid($size: minmax(20rem, 1fr), $gap: 0 0.5rem);
  }

  .chap-item {
    display: block;

    &:nth-child(odd) {
      background-color: #fff;
    }

    @include border($pos: bottom);
    &:first-child {
      @include border($pos: top);
    }

    @include screen-min(sm) {
      &:nth-child(2) {
        @include border($pos: top);
      }

      &:nth-child(4n),
      &:nth-child(4n + 1) {
        background-color: #fff;
      }

      &:nth-child(4n + 2),
      &:nth-child(4n + 3) {
        background-color: color(neutral, 1);
      }
    }
  }

  .chap-link {
    display: block;
    padding: 0.5rem 0.75rem;

    @include fgcolor(color(neutral, 7));
    @include hover {
      @include fgcolor(color(primary, 5));
    }
  }

  .chap-text {
    @include truncate();
  }
</style>

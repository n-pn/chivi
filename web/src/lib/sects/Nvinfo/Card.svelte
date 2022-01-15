<script>
  import BCover from '$atoms/BCover.svelte'

  export let nvinfo
</script>

<a href="/-{nvinfo.bslug}" class="nvinfo">
  <div class="cover">
    <BCover bcover={nvinfo.bcover} />
  </div>

  <div class="infos">
    <div class="extra _vname">
      <span class="-vi -trim">{nvinfo.vname}</span>
    </div>

    <div class="extra _zname">
      <small class="-zh -trim">{nvinfo.zname}</small>
    </div>

    <div class="extra _author">
      <span class="value -trim">{nvinfo.author}</span>
    </div>

    <div class="extra">
      <span class="label">Thể loại:</span>
      <span class="value">{nvinfo.genres[0]}</span>
    </div>

    <div class="extra">
      <span class="label">Đánh giá:</span>
      <span class="value">{nvinfo.rating == 0 ? '--' : nvinfo.rating}</span
      ><span class="label">/10</span>
    </div>
  </div>
</a>

<style lang="scss">
  .nvinfo {
    display: block;
    padding: 0.5rem;

    @include bgcolor(white);
    @include bdradi();
    @include shadow(1);

    @include flow;

    &:hover {
      @include shadow(2);

      .-zh,
      .-vi {
        @include fgcolor(primary, 5);
      }
    }
  }

  .cover {
    float: left;
    @include bdradi();
    @include bps(width, 35%, 30%);

    position: relative;
    overflow: hidden;

    @include flow;

    &:before {
      content: '';
      display: block;
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 0;
      padding-top: math.div(4, 3) * 100%;
      @include bgcolor(primary, 7);
      z-index: -1;
    }

    :global(img) {
      width: 100%;
      height: auto;
      @include bdradi();
    }
  }

  .infos {
    float: right;

    padding-left: 0.5rem;
    width: 65%;
    @include bps(width, 65%, 70%);
  }

  .extra {
    @include flow();
    margin-top: 0.25rem;

    > * {
      float: left;
    }
    > * + * {
      margin-left: 0.25rem;
    }
  }

  .-vi,
  .-zh {
    display: inline-block;
  }

  .-vi {
    line-height: 1.5rem;
    // font-weight: 500;
    @include ftsize(xl);
    @include fgcolor(neutral, 8);
  }

  .-zh {
    line-height: 1.25rem;
    margin-bottom: 0.25rem;
    @include ftsize(lg);
    @include fgcolor(neutral, 7);
  }

  .label {
    @include fgcolor(neutral, 6);
  }

  .value {
    font-weight: 500;
    @include fgcolor(neutral, 6);
  }

  .-trim {
    display: inline-block;
    max-width: 100%;
    @include clamp($width: null);
  }
</style>

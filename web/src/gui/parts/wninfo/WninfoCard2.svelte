<script lang="ts">
  import BCover from '$gui/atoms/BCover.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import { rel_time } from '$utils/time_utils'
  import { map_status } from '$utils/nvinfo_utils'
  export let nvinfo: CV.Wninfo
</script>

<a href="/wn/{nvinfo.id}" class="nvinfo">
  <div class="cover">
    <BCover srcset={nvinfo.bcover} />
  </div>

  <div class="infos">
    <div class="info _title"><div class="trim">{nvinfo.vtitle}</div></div>
    <div class="info"><strong class="trim">{nvinfo.vauthor}</strong></div>

    <div class="info">
      <span>Thể loại:</span>
      <strong>{nvinfo.genres[0]}</strong>
    </div>

    <div class="info">
      <span>Đánh giá:</span>
      <strong>{nvinfo.voters < 10 ? '--' : nvinfo.rating}</strong>
      <em>({nvinfo.voters} lượt)</em>
    </div>

    <div class="info _small">
      <span><SIcon name="activity" /></span>
      <em>{map_status(nvinfo.status)}</em>
      <span><SIcon name="clock" /></span>
      <em>{rel_time(nvinfo.mftime)}</em>
    </div>
  </div>
</a>

<style lang="scss">
  .nvinfo {
    display: flex;
    // overflow: hidden;

    @include bgcolor(secd);
    @include bdradi();
    @include shadow(1);

    &:hover {
      @include shadow(2);

      ._title {
        @include fgcolor(primary, 5);
      }
    }
  }

  .cover {
    height: 100%;
    width: 30%;
    flex-shrink: 0;

    overflow: hidden;
    @include bdradi($loc: left);

    :global(picture) {
      height: 100%;
      width: auto;
      border-radius: 0 !important;
    }
  }

  .infos {
    @include flex-cx;
    flex-direction: column;
    padding: 0.5rem var(--gutter);
    width: 70%;
  }

  .info {
    // @include flex-cy(0.25rem);
    @include fgcolor(tert);
    & + & {
      margin-top: 0.5rem;
    }
  }

  ._title {
    line-height: 1.5rem;
    // font-weight: 500;

    @include ftsize(xl);
    @include fgcolor(secd);
  }

  ._small {
    font-size: 0.95em;
  }

  .trim {
    @include clamp($lines: 1);
    // overflow: hidden;
  }
</style>

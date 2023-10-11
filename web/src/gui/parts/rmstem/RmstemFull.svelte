<script lang="ts" context="module">
  const status_strs = ['Còn tiếp', 'Hoàn thành', 'Tạm dừng', 'Không rõ']
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Truncate from '$gui/atoms/Truncate.svelte'
  import Crumb from '$gui/molds/Crumb.svelte'
  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import BCover from '$gui/atoms/BCover.svelte'

  export let rstem: CV.Rmstem
  export let binfo: CV.Wninfo

  // $: sroot = `/rm/${rstem.sname}:${rstem.sn_id}`

  $: intro = rstem.intro_vi || rstem.intro_zh
  $: sname = rstem.sname.substring(1)

  $: author = rstem.author_vi || rstem.author_zh

  $: labels = rstem.genre_vi || rstem.genre_zh

  $: dhtml = intro
    .split('\n')
    .map((x) => `<p>${x}</p>`)
    .join('\n')

  $: crumb = [
    { text: 'Nguồn nhúng ngoài', href: `/rm` },
    { text: sname, href: `/rm?sn=${rstem.sname}` },
    { text: `ID: ${rstem.sn_id}` },
  ]
</script>

<Crumb items={crumb} />

<section class="rinfo">
  <div class="names">
    <h1 class="title">{rstem.btitle_vi} - {rstem.btitle_zh}</h1>

    <div class="links">
      <span class="xstat">
        <span class="-text"><SIcon name="edit" /></span>
        <a class="-data _link" href="/rm?sby={author}">{author}</a>
      </span>

      <span class="xstat">
        <span class="-text"><SIcon name="world" /></span>
        <a class="-data _link" href="/rm?sn={rstem.sname}">{sname}</a>
        {#if rstem.rlink}
          <a class="-data _link" href={rstem.rlink}
            ><SIcon name="external-link" /></a>
        {/if}
      </span>
    </div>

    <div class="xtags labels">
      {#each labels.split('\t') as label}
        <a class="m-chip _xs" href="/rm?lb={label}">{label}</a>
      {/each}
    </div>

    {#if binfo}
      <div class="binfo">
        Liên kết với bộ truyện: <a class="m-link" href="/wn/{binfo.bslug}"
          >{binfo.vtitle} <SIcon name="external-link" />
        </a>
      </div>
    {/if}

    <div class="stats">
      <span class="xstat">
        <span class="-text">Số chương:</span>
        <span class="-data">{rstem.chap_count}</span>
      </span>

      <span class="xstat">
        <span class="-text">Cập nhật:</span>
        <span class="-data">{get_rtime(rstem.update_int)}</span>
      </span>

      <span class="xstat">
        <span class="-text">Trạng thái:</span>
        <span class="-data">{status_strs[rstem.status_int]}</span>
      </span>

      <span class="xstat">
        <span class="-text">Hệ số:</span>
        <span class="-data">{rstem.multp}</span>
      </span>

      <span class="xstat">
        <span class="-text">Lượt xem:</span>
        <span class="-data">{rstem.view_count}</span>
      </span>
    </div>
  </div>

  <div class="cover">
    <BCover srcset={rstem.cover_rm} />
  </div>
</section>

<h3>Giới thiệu:</h3>
<div class="intro">
  {#if intro}
    <Truncate html={dhtml} />
  {:else}
    <p>Chưa có giới thiệu</p>
  {/if}
</div>

<style lang="scss">
  .rinfo {
    display: flex;
  }

  .xtags {
    display: flex;
    gap: 0.2rem;
  }

  .title {
    display: block;
    padding: 0.25em 0;
    line-height: 1.5em;

    // @include ftsize();
    @include fgcolor(secd);

    @include bps(
      font-size,
      rem(18px),
      $pl: rem(20px),
      $ts: rem(24px),
      $tm: rem(28px)
    );
  }

  .links {
    @include fgcolor(tert);
    @include flex-cy($gap: 0.5rem);
    flex-wrap: wrap;
    margin-bottom: 0.5rem;

    font-style: normal;

    @include bps(
      font-size,
      rem(14px),
      $pl: rem(15px),
      $ts: rem(16px),
      $tm: rem(17px)
    );
  }

  .stats {
    @include flex($gap: 0.5rem);
    flex-wrap: wrap;
    font-style: italic;
    margin-bottom: 0.5rem;

    line-height: 1em;
    padding: 0.25em;

    @include bps(
      font-size,
      rem(13px),
      $pl: rem(14px),
      $ts: rem(15px),
      $tm: rem(16px)
    );
  }

  .xstat {
    display: inline-flex;
    align-items: center;
    gap: 0.25rem;

    .-text {
      @include fgcolor(mute);
    }

    .-data {
      @include fgcolor(secd);
    }

    :global(svg) {
      display: inline-flex;
      width: 1em;
      margin-bottom: 0.2em;
    }

    ._link {
      font-weight: 500;
      @include fgcolor(primary, 5);
      &:hover {
        @include fgcolor(primary, 6);
      }
    }
  }

  .binfo {
    margin-bottom: 0.5rem;
    @include bps(
      font-size,
      rem(14px),
      $pl: rem(15px),
      $ts: rem(16px),
      $tm: rem(17px)
    );
  }

  .cover {
    width: 30vw;
    min-width: 120px;
    max-width: 180px;
    padding-left: 0.75rem;
    margin-left: auto;
  }

  .intro {
    font-style: italic;
    @include fgcolor(tert);
    @include ftsize(sm);
    line-height: 1.25rem;
    margin-bottom: 1rem;

    --line: 4;
  }

  .labels {
    margin-bottom: 0.5rem;
    flex-wrap: wrap;
  }
</style>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Truncate from '$gui/atoms/Truncate.svelte'
  import ChapList from '$gui/parts/wnchap/ChapList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ustem, binfo, chaps, rmemo } = data)

  $: intro = ustem.vdesc || ''
  $: dhtml = intro
    .split('\n')
    .map((x: string) => `<p>${x.replace(/</g, '&lt;')}</p>`)
    .join('\n')

  $: repo_path = `/ts/up${ustem.sname}/${ustem.id}`
</script>

<section>
  <h3 class="sub">Giới thiệu:</h3>

  <div class="intro">
    {#if ustem.vdesc}
      <Truncate html={dhtml} />
    {:else}
      <p class="u-mute">Chưa có giới thiệu</p>
    {/if}
  </div>
</section>

<section>
  <h3 class="sub">Từ khoá:</h3>

  {#if ustem.labels.length > 0}
    <div class="tags">
      {#each ustem.labels as label}
        <a class="tag m-link" href="/up?lb={label}">
          <SIcon name="hash" />
          <span>{label}</span>
        </a>
      {/each}
    </div>
  {:else}
    <div class="d-empty-xs">Không có từ khóa</div>
  {/if}
</section>

<section>
  <h3 class="sub">Liên kết:</h3>

  {#if binfo}
    <a class="binfo m-link" href="/wn/{binfo.bslug}"
      >{binfo.vtitle} <SIcon name="external-link" />
    </a>
  {:else}
    <p class="u-mute">Chưa liên kết tới thông tin truyện chữ</p>
  {/if}
</section>

<section>
  <h3 class="sub">
    <span>Chương mới nhất:</span>
    <a href={repo_path} class="sub-link">Xem tất cả</a>
  </h3>
  <ChapList crepo={data.crepo} rmemo={$rmemo} {chaps} />
</section>

<style lang="scss">
  section {
    margin: 1rem 0;
  }

  .sub {
    line-height: 2rem;
    height: 2rem;
    margin-bottom: 0.75rem;
    @include flex($gap: 0.5rem);
    @include border(--bd-main, $loc: bottom);
  }

  .sub-link {
    margin-left: auto;
    font-style: italic;
    @include ftsize(md);
    @include fgcolor(tert);

    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  .tag {
    display: inline-flex;
    align-items: center;
    margin-right: 0.5rem;
    // line-height: 1.25rem;
    @include ftsize(lg);
  }

  .intro {
    font-style: italic;
    @include fgcolor(tert);
    --line: 4;
  }

  .binfo {
    @include ftsize(lg);
    margin-bottom: 0.5rem;
  }
</style>

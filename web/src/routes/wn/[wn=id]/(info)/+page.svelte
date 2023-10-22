<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  import Truncate from '$gui/atoms/Truncate.svelte'
  import GdreplList from '$gui/parts/dboard/GdreplList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ gdroot, rplist, nvinfo } = data)

  let short_intro = false
  $: dhtml = nvinfo.bintro
    .split('\n')
    .map((x) => `<p>${x}</p>`)
    .join('\n')
</script>

<h2>Giới thiệu:</h2>
<div class="intro" class:_short={short_intro}>
  <Truncate html={dhtml} />
</div>

<h3 class="sub">Từ khoá</h3>

<div class="tags">
  {#each nvinfo.labels as label}
    <a class="tag" href="/wn?tagged={label}">
      <SIcon name="hash" />
      <span>{label}</span>
    </a>
  {/each}
</div>

<h3 class="sub">Thảo luận</h3>
<GdreplList {gdroot} {rplist} />

<style lang="scss">
  // article {
  //   @include bps(margin-left, 0rem, 0.25rem, 1.5rem, 2rem);
  //   @include bps(margin-right, 0rem, 0.25rem, 1.5rem, 2rem);
  // }

  .intro {
    word-wrap: break-word;
    @include fgcolor(secd);
    // @include bps(padding, $md: 0 0.75rem);
    @include bps(font-size, rem(15px), rem(16px), rem(17px));

    &._short {
      height: 20rem;
      overflow-y: scroll;
      scrollbar-width: thin;
      scrollbar-color: color(gray, 8);
    }

    > :global(p) {
      margin-top: 0.75rem;
    }
  }

  .sub {
    line-height: 2rem;
    height: 2rem;
    margin-bottom: 0.75rem;
    @include flex($gap: 0.5rem);
    @include border(--bd-main, $loc: bottom);
  }

  .tag {
    display: inline-flex;
    align-items: center;
    margin-right: 0.5rem;
    line-height: 1.25rem;
    @include fgcolor(primary, 5);
    &:hover {
      @include border(primary, 5, $loc: bottom);
    }
  }

  h2,
  h3 {
    margin-top: 1rem;
  }
</style>

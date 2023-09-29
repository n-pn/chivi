<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Truncate from '$gui/atoms/Truncate.svelte'
  import Crumb from '$gui/molds/Crumb.svelte'
  import { get_rtime } from '$gui/atoms/RTime.svelte'

  export let ustem: CV.Upstem
  export let binfo: CV.Wninfo

  $: uname = ustem.sname.substring(1)

  $: dhtml = ustem.vintro
    .split('\n')
    .map((x) => `<p>${x}</p>`)
    .join('\n')

  $: crumb = [
    { text: 'Dự án cá nhân', href: `/up` },
    { text: ustem.sname, href: `/up?by=${uname}` },
    { text: `ID: ${ustem.id}` },
  ]
</script>

<Crumb items={crumb} />

<div class="xtags m-chips">
  <a class="m-chip _xs _primary" href="/up?by={uname}">{ustem.sname}</a>
  {#each ustem.labels as label}
    <a class="m-chip _xs" href="/up?lb={label}">{label}</a>
  {/each}
</div>
<h1 class="title">{ustem.vname}</h1>

<div class="stats">
  <span class="-stat">
    <span class="-text">Số chương:</span>
    <span class="-data">{ustem.chap_count}</span>
  </span>

  <span class="-stat">
    <span class="-text">Cập nhật:</span>
    <span class="-data">{get_rtime(ustem.mtime)}</span>
  </span>
</div>

{#if binfo}
  <div class="binfo">
    Liên kết với bộ truyện: <a class="m-link" href="/wn/{binfo.bslug}"
      >{binfo.vtitle} <SIcon name="external-link" />
    </a>
  </div>
{/if}

<div class="intro">
  {#if ustem.vintro}
    <Truncate --line={4} html={dhtml} show_btn={ustem.vintro.length > 200} />
  {:else}
    <p>Chưa có giới thiệu</p>
  {/if}
</div>

<style lang="scss">
  .xtags {
    display: flex;
    gap: 0.2rem;
  }

  .title {
    display: block;
    padding: 0.5rem 0;

    // @include ftsize();
    @include fgcolor(secd);
  }

  .stats {
    @include flex($gap: 0.5rem);
    font-style: italic;
    @include fgcolor(mute);
    margin-bottom: 0.5rem;

    .-data {
      font-weight: 500;
      @include fgcolor(tert);
    }
  }

  .binfo {
    @include ftsize(lg);
    margin-bottom: 0.5rem;
  }

  .intro {
    font-style: italic;
    @include fgcolor(tert);
    @include ftsize(sm);
    line-height: 1.25rem;
    margin-bottom: 1rem;
  }
</style>
